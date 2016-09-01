clear all
c = 340;
fs = 44.1e3;
f = 3e3;
maxIterations = 100;
% Load array
load data/arrays/Nor848A-4.mat
w = ones(1, numel(xPos))/numel(xPos);
w = hiResWeights;
nSensors = numel(xPos);

%Scanning points
distanceToScanningPlane = 2; %[m]
numberOfScanningPointsX = 40;
numberOfScanningPointsY = 30;

coveringAngleX = 48.5;
coveringAngleY = 35;
maxScanningPlaneExtentX = tan(coveringAngleX*pi/180);
maxScanningPlaneExtentY = tan(coveringAngleY*pi/180);

scanningAxisX = -maxScanningPlaneExtentX:2*maxScanningPlaneExtentX/(numberOfScanningPointsX-1):maxScanningPlaneExtentX;
scanningAxisY = -maxScanningPlaneExtentY:2*maxScanningPlaneExtentY/(numberOfScanningPointsY-1):maxScanningPlaneExtentY;

[scanningPointsX, scanningPointsY] = meshgrid(scanningAxisX, scanningAxisY);
[thetaScanningAngles, phiScanningAngles] = convertCartesianToPolar(scanningPointsX, scanningPointsY, distanceToScanningPlane);


% Set parameters of incoming narrowband signal(s)
xPosSource = [0.4 -0.8 -0.2 0.8 0];
yPosSource = [0 -0.3 0.4 0.6 -0.4];
zPosSource = distanceToScanningPlane;
amplitudes = [2 3.5 1.5 2 0];
[thetaArrivalAngles, phiArrivalAngles] = convertCartesianToPolar(xPosSource, yPosSource, zPosSource);




%Create input signal
inputSignal = createSignal(xPos, yPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles, amplitudes);


%Create steering vector/matrix
e = steeringVector(xPos, yPos, f, c, thetaScanningAngles, phiScanningAngles);


% CLEAN method

%Safety factor 0 < loopGain < 1
loopGain = 0.9;

%Initialise cross spectral matrix
D = inputSignal*inputSignal';
D(logical(eye(nSensors))) = 0;

%Initialise final clean image
Q = zeros(numberOfScanningPointsY, numberOfScanningPointsX);

%Initialise break criterion
sumOfCSM = sum(sum(abs(D)));
sumOfDegradedCSM = sumOfCSM;

% --- iteration start ---
    
for it = 1:maxIterations
    

    % -------------------------------------------------------
    % 1. Calculate dirty map
    P = zeros(numberOfScanningPointsY, numberOfScanningPointsX);
    for scanningPointY = 1:numberOfScanningPointsY
        for scanningPointX = 1:numberOfScanningPointsX
            ee = reshape(e(scanningPointY, scanningPointX, :), nSensors, 1);
            P(scanningPointY, scanningPointX) = (ee'.*w)*D*(w'.*ee);
        end
    end
    
    %Plot original delay-and-sum source distribution
    if it==1
        plotSteeredResponseXY(P, scanningPointsX, scanningPointsY, 1)
        hold on
        plot3(xPosSource, yPosSource, ones(1, numel(xPosSource))*60, 'k+')
    end
    
    
    % -------------------------------------------------------
    % 2. Find peak value and its position in dirty map
    [maxSourcePower, maxSourcePowerIndex] = max(P(:));
    [maxSourcePowerYIndx, maxSourcePowerXIndx] = ind2sub(size(P), maxSourcePowerIndex);
    
    maxSourcePowerXLocation = scanningPointsX(maxSourcePowerXIndx);
    maxSourcePowerYLocation = scanningPointsY(maxSourcePowerYIndx);
    
    
    
    % -------------------------------------------------------
    % 3. Get the PSF from this location and subtract from dirty map
    
    %Steering vector to location of peak source
    g = squeeze(e(maxSourcePowerYIndx, maxSourcePowerXIndx, :));
    
    %Cross spectral matrix induced by peak source in that direction (eq. 11)
    G = g*g';
    G(logical(eye(nSensors))) = 0;
    
%     %PSF from location of peak source
%     Pmax = zeros(numberOfScanningPointsY,numberOfScanningPointsX);
%     for scanningPointY = 1:numberOfScanningPointsY
%         for scanningPointX = 1:numberOfScanningPointsX
%             ee = reshape(e(scanningPointY, scanningPointX, :), nSensors, 1);
%             Pmax(scanningPointY, scanningPointX) = (ee'.*w)*G*(w'.*ee);
%         end
%     end
%     
%     P = P - maxSourcePower*Pmax;
%     
%     if it==1
%         plotSteeredResponseXY(P, scanningPointsX, scanningPointsY, 2)
%         hold on
%         plot3(xPosSource, yPosSource, ones(1, numel(xPosSource))*60, 'k+')
%     end
    
    
    % -------------------------------------------------------
    % 4. New updated map with clean beam from peak source location (eq. 13)
    % Clean beam with specified width and max value of 1
    
    PmaxCleanBeam = zeros(numberOfScanningPointsY, numberOfScanningPointsX);
    PmaxCleanBeam(maxSourcePowerYIndx, maxSourcePowerXIndx) = 1;
    
    % Calculate the source strength distribution
    Q = Q + loopGain*maxSourcePower*PmaxCleanBeam;
    
    
    
    % -------------------------------------------------------
    % 5. Calculate degraded cross spectral matrix (eq. 14)
    %Basically removing the PSF from that location of the plot
    D = D - loopGain*maxSourcePower*G;
    D(logical(eye(nSensors))) = 0;
    
    
    % Check to see if break criterion is fulfilled
    sumOfCSM = sum(sum(abs(D)));
    if sumOfCSM > sumOfDegradedCSM
        disp(['Converged after ' num2str(it) ' iterations'])
        break;
    end
    sumOfDegradedCSM = sumOfCSM;
    
    % --- iteration end ---
    
end

% 5. Source plot is written as summation of clean beams and rest of source
% map

Q = Q + P;



plotSteeredResponseXY(Q, scanningPointsX, scanningPointsY, 2)
hold on
plot3(xPosSource, yPosSource, ones(1, numel(xPosSource))*60, 'k+')






