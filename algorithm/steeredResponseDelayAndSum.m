function [S, R, e, u, v] = steeredResponseDelayAndSum(xPos, yPos, w, inputSignal, f, c, thetaScanAngles, phiScanAngles)
%steeredResponseDelayAndSum - calculate delay and sum in frequency domain
%
%Calculates the steered response from the delay-and-sum algorithm in the
%frequency domain based on sensor positions, input signal and scanning angles
%
%[S, R, e, u, v] = steeredResponseDelayAndSum(xPos, yPos, w, inputSignal, f, c, thetaScanAngles, phiScanAngles)
%
%IN
%xPos            - 1xP vector of x-positions [m]
%yPos            - 1xP vector of y-positions [m]
%w               - 1xP vector of element weights
%inputSignal     - PxL vector of input signals consisting of L samples
%f               - Wave frequency [Hz]
%c               - Speed of sound [m/s]
%thetaScanAngles - 1xN vector or NxM matrix of theta scanning angles [degrees]
%phiScanAngles   - 1xM vector or NxM matrix of of phi scanning angles [degrees]
%
%OUT
%S               - NxM matrix of delay-and-sum steered response power
%R               - PxP correlation matrix / cross spectral matrix (CSM)
%e               - NxMxP steering vector/matrix
%u               - NxM matrix of u coordinates in UV space [sin(theta)*cos(phi)]  
%v               - NxM matrix of v coordinates in UV space [sin(theta)*sin(phi)]
%
%Created by J?rgen Grythe, Squarehead Technology AS
%Last updated 2016-09-24


if ~exist('thetaScanningAngles', 'var')
    thetaScanAngles = -90:90;
end

if ~exist('phiScanningAngles', 'var')
    phiScanAngles = 0:180;
end

nMics = numel(xPos);

%Calculate steering vector for all scanning angles
[e, u, v] = steeringVector(xPos, yPos, f, c, thetaScanAngles, phiScanAngles);


%Calculate correlation matrix
R = inputSignal*inputSignal';

%Make the weighting vector a column vector instead of row vector
if isrow(w)
    w = w';
end

%Calculate power as a function of steering vector/scanning angle (delay-and-sum)
%with scanning angles as either vectors or matrices
if isvector(thetaScanAngles);
    nPointsY = numel(thetaScanAngles);
    nPointsX = numel(phiScanAngles);
else
    [nPointsY, nPointsX] = size(thetaScanAngles);
end

S = zeros(nPointsY, nPointsX);
for pointY = 1:nPointsY
    for pointX = 1:nPointsX
        ee = reshape(e(pointY, pointX, :), nMics, 1);
        S(pointY, pointX) = (w.*ee)'*R*(ee.*w);
    end
end



