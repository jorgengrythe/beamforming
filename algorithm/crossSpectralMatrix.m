function R = crossSpectralMatrix(inputSignal)
%crossSpectralMatrix - calculate the cross spectral matrix (CSM)
%
%R = crossSpectralMatrix(inputSignal)
%
%IN
%nMics x nSamples matrix of complex signal
%
%OUT
%R - PxP correlation matrix / cross spectral matrix (CSM)

[~, nSamples] = size(inputSignal);

R = inputSignal*inputSignal';
R = R/nSamples;