function Q = deconvolutionDAMAS(S, e, maxIterations)
%deconvolutionDAMAS - deconvolves the intensity plot with the DAMAS algorithm
%as implemented in "A deconvolution approach for the mapping of acoustic sources
%(DAMAS) determined from phased microphone arrays", Brooks and Humphreys, 2005
%
%Q = deconvolutionDAMAS(S, e, maxIterations)
%
%IN
%S - MxN matrix of delay-and-sum steered response power
%e - MxNxP steering vector/matrix for a certain frequency
%
%OUT
%Q - MxN devonvolved intensity plot
%
%Created by J?rgen Grythe
%Last updated 2017-02-27

if ~exist('maxIterations', 'var')
    maxIterations = 100;
end

Y = real(S);
deps = 0.1;

%M # of y-points, N # of x-points, P number of mics
[M, N, P] = size(e);

%Make the A-matrix square size NxM x NxM x P
ee = reshape(e, M*N, P);
A = (abs(ee*ee').^2)./P^2;

%Initialise final source powers Q
Q = zeros(size(Y));
Q0 = Y;


%Solve the system Y = AQ for Q by Gauss-Seidel iteration where Y is the
%original delay-and-sum plot we want to deconvolve, and Q are the true
%source powers
for i=1:maxIterations;
    
    %Gauss-Seidel iteration. If the solution is negative set it to zero (to
    %ensure that we only have positive and not negative power)
    for n=1:M*N
        Q(n) = max(0, Y(n) - A(n, 1:n-1)*Q(1:n-1)' ...
            - A(n, n+1:end)*Q0(n+1:end)');
    end

    %Break criterion for convergence
    dX = (Q - Q0);
    maxd = max(abs(dX(:)))/mean(Q0(:));
    
    if  maxd < deps
        break;
    end
    
    Q0 = Q;
end


if i == maxIterations
    disp(['Stopped after maximum iterations (' num2str(maxIterations) ')'])
else
    disp(['Converged after ' num2str(i) ' iterations'])
end

