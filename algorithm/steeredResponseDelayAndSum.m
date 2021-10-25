function S = steeredResponseDelayAndSum(R, e, w)
%steeredResponseDelayAndSum - calculate delay and sum in frequency domain
%
%Calculates the steered response from the delay-and-sum algorithm in the
%frequency domain based on sensor positions, input signal and scanning angles
%
%S = steeredResponseDelayAndSum(R, e, w)
%
%IN
%R - PxP correlation matrix / cross spectral matrix (CSM)
%e - MxNxP steering vector/matrix for a certain frequency
%w - 1xP vector of element weights
%
%OUT
%S - MxN matrix of delay-and-sum steered response power
%
%Created by J?rgen Grythe
%Last updated 2017-01-31

%M # of y-points, N # of x-points, P number of mics
[M, N, P] = size(e);

%Make the weighting vector a column vector instead of row vector
if isrow(w)
    w = w';
end

%Delay and sum steered response power
S = zeros(M, N);
for y = 1:M
    for x = 1:N
        ee = reshape(e(y, x, :), P, 1);
        S(y, x) = (w.*ee)'*R*(ee.*w);
    end
end



