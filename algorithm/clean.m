c = 340;
fs = 44.1e3;
coherence = 0;
thetaScanningAngles = -90:1:90;
phiScanningAngles = 0:1:180;

%Set parameters of incoming narrowband signal(s)
f = 3e3;
thetaArrivalAngles = [45 30 45 ...
                      -30 0 30 ...
                      45 30 45]/1.5;
phiArrivalAngles = [135 90 45 ...
                    0 0 0 ...
                    -135 -90 -45];
amplitudes = [0 0.5 1 ...
              1.5 2 2.5 ...
              3 3.5 4];
          


% Load array
load data/arrays/Nor848A-4.mat
w = ones(1, 128)/128;
w = hiResWeights;


%Create input signal
inputSignal = createSignal(xPos, yPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles, amplitudes);



nSensors = numel(xPos);
nSamples = numel(inputSignal);
nThetaAngles = numel(thetaScanningAngles);
nPhiAngles = numel(phiScanningAngles);
k = 2*pi*f/c;
P = numel(xPos);

%Calculate steering vector/matrix (MxNxP)
kx = sin(thetaScanningAngles*pi/180)'*cos(phiScanningAngles*pi/180);
ky = sin(thetaScanningAngles*pi/180)'*sin(phiScanningAngles*pi/180);
kxx = bsxfun(@times, kx, reshape(xPos, 1, 1, P));
kyy = bsxfun(@times, ky, reshape(yPos, 1, 1, P));
e = exp(1j*k*(kxx + kyy));


%Calculate correlation matrix / cross spectral matrix
R = inputSignal*inputSignal';
R = R/nSamples;

% CLEAN method

%Safety factor 0 < loopGain < 1
loopGain = 1;

%Initialise cross spectral matrix
D = R;

%Initialise final clean image
Q = zeros(nThetaAngles, nPhiAngles);

% --- iteration start ---

for it = 1:1
    
    
    % -------------------------------------------------------
    % 1. Calculate dirty map with diagonal of CSM removed
    D(logical(eye(nSensors))) = 0;
    
    P = zeros(nThetaAngles, nPhiAngles);
    for angleTheta = 1:nThetaAngles
        for anglePhi = 1:nPhiAngles
            ee = reshape(e(angleTheta, anglePhi,:), nSensors, 1);
            P(angleTheta, anglePhi) = (ee'.*w)*D*(w'.*ee);
        end
    end
    
    
    % -------------------------------------------------------
    % 2. Find peak value and its position in dirty map
    [maxSourcePower, maxSourcePowerIndex] = max(P(:));
    [maxSourcePowerThetaIndx, maxSourcePowerPhiIndx] = ind2sub(size(P), maxSourcePowerIndex);
    
    maxSourcePowerPhiAngle = phiScanningAngles(maxSourcePowerPhiIndx);
    maxSourcePowerThetaAngle = thetaScanningAngles(maxSourcePowerThetaIndx);
    
    
    % -------------------------------------------------------
    % 3. Get the PSF from this location
    
    %Steering vector to location of peak source
    g = squeeze(e(maxSourcePowerThetaIndx, maxSourcePowerPhiIndx, :));
    
    %Cross spectral matrix induced by peak source in that direction (eq. 11)
    G = g*g';
    G(logical(eye(nSensors))) = 0;
    
    %PSF from location of peak source
    Pmax = zeros(nThetaAngles, nPhiAngles);
    for angleTheta = 1:nThetaAngles
        for anglePhi = 1:nPhiAngles
            ee = reshape(e(angleTheta, anglePhi,:), nSensors, 1);
            Pmax(angleTheta, anglePhi) = (ee'.*w)*G*(w'.*ee);
        end
    end
    
    
    % -------------------------------------------------------
    % 4. Subtract dirty map by PSF from location of peak source (eq. 12)
    P = P - maxSourcePower*Pmax;

    
    % -------------------------------------------------------
    % 5. New updated map with clean beam from peak source location (eq. 13)
    % Clean beam with specified width and max value of 1
    
    PmaxCleanBeam = zeros(size(Pmax));
    umax = sin(thetaScanningAngles(maxSourcePowerThetaIndx)*pi/180)*cos(phiScanningAngles(maxSourcePowerPhiIndx)*pi/180);
    vmax = sin(thetaScanningAngles(maxSourcePowerThetaIndx)*pi/180)*sin(phiScanningAngles(maxSourcePowerPhiIndx)*pi/180);
    for angleTheta = 1:nThetaAngles
        for anglePhi = 1:nPhiAngles
            u = sin(thetaScanningAngles(angleTheta)*pi/180)*cos(phiScanningAngles(anglePhi)*pi/180);
            v = sin(thetaScanningAngles(angleTheta)*pi/180)*sin(phiScanningAngles(anglePhi)*pi/180);
            if sqrt((u-umax)^2 + (v-vmax)^2) < 0.1
                PmaxCleanBeam(angleTheta, anglePhi) = Pmax(angleTheta, anglePhi);
            end
        end
    end
    
    % Calculate the source strength distribution
    Q = Q + loopGain*maxSourcePower*PmaxCleanBeam;
    
    
    
    % -------------------------------------------------------
    % 5. Calculate degraded cross spectral matrix (eq. 14)
    D = D - loopGain*maxSourcePower*G;
    
end



% --- iteration end ---

% 5. Source plot is written as summation of clean beams and rest of source
% map

Q = Q + P;


plotSteeredResponse(Q, kx, ky, 50)

%%
figure;surf(kx, ky, 20*log10(abs(S)), 'edgecolor', 'none')
figure;surf(kx, ky, 20*log10(abs(Pmax)), 'edgecolor', 'none')

    plotSteeredResponse(P, kx, ky, 50)
    hold on
    plot3(sin(maxSourcePowerThetaAngle*pi/180)*cos(maxSourcePowerPhiAngle*pi/180), ...
        sin(maxSourcePowerThetaAngle*pi/180)*sin(maxSourcePowerPhiAngle*pi/180), ...
        0, 'k+', 'MarkerSize', 10, 'LineWidth', 2)




