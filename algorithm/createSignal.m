function signalTotal = createSignal(xPos, yPos, zPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles, amplitudes, nSamples, coherence)
%createSignal - create input signal to an array of microphones
%
%Creates the input signal to an array of microphones based on the position
%in space of the microphones and the arrival angle and amplitude of
%the individual sources
%
%signalTotal = createSignal(xPos, yPos, zPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles, amplitudes, nSamples, coherence)
%
%IN
%xPos               - 1xP vector of x-positions [m]
%yPos               - 1xP vector of y-positions [m]
%zPos               - 1xP vector of z-positions [m]
%f                  - Wave frequency [Hz]
%c                  - Speed of sound in [m/s]
%fs                 - Sampling frequency in [Hz]
%thetaArrivalAngles - 1xM vector of theta arrival angles for sources
%phiArrivalAngles   - 1xM vector of phi arrival angles for sources
%amplitudes         - 1xM vector of amplitudes of sources
%nSamples           - Number of samples to be used in the calculations
%coherence          - Boolean to make input signals coherent or not
%
%OUT
%signalTotal        - PxN matrix of input signal to individual sensors
%
%Created by J?rgen Grythe
%Last updated 2016-12-07

if ~exist('coherence', 'var')
    coherence = false;
    rng('default')
end

if ~exist('nSamples', 'var')
    nSamples = 1e3;
end

if ~exist('amplitudes', 'var')
    amplitudes = zeros(1,numel(xPos));
end

if ~isvector(xPos)
    error('X-positions of array elements must be a 1xP vector where P is number of elements')
end

if ~isvector(yPos)
    error('Y-positions of array elements must be a 1xP vector where P is number of elements')
end

if ~isvector(zPos)
    error('Z-positions of array elements must be a 1xP vector where P is number of elements')
end


T = nSamples/fs;
t = 0:1/fs:T-1/fs;

signalTotal = 0;
for k = 1:numel(thetaArrivalAngles)

    %Create signal hitting the array
    doa = squeeze(steeringVector(xPos, yPos, zPos, f, c, thetaArrivalAngles(k), phiArrivalAngles(k)));
        
    %Add random phase to make signals incoherent
    if coherence
        signal = 10^(amplitudes(k)/20)*doa*exp(1j*2*pi*f*t);
    else
        signal = 10^(amplitudes(k)/20)*doa*exp(1j*2*pi*(f*t+randn(1, nSamples)));
    end
    
    %Total signal equals sum of individual signals
    signalTotal = signalTotal + signal;
      
end
