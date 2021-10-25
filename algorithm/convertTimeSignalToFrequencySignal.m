function [frequencySignal, fc] = convertTimeSignalToFrequencySignal(timeSignal, nFFT, fs)
%convertTimeSignalToFrequencySignal - converts a space-time signal to a 
%space-frequency signal. The frequency resolution is decided by the
%sampling frequency divided by number of FFT points used, i.e. with fs = 
%44.1 kHz and nFFT = 1024, frequency resolution is 1024 bins where each bin
%cover 44.1 kHz / 1024 / 2 ~ 21.5 Hz
%
%convertTimeSignalToFrequencySignal(timeSignal, nFFT, fs)
%
%IN
%timeSignal      - MxN matrix of N samples on M microphones
%nFFT            - 1x1 length of FFT to be used and number of bins
%
%OUT
%frequencySignal - M x nFFT matrix of complex signal
%fc              - centre frequency for each bin
%
%Created by J?rgen Grythe
%Last updated 2017-10-30

if ~exist('nFFT', 'var')
    nFFT = 1024;
end

[nMics, nSamples] = size(timeSignal);

%Centre frequency for each bin
fc = (0:fs/(2*nFFT):(fs-1)/2) + fs/(2*nFFT);

%We need to iterate over entire time-signal a total of nMics + 1 times
nSamplesInIncrement = floor((nSamples-nFFT)/nMics);
if nSamplesInIncrement > nFFT
    nSamplesInIncrement = nFFT;
end

%Pre buffering for speed
frequencySignal = zeros(nMics, nFFT);
k=0;

%Calculate space-frequency signal by iterating over entire signal
for sample = 1:nSamplesInIncrement:nSamples-nFFT
    
    %Take a slice of the signal nFFT samples long
    timeSlice = timeSignal(:, sample:sample+nFFT-1);
    
    %Calculate the FFT of the signal slice. The FFT operates from -fs/2 to
    %fs/2, but we want the final matrix to be MxnFFT where the frequency
    %goes from 0 to fs, so double the FFT size and keep half the samples of
    %of the symmetrical part of the FFT
    frequencySlice = fft(timeSlice, 2*nFFT, 2);
    frequencySignal = frequencySignal + 2*frequencySlice(:, 1:nFFT);
    k=k+1;
end


%Normalising
frequencySignal = frequencySignal/(nFFT + nSamples + nMics + 1);

disp(['Iterations: ' num2str(k)])
disp(['Increments: ' num2str(nSamplesInIncrement)])
disp(['% overlap: ' num2str((1-(nSamplesInIncrement/nFFT))*100)])
