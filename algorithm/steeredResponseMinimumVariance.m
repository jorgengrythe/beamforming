function S = steeredResponseMinimumVariance(R, e)
%steeredResponseMinimumVariance - minimum variance beamforming
%
%Calculates the steered response from the minimum variance beamforming algorithm in
%the frequency domain based on sensor positions, input signal and scanning angles
%
%S = steeredResponseMinimumVariance(R, e)
%
%IN
%R - PxP correlation matrix / cross spectral matrix (CSM)
%e - NxMxP steering vector/matrix for a certain frequency
%
%OUT
%S - NxM matrix of minimum variance steered response power
%
%Created by J?rgen Grythe, Squarehead Technology AS
%Last updated 2016-12-06


[nPointsY, nPointsX, nMics] = size(e);

%Cross spectral matrix with diagonal loading
R = R + trace(R)/(nMics^2)*eye(nMics, nMics);
R = R/nMics;
R = inv(R);

%Minimum variance steered response power
S = zeros(nPointsY, nPointsX);
for pointY = 1:nPointsY
    for pointX = 1:nPointsX
        ee = reshape(e(pointY, pointX, :), nMics, 1);
        S(pointY, pointX) = 1./(ee'*R*ee);
    end
end