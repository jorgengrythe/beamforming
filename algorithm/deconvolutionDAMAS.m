function Q = deconvolutionDAMAS(S, e, maxIterations)
%deconvolutionDAMAS - deconvolves the intensity plot with the DAMAS algorithm
%as implemented in "A deconvolution approach for the mapping of acoustic sources
%(DAMAS) determined from phased microphone arrays", Brooks and Humphreys, 2005
%
%Q = deconvolutionDAMAS(S, e, maxIterations)
%
%IN
%S - NxM matrix of delay-and-sum steered response power
%e - NxMxP steering vector/matrix for a certain frequency
%
%OUT
%Q - NxM devonvolved intensity plot
%
%Created by J?rgen Grythe, Squarehead Technology AS
%Last updated 2017-01-27

if ~exist('maxIterations', 'var')
    maxIterations = 100;
end

Y = real(S);

[nPointsY, nPointsX, nMics] = size(e);
N = nPointsY*nPointsX;

%Make the A-matrix
ee = reshape(e, N, nMics);
A = (abs(ee*ee').^2)./nMics^2;

% DAMAS
Q = zeros(size(Y));
Q0 = Y;

deps = 1e-1;
for iteration=1:maxIterations;
    
    for n=1:N
        Q(n) = max(0, Y(n) - A(n, 1:n-1)*Q(1:n-1).' ...
            - A(n, n+1:end)*Q0(n+1:end).');
    end
    
    for n=N:-1:1
        Q(n) = max(0, Y(n) - A(n, 1:n-1)*Q0(1:n-1).' ...
            - A(n,n+1:end)*Q(n+1:end).');
    end
    
    
    dX = (Q - Q0);
    maxd = max(abs(dX(:)))/mean(Q0(:));
    if  maxd < deps
        disp(['Converged after ' num2str(iteration) ' iterations']);
        break;
    end
    Q0 = Q;
end


if iteration == maxIterations
    disp(['Stopped after maximum iterations (' num2str(maxIterations) ')'])
else
    disp(['Converged after ' num2str(iteration) ' iterations'])
end

