function S = steeredResponseFunctionalBeamforming(R, e, mapOrder)
%steeredResponseFunctionalBeamforming - calculate functional beamforming
%
%Calculates the steered response from the functional beamforming algorithm
%
%S = steeredResponseFunctionalBeamforming(R, e, mapOrder)
%
%IN
%R        - PxP correlation matrix / cross spectral matrix (CSM)
%e        - NxMxP steering vector/matrix for a certain frequency
%mapOrder - map order, typical values 20-300
%
%OUT
%S        - NxM matrix of Functional Beamforming steered response power
%
%Created by J?rgen Grythe, Squarehead Technology AS
%Last updated 2017-01-31

if ~exist('mapOrder', 'var')
    mapOrder = 20;
end

%N # of y-points, M # of x-points, P number of mics
[N, M, P] = size(e);

%Functional beamforming steered response power
S = zeros(N, M);
for y = 1:N
    for x = 1:M
        ee = reshape(e(y, x, :), P, 1);
        S(y, x) = (ee'*R^(1/mapOrder)*ee)^mapOrder;
    end
end