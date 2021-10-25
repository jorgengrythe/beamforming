function R = CSM(inputMatrix, f, fs, nFFT, K)
%CSM - calculate the cross spectral matrix
%
%Calculates the cross spectral matrix (CSM) of a time signal for a specific
%frequency.
%
%R = CSM(inputMatrix, f, fs, nFFT, K)
%
%IN
%inputMatrix - MxN matrix of time data consisting of M sensors and N samples
%f           - beamforming frequency
%fs          - sampling frequency
%nFFT        - number of points for the FFT
%K           - number of snapshots to compute FFT over
%
%OUT
%R           - the cross spectral matrix for a frequency f
%
%
%Created by Jørgen Grythe
%Last updated 2018-05-23

if ~exist('K', 'var')
    K = 100;
end

if ~exist('nFFT', 'var')
    nFFT = 128;
end

[M, N] = size(inputMatrix);

if nFFT*K > N
    error(['The FFT length (' num2str(nFFT) ') times number of snapshots (' num2str(K) ') exceeds the number of samples (' num2str(N) ') in the input signal. Either choose smaller FFT lengt, fewer snapshots, or use an input signal with more samples'])
end

%Reshape the inputMatrix to a M*nFFT*K matrix
y = double(reshape(inputMatrix(:, 1:(nFFT*K)), M, nFFT, K))/fs;

%Calculate the fft along the fft dimension to get an MxMxK matrix
X = fft(y, [], 2) / sqrt(nFFT);

%%Concatenate positive and negative frequencies to make frequency array
fftfreq = (fs/nFFT) * ([0:(nFFT/2-1) -(nFFT/2):-1]);

%Find frequency closest to beamforming frequency f
[~, fi] = min(abs(f - fftfreq));

%Pick out single frequency to get M*K matrix
Xfi = squeeze(X(:, fi, :));

%Calculate the CSM for the frequency f
R = Xfi * Xfi' / K;
