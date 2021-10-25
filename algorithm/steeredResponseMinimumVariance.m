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
%e - MxNxP steering vector/matrix for a certain frequency
%
%OUT
%S - MxN matrix of minimum variance steered response power
%
%Created by J?rgen Grythe
%Last updated 2017-02-27

%M # of y-points, N # of x-points, P number of mics
[M, N, P] = size(e);

%Cross spectral matrix with diagonal loading
R = R + trace(R)/(P^2)*eye(P, P);
R = R/P;
R = inv(R);

%Minimum variance steered response power
S = zeros(M, N);
for y = 1:M
    for x = 1:N
        ee = reshape(e(y, x, :), P, 1);
        S(y, x) = 1./(ee'*R*ee);
    end
end
