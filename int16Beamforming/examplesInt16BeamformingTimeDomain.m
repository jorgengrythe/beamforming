clear all;
clc

% File folder and name of int16 input signal
int16FileFolder = '/Users/';
int16FileName = 'inputsignal';

fileName = [int16FileFolder int16FileName '.int16'];

nMics = 128; % # mics in array
fs = 44.1e3; %sampling rate

data = readInt16(nMics, fs, 0, fileName);

% Get microphone positions
%Here the microphone positions needs to be loaded. That is mic #1
%corresponds to the first row in the timeSignal matrix, mic #2 to the
%second row and so on
Xm = zeros(1, nMics);
Ym = zeros(1, nMics);
Zm = zeros(1, nMics);
Wm = ones(1, numel(Xm))/numel(Xm);


% Scanning range (multiple frequencies, broadband)
fmin = 3e3;
fmax = 5e3;
c = 340; %speed of sound

t_start = 0.0;
T = 0.035; %time weighting
block = T*fs;

% Scanning parameters
distance = 2.0; %distance to source
maxX = 1; %max scanning extent x
maxY = 1; %max scanning extent y
deltaX = 0; %offset scanning grid
deltaY = 0; %offset scanning grid
anglRes = 1; %angle resolution
filterFrequencies = [fmin, fmax];


tic
[anglex,angley, pow] = sweepPow2(Xm, Ym, Zm, Wm, data(:, (t_start*fs)+1:end), fs, filterFrequencies, distance, maxX, maxY, anglRes, block, deltaX, deltaY);
toc

figure;
imagesc(angley, anglex, db(pow'))
