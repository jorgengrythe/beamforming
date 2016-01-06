function [S, kx, ky] = steeredResponseMinimumVariance(xPos, yPos, inputSignal, f, c, thetaScanningAngles, phiScanningAngles)
%steeredResponseMinimumVariance - minimum variance beamforming
%
%Calculates the steered response from the minimum variance beamforming algorithm in
%the frequency domain based on sensor positions, input signal and scanning angles
%
%[S, kx, ky] = steeredResponseMinimumVariance(xPos, yPos, inputSignal, f, c, thetaScanningAngles, phiScanningAngles)
%
%IN
%xPos                - 1xP vector of x-positions [m]
%yPos                - 1xP vector of y-positions [m]
%w                   - 1xP vector of element weights
%inputSignal         - PxL vector of inputsignals consisting of L samples
%f                   - Wave frequency [Hz]
%c                   - Speed of sound [m/s]
%thetaScanningAngles - 1xN vector of theta scanning angles [degrees]
%phiScanningAngles   - 1xM vector of phi scanning angles [degrees]
%
%OUT
%S                   - NxM matrix of minimum variance steered response power
%kx                  - 1xN vector of theta scanning angles in polar coordinates
%ky                  - 1xM vector of phi scanning angles in polar coordinates
%
%Created by Jørgen Grythe, Norsonic AS
%Last updated 2015-10-27


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
[e, kx, ky] = steeringVector(xPos, yPos, f, c, thetaScanningAngles, phiScanningAngles);

%Calculate correlation matrix with diagonal loading
R = inputSignal*inputSignal';
R = R + trace(R)/(nSensors^2)*eye(nSensors, nSensors);
R = R/nSamples;

%Calculate power as a function of scanning angle (minimum variance)
S = zeros(nThetaAngles,nPhiAngles);
for angleTheta = 1:nThetaAngles
    for anglePhi = 1:nPhiAngles
        
        %Get steering vector from single scanning point
        ee = squeeze(e(angleTheta,anglePhi,:));
        
        %Calculate power from that scanning point
        S(angleTheta,anglePhi) = 1./(ee'*(R\ee));
    end
end