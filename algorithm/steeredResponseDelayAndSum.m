function [S, kx, ky] = steeredResponseDelayAndSum(xPos, yPos, w, inputSignal, f, c, thetaScanningAngles, phiScanningAngles)
%steeredResponseDelayAndSum - calculate delay and sum in frequency domain
%
%Calculates the steered response from the delay-and-sum algorithm in the
%frequency domain based on sensor positions, input signal and scanning angles
%
%[S, kx, ky] = steeredResponseDelayAndSum(xPos, yPos, w, inputSignal, f, c, thetaScanningAngles, phiScanningAngles)
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
%S                   - NxM matrix of delay-and-sum steered response power
%kx                  - 1xN vector of theta scanning angles in polar coordinates
%ky                  - 1xM vector of phi scanning angles in polar coordinates
%
%Created by Jørgen Grythe, Norsonic AS
%Last updated 2015-10-06


if ~exist('thetaScanningAngles', 'var')
    thetaScanningAngles = -90:90;
end

if ~exist('phiScanningAngles', 'var')
    phiScanningAngles = 0:180;
end

nSensors = numel(xPos);
nSamples = numel(inputSignal);
nThetaAngles = numel(thetaScanningAngles);
nPhiAngles = numel(phiScanningAngles);

%Calculate steering vector for all scanning angles
[e, kx, ky] = steeringVector(xPos, yPos, f, c, thetaScanningAngles, phiScanningAngles);

%Multiply input signal by weighting vector
inputSignal = diag(w)*inputSignal;

%Calculate correlation matrix
R = inputSignal*inputSignal';
R = R/nSamples;


%Calculate power as a function of steering vector/scanning angle (delay-and-sum)
S = zeros(nThetaAngles,nPhiAngles);
for angleTheta = 1:nThetaAngles
    for anglePhi = 1:nPhiAngles
        ee = reshape(e(angleTheta, anglePhi,:), nSensors, 1);
        S(angleTheta,anglePhi) = ee'*R*ee;
    end
end