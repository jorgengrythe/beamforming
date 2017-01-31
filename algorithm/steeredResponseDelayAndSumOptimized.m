function [S, u, v, w, R, e] = steeredResponseDelayAndSumOptimized(xPos, yPos, zPos, elementWeights, inputSignal, f, c, thetaScanningAngles, phiScanningAngles)
%steeredResponseDelayAndSum - calculate delay and sum in frequency domain
%
%Calculates the steered response from the delay-and-sum algorithm in the
%frequency domain based on sensor positions, input signal and scanning angles
%
%[S, u, v, w, R, e] = steeredResponseDelayAndSumOptimized(xPos, yPos, zPos, elementWeights, inputSignal, f, c, thetaScanningAngles, phiScanningAngles)
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
%w                   - NxM matrix of w coordinates in UV space [cos(theta)]
%R                   - PxP correlation matrix / cross spectral matrix (CSM)
%e                   - NxMxP steering vector/matrix 
%
%Created by J?rgen Grythe, Squarehead Technology AS
%Last updated 2017-01-31


if ~exist('thetaScanningAngles', 'var')
    thetaScanningAngles = -90:90;
end

if ~exist('phiScanningAngles', 'var')
    phiScanningAngles = 0:180;
end


%Calculate steering vector for all scanning angles
[e, u, v, w] = steeringVector(xPos, yPos, zPos, f, c, thetaScanningAngles, phiScanningAngles);

%Calculate correlation matrix
inputSignal = diag(elementWeights)*inputSignal;
R = inputSignal*inputSignal';


%N # of y-points, M # of x-points, P number of mics
[N, M, P] = size(e);

S = zeros(N, M);
for y = 1:N
    for x = 1:M
        ee = reshape(e(y, x, :), P, 1);
        S(y, x) = ee'*R*ee;
    end
end



