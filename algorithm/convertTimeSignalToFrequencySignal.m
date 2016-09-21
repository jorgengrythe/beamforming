function [frequencySignal, fc] = convertTimeSignalToFrequencySignal(timeSignal, nFFT, fs)
%convertTimeSignalToFrequencySignal - converts a space-time signal to a 
%space-frequency signal. The frequency resolution is decided by the
%sampling frequency divided by number of FFT points used, i.e. with fs = 
%44.1 kHz and nFFT = 1024, frequency resolution is 1024 bins where each bin
%cover 44.1 kHz / 1024 ~ 43 Hz
%
%convertTimeSignalToComplexSignal(timeSignal, numberOfFFTSamples)
%
%IN
%timeSignal      - MxN matrix of N samples on M microphones
%nFFT            - 1x1 length of FFT to be used and number of bins
%
%OUT
%frequencySignal - M x nFFT matrix of complex signal
%fc              - centre frequency for each bin
%
%Created by J?rgen Grythe, Squarehead Technology AS
%Last updated 2016-09-21

if ~exist('nFFT', 'var')
    nFFT = 1024;
end

[nMics, nSamples] = size(timeSignal);

%Centre frequency for each bin
fc = 0:fs/(2*nFFT):(fs-1)/2;

%We need to iterate over entire time-signal a total of nMics + 1 times to
%calculate a lineary independent space-frequency matrix (the increment
%between time partitions is calculated to get nMics+1 total partitions)
nSamplesInIncrement = floor((nSamples-nFFT)/nMics);

%Pre buffering for speed
frequencySignal = zeros(nMics, nFFT);
k=0;
%Calculate space-frequency signal by iterating over entire signal
for sample = 1:nSamplesInIncrement:nSamples-nFFT
    timeSignalPartition = timeSignal(:, sample:sample+nFFT-1);
    frequencySignal = frequencySignal + fft(timeSignalPartition, nFFT, 2);
    k=k+1;
end


%Normalising
frequencySignal = frequencySignal/(nFFT + nSamples + nMics + 1);

disp(['Iterations: ' num2str(k)])
disp(['Increments: ' num2str(nSamplesInIncrement)])
disp(['% overlap: ' num2str((1-(nSamplesInIncrement/nFFT))*100)])