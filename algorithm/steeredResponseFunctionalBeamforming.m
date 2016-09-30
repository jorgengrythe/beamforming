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
%Last updated 2016-09-30

if ~exist('mapOrder', 'var')
    mapOrder = 20;
end

[nPointsY, nPointsX, nMics] = size(e);

%Functional beamforming steered response power
S = zeros(nPointsY, nPointsX);
for pointY = 1:nPointsY
    for pointX = 1:nPointsX
        ee = reshape(e(pointY, pointX, :), nMics, 1);
        S(pointY, pointX) = (ee'*R^(1/mapOrder)*ee)^mapOrder;
    end
end