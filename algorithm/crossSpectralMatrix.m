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
%
%Created by J?rgen Grythe, Squarehead Technology AS
%Last updated 2016-12-07

[~, nSamples] = size(inputSignal);

R = inputSignal*inputSignal';
R = R/nSamples;