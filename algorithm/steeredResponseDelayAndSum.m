function [S, u, v, R, e] = steeredResponseDelayAndSum(xPos, yPos, w, inputSignal, f, c, thetaScanningAngles, phiScanningAngles)
%steeredResponseDelayAndSum - calculate delay and sum in frequency domain
%
%Calculates the steered response from the delay-and-sum algorithm in the
%frequency domain based on sensor positions, input signal and scanning angles
%
%[S, R, e, u, v] = steeredResponseDelayAndSum(xPos, yPos, w, inputSignal, f, c, thetaScanningAngles, phiScanningAngles)
%
%IN
%xPos                - 1xP vector of x-positions [m]
%yPos                - 1xP vector of y-positions [m]
%w                   - 1xP vector of element weights
%inputSignal         - PxL vector of input signals consisting of L samples
%f                   - Wave frequency [Hz]
%c                   - Speed of sound [m/s]
%thetaScanningAngles - 1xN vector or NxM matrix of theta scanning angles [degrees]
%phiScanningAngles   - 1xM vector or NxM matrix of of phi scanning angles [degrees]
%
%OUT
%S                   - NxM matrix of delay-and-sum steered response power
%u                   - NxM matrix of u coordinates in UV space [sin(theta)*cos(phi)]  
%v                   - NxM matrix of v coordinates in UV space [sin(theta)*sin(phi)]
%R                   - PxP correlation matrix / cross spectral matrix (CSM)
%e                   - NxMxP steering vector/matrix 
%
%Created by J?rgen Grythe, Squarehead Technology AS
%Last updated 2016-09-07


if ~exist('thetaScanningAngles', 'var')
    thetaScanningAngles = -90:90;
end

if ~exist('phiScanningAngles', 'var')
    phiScanningAngles = 0:180;
end

nSensors = numel(xPos);

%Calculate steering vector for all scanning angles
[e, u, v] = steeringVector(xPos, yPos, f, c, thetaScanningAngles, phiScanningAngles);


%Calculate correlation matrix
R = inputSignal*inputSignal';

%Make the weighting vector a column vector instead of row vector
if isrow(w)
    w = w';
end

%Calculate power as a function of steering vector/scanning angle (delay-and-sum)
%with scanning angles as either vectors or matrices
if isvector(thetaScanningAngles);
    numberOfRowsInS = numel(thetaScanningAngles);
    numberOfColsInS = numel(phiScanningAngles);
else
    [numberOfRowsInS, numberOfColsInS] = size(thetaScanningAngles);
end

S = zeros(numberOfRowsInS, numberOfColsInS);
for rowScanningPoint = 1:numberOfRowsInS
    for columnScanningPoint = 1:numberOfColsInS
        ee = reshape(e(rowScanningPoint, columnScanningPoint, :), nSensors, 1);
        S(rowScanningPoint, columnScanningPoint) = (w.*ee)'*R*(ee.*w);
    end
end



