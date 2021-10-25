function S = steeredResponseFunctionalBeamforming(R, e, mapOrder)
%steeredResponseFunctionalBeamforming - calculate functional beamforming
%
%Calculates the steered response from the functional beamforming algorithm
%
%S = steeredResponseFunctionalBeamforming(R, e, mapOrder)
%
%IN
%R        - PxP correlation matrix / cross spectral matrix (CSM)
%e        - MxNxP steering vector/matrix for a certain frequency
%mapOrder - map order, typical values 20-300
%
%OUT
%S        - MxN matrix of Functional Beamforming steered response power
%
%Created by J?rgen Grythe
%Last updated 2017-02-27

if ~exist('mapOrder', 'var')
    mapOrder = 20;
end

%N # of y-points, M # of x-points, P number of mics
[M, N, P] = size(e);

%Functional beamforming steered response power
S = zeros(M, N);
for y = 1:M
    for x = 1:N
        ee = reshape(e(y, x, :), P, 1);
        S(y, x) = (ee'*R^(1/mapOrder)*ee)^mapOrder;
    end
end
