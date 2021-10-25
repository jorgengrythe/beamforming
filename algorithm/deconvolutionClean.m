function Q = deconvolutionClean(R, e, w, loopGain, maxIterations)
%deconvolutionClean - deconvolves the intensity plot with the clean algorithm
%as implemented in "CLEAN based on spatial source coherence", Pieter Sijtsma, 2007
%
%Q = deconvolutionClean(R, e, w, loopGain)
%
%IN
%R             - PxP cross spectral matrix (CSM)
%e             - MxNxP steering vector/matrix 
%w             - 1xP weighting vector
%loopGain      - 1x1 safety factor, 0 < loopGain < 1
%maxIterations - Maximum number of iterations to create the clean map
%
%OUT
%Q - MxN devonvolved intensity plot
%
%Created by J?rgen Grythe
%Last updated 2017-02-27

%M # of y-points, N # of x-points, P number of mics
[M, N, P] = size(e);

%Make the weighting vector a column vector instead of row vector
if isrow(w)
    w = w';
end

%Maximum number of iterations to create the clean map
if ~exist('maxIterations', 'var')
    maxIterations = 100;
end

%Safety factor that determines how much to remove that correlates with
%strongest source, 0 removes nothing, 1 removes all
if ~exist('loopGain', 'var')
    loopGain = 0.9;
end

%Initialise trimmed cross spectral matrix (CSM) by setting the diagonal to zero
R(logical(eye(P))) = 0;

%Initialise final clean image
cleanMap = zeros(M, N);

%Initialise break criterion
sumOfCSM = sum(sum(abs(R)));
sumOfDegradedCSM = sumOfCSM;


for cleanMapIterations = 1:maxIterations
    
    % -------------------------------------------------------
    % 1. Calculate dirty map
    dirtyMap = zeros(M, N);
    for y = 1:M
        for x = 1:N
            ee = reshape(e(y, x, :), P, 1);
            dirtyMap(y, x) = (w.*ee)'*R*(ee.*w);
        end
    end
    
    
    
    % -------------------------------------------------------
    % 2. Find peak value and its position in dirty map
    [maxPeakValue, maxPeakIndx] = max(dirtyMap(:));
    [maxPeakValueYIndx, maxPeakValueXIndx] = ind2sub(size(dirtyMap), maxPeakIndx);
    
    
    
    % -------------------------------------------------------
    % 3. Calculate the CSM induced by the peak source
    
    % Steering vector to location of peak source
    g = reshape(e(maxPeakValueYIndx, maxPeakValueXIndx, :), P, 1);
    
    % Cross spectral matrix induced by peak source in that direction (eq. 11)
    G = g*g';
    G(logical(eye(P))) = 0;
    
    
    
    % -------------------------------------------------------
    % 4. New updated map with clean beam from peak source location
    % Clean beam with specified width and max value of 1
    PmaxCleanBeam = zeros(M, N);
    PmaxCleanBeam(maxPeakValueYIndx, maxPeakValueXIndx) = 1;
    
    % Update clean map with clean beam from peak source location
    cleanMap = cleanMap + loopGain*maxPeakValue*PmaxCleanBeam;
    
    
    
    % -------------------------------------------------------
    % 5. Calculate degraded cross spectral matrix
    % Basically removing the PSF from that location of the plot
    R = R - loopGain*maxPeakValue*G;
    R(logical(eye(P))) = 0;
    
    % Stop the iteration if the degraded CSM contains more information than
    % in the previous iteration
    sumOfCSM = sum(sum(abs(R)));
    if sumOfCSM > sumOfDegradedCSM
        break;
    end
    sumOfDegradedCSM = sumOfCSM;
    
    
end

if cleanMapIterations == maxIterations
    disp(['Stopped after maximum iterations (' num2str(maxIterations) ')'])
else
    disp(['Converged after ' num2str(cleanMapIterations) ' iterations'])
end

% 6. Source plot is written as summation of clean beams and remaining dirty map
Q = cleanMap + dirtyMap;



end
