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


% Scanning frequency (single frequency, narrowband)
f = 4e3;
c = 340; %speed of sound


% Scanning parameters
distance = 3.0;
maxX = 2.0;
maxY = 1.5;
anglRes = 2;

% Deconvolution parameters
loopGain = 0.9;
maxIterations = 50;




%Calculate cross spectral matrix. Since we are beamforming in the frequency
%domain, we need a specific R matrix for each scanning frequency.
K = 100;
nFFT = 128;
R = CSM(timeSignal, f, fs, nFFT, K);

%Get scanning angles and calculate steering vector
[thetaScanAngles, phiScanAngles] = meshgridScanAngles(maxAngleX, maxAngleY, anglRes);
e = steeringVector(Xm, Ym, Zm, f, c, thetaScanAngles, phiScanAngles);




%Calculate delay-and-sum steered power
DAS = steeredResponseDelayAndSum(R, e, Wm);

%Or minimum variance
MV = steeredResponseMinimumVariance(R, e);

%Or functional beamforming
FB = steeredResponseFunctionalBeamforming(R, e);

%Or DAMAS deconvolution
DAMAS = deconvolutionDAMAS(DAS, e, maxIterations);

%Or CLEAN deconvolution
CLEAN = deconvolutionCleanSC(R, e, Wm, loopGain, maxIterations);

%Or CLEAN SC deconvolution
CLEANSC = deconvolutionCleanSC(R, e, Wm, loopGain, maxIterations);