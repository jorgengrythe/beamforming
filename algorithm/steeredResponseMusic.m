function [S, kx, ky, V] = steeredResponseMusic(x_pos, y_pos, inputSignal, f, c, thetaScanningAngles, phiScanningAngles, nSources)

%Set up variables
if ~exist('thetaScanningAngles', 'var')
    thetaScanningAngles = -90:90;
end

if ~exist('phiScanningAngles', 'var')
    phiScanningAngles = 0:180;
end

nSensors = size(inputSignal,1);
nSamples = size(inputSignal,2);
nThetaAngles = numel(thetaScanningAngles);
nPhiAngles = numel(phiScanningAngles);

%Calculate steering vector for all scanning angles
[e, kx, ky] = steeringVector(x_pos, y_pos, f, c, thetaScanningAngles, phiScanningAngles);

%Calculate correlation matrix with diagonal loading
R = inputSignal*inputSignal';
R = R + trace(R)/(nSensors^2)*eye(nSensors, nSensors);
R = R/nSamples;

[V,~] = eig(R);%eigenvectors of R
Vn = V(:,1:end-nSources);%noise eigenvectors

%Calculate power as a function of scanning angle (minimum variance)
S = zeros(nThetaAngles,nPhiAngles);
for angleTheta = 1:nThetaAngles
    for anglePhi = 1:nPhiAngles
        
        %Get steering vector from single scanning point
        ee = squeeze(e(angleTheta,anglePhi,:));
        
        %Calculate power from that scanning point
        S(angleTheta,anglePhi) = 1./(ee'*(Vn*Vn')*ee);
    end
end