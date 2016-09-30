function [S, V, Vn] = steeredResponseMusic(R, e, nSources)
%steeredResponseMusic - MUSIC beamforming
%
%Calculates the steered response from the MUSIC beamforming algorithm in
%the frequency domain based on sensor positions, input signal and scanning angles
%
%S = steeredResponseMusic(R, e, nSources)
%
%IN
%R        - PxP correlation matrix / cross spectral matrix (CSM)
%e        - NxMxP steering vector/matrix for a certain frequency
%nSources - Number of sources present in input
%
%OUT
%S        - NxM matrix of MUSIC steered response power
%V        - Eigenvectors of correlation matrix
%Vn       - Noise eigenvectors
%
%Created by J?rgen Grythe, Squarehead Technology AS
%Last updated 2016-09-30


[nPointsY, nPointsX, nMics] = size(e);

%Cross spectral matrix with diagonal loading
R = R + trace(R)/(nMics^2)*eye(nMics, nMics);
R = R/nMics;

%Eigenvectors of R
[V,~] = eig(R);

%Noise eigenvectors
Vn = V(:,1:end-nSources);

%Music steered response power
S = zeros(nPointsY, nPointsX);
for pointY = 1:nPointsY
    for pointX = 1:nPointsX
        ee = reshape(e(pointY, pointX, :), nMics, 1);
        S(pointY, pointX) = 1./(ee'*(Vn*Vn')*ee);
    end
end

