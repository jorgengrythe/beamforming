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
%thetaScanningAngles - 1xM vector or MxN matrix of theta scanning angles [degrees]
%phiScanningAngles   - 1xN vector or MxN matrix of of phi scanning angles [degrees]
%
%OUT
%S                   - MxN matrix of delay-and-sum steered response power
%u                   - MxN matrix of u coordinates in UV space [sin(theta)*cos(phi)]  
%v                   - MxN matrix of v coordinates in UV space [sin(theta)*sin(phi)]
%w                   - MxN matrix of w coordinates in UV space [cos(theta)]
%R                   - PxP correlation matrix / cross spectral matrix (CSM)
%e                   - MxNxP steering vector/matrix 
%
%Created by J?rgen Grythe
%Last updated 2017-02-27


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


%M # of y-points, N # of x-points, P number of mics
[M, N, P] = size(e);

S = zeros(M, N);
for y = 1:M
    for x = 1:N
        ee = reshape(e(y, x, :), P, 1);
        S(y, x) = ee'*R*ee;
    end
end



