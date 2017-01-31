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
%Last updated 2017-01-31

%N # of y-points, M # of x-points, P number of mics
[N, M, P] = size(e);

%Cross spectral matrix with diagonal loading
R = R + trace(R)/(P^2)*eye(P, P);
R = R/P;

%Eigenvectors of R
[V,~] = eig(R);

%Noise eigenvectors
Vn = V(:,1:end-nSources);

%Music steered response power
S = zeros(N, M);
for y = 1:N
    for x = 1:M
        ee = reshape(e(y, x, :), P, 1);
        S(y, x) = 1./(ee'*(Vn*Vn')*ee);
    end
end

