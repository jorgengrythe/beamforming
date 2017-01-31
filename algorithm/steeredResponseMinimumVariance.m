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
%Last updated 2017-01-31

%N # of y-points, M # of x-points, P number of mics
[N, M, P] = size(e);

%Cross spectral matrix with diagonal loading
R = R + trace(R)/(P^2)*eye(P, P);
R = R/P;
R = inv(R);

%Minimum variance steered response power
S = zeros(N, M);
for y = 1:N
    for x = 1:M
        ee = reshape(e(y, x, :), P, 1);
        S(y, x) = 1./(ee'*R*ee);
    end
end