%% Examples on delay-and-sum response for different arrays and input signals


%% 1D-array case
clear all

% Create vectors of x- and y-coordinates of microphone positions 
xPos = -1:0.2:1; % 1xP vector of x-positions in meters
yPos = zeros(1, numel(xPos)); % 1xP vector of y-positions in meters
w = ones(1, numel(xPos))/numel(xPos); % 1xP vector of weightings

% Define arriving angles and frequency of input signals
thetaArrivalAngles = [-30 10]; % degrees
phiArrivalAngles = [0 0]; % degrees
f = 800; % Hz
c = 340; % m/s
fs = 44.1e3; % Hz

% Define array scanning angles (1D, so phi = 0)
thetaScanAngles = -90:0.1:90; % degrees
phiScanAngles = 0; % degrees


% Create input signal
inputSignal = createSignal(xPos, yPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles);

% Create steering vector/matrix
e = steeringVector(xPos, yPos, f, c, thetaScanAngles, phiScanAngles);

% Create cross spectral matrix
R = crossSpectralMatrix(inputSignal);

% Calculate delay-and-sum steered response
S = steeredResponseDelayAndSum(R, e, w);

%Normalise spectrum
spectrumNormalized = abs(S)/max(abs(S));

%Convert to decibel
spectrumLog = 10*log10(spectrumNormalized);

%Plot steered response
figure(1);clf
plot(thetaScanAngles, spectrumLog)
grid on
xlim([thetaScanAngles(1) thetaScanAngles(end)])

yL = get(gca,'YLim');
for j=1:numel(thetaArrivalAngles)
    indx = find(thetaScanAngles >= thetaArrivalAngles(j), 1);
    line([thetaScanAngles(indx) thetaScanAngles(indx)], yL, ...
        'LineWidth', 1, 'Color', 'r', 'LineStyle', '--');
end
xlabel('\theta')
ylabel('dB')

%% 1D-array case different source strengths

%Relative amplitude difference in decibel
amplitudes = [0 -5];

% Create input signal
inputSignal = createSignal(xPos, yPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles, amplitudes);

% Input signal is changed so update cross spectral matrix
R = crossSpectralMatrix(inputSignal);

% Calculate delay-and-sum steered response
S = steeredResponseDelayAndSum(R, e, w);

%Normalise spectrum
spectrumNormalized = abs(S)/max(abs(S));

%Convert to decibel
spectrumLog = 10*log10(spectrumNormalized);

%Plot steered response
figure(2)
plot(thetaScanAngles,spectrumLog)
grid on
xlim([thetaScanAngles(1) thetaScanAngles(end)])

yL = get(gca,'YLim');
for j=1:numel(thetaArrivalAngles)
    indx = find(thetaScanAngles >= thetaArrivalAngles(j), 1);
    line([thetaScanAngles(indx) thetaScanAngles(indx)], yL, ...
        'LineWidth', 1, 'Color', 'r', 'LineStyle', '--');
end
xlabel('\theta')
ylabel('dB')


%% 2D-array case, spectrum in linear scale in UV-space

% Position of sensors and weighting of 2D array
% Create circular array
nElements = 20;
radius = 0.6;

[xPos, yPos] = pol2cart((0:1/nElements:1-1/nElements)*2*pi, ones(1,nElements)*radius);
w = ones(1,numel(xPos))/numel(xPos);

% Define arriving angles of input signals
thetaArrivalAngles = [30 20 30];
phiArrivalAngles = [10 70 210];

% Define array scanning angles
thetaScanAngles = -90:0.5:90;
phiScanAngles = 0:1:180;

% Create input signal
inputSignal = createSignal(xPos, yPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles);

% Update steering vector and also save UV-space coordinates
[e, u, v] = steeringVector(xPos, yPos, f, c, thetaScanAngles, phiScanAngles);

% Update cross spectral matrix
R = crossSpectralMatrix(inputSignal);

% Calculate delay-and-sum steered response
S = steeredResponseDelayAndSum(R, e, w);

%Normalise spectrum
spectrumNormalized = abs(S)/max(max(abs(S)));

%Plot steered response in UV-space
figure(3)
surf(u, v, spectrumNormalized, 'edgecolor', 'none', 'FaceAlpha', 0.8)
view(0, 90)
axis square

%Do some magic to make the figure look nice
set(gcf, 'color','k')
cmap = colormap;
cmap(1,:) = [1 1 1]*0.2;
colormap(cmap);
set(gca, 'color', [0 0 0], 'xcolor', [1 1 1], 'ycolor', [1 1 1], 'zcolor', [1 1 1])
set(gca, 'XTickLabel', [], 'YTickLabel', [], 'ZTickLabel', [])
set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on', 'ZMinorGrid', 'on', 'MinorGridColor', [1 1 1], 'MinorGridLineStyle', '-')
xlabel('u = sin(\theta)cos(\phi)')
ylabel('v = sin(\theta)sin(\phi)')

%% 2D-array case, different source strengths, spectrum in linear scale in UV-space

%Relative amplitude difference between sources in decibel,
%could also have written amplitudes = [3 1 0]
amplitudes = [0 -2 -3];

% Create input signal
inputSignal = createSignal(xPos, yPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles, amplitudes);

% Update cross spectral matrix (same scanning angles so steering vector is the same)
R = crossSpectralMatrix(inputSignal);

% Calculate delay-and-sum steered response
S = steeredResponseDelayAndSum(R, e, w);

%Normalise spectrum
spectrumNormalized = abs(S)/max(max(abs(S)));

% Plot the steered response
figure(4);clf
surf(u, v, spectrumNormalized, 'edgecolor', 'none', 'FaceAlpha', 0.8)
view(0, 90)
axis square

%Do some magic to make the figure look nice
set(gcf, 'color','k')
cmap = colormap;
cmap(1,:) = [1 1 1]*0.2;
colormap(cmap);
set(gca, 'color', [0 0 0], 'xcolor', [1 1 1], 'ycolor', [1 1 1], 'zcolor', [1 1 1])
set(gca, 'XTickLabel', [], 'YTickLabel', [], 'ZTickLabel', [])
set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on', 'ZMinorGrid', 'on', 'MinorGridColor', [1 1 1], 'MinorGridLineStyle', '-')
xlabel('u = sin(\theta)cos(\phi)')
ylabel('v = sin(\theta)sin(\phi)')

%% 2D-array case, different source strengths, spectrum in logarithmic scale in UV-space

%Convert the delay-and-sum steered response to decibel
spectrumLog = 10*log10(spectrumNormalized);

% Plot the steered response
figure(5);clf
surf(u, v, spectrumLog, 'edgecolor', 'none', 'FaceAlpha', 0.8)
view(0, 90)
axis square

%Do some magic to make the figure look nice
set(gcf, 'color','k')
cmap = colormap;
cmap(1,:) = [1 1 1]*0.2;
colormap(cmap);
set(gca, 'color', [0 0 0], 'xcolor', [1 1 1], 'ycolor', [1 1 1], 'zcolor', [1 1 1])
set(gca, 'XTickLabel', [], 'YTickLabel', [], 'ZTickLabel', [])
set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on', 'ZMinorGrid', 'on', 'MinorGridColor', [1 1 1], 'MinorGridLineStyle', '-')
xlabel('u = sin(\theta)cos(\phi)')
ylabel('v = sin(\theta)sin(\phi)')

%% 2D-array case, different source strengths, spectrum in logarithmic scale with dynamic range in UV-space

%Dynamic range in decibels
dynamicRange = 6;

% Plot the steered response
figure(6);clf
surf(u, v, spectrumLog, 'edgecolor', 'none', 'FaceAlpha', 0.8)
view(0, 90)
axis square

%Do some magic to make the figure look nice
set(gcf, 'color','k')
cmap = colormap;
cmap(1,:) = [1 1 1]*0.2;
colormap(cmap);
set(gca, 'color', [0 0 0], 'xcolor', [1 1 1], 'ycolor', [1 1 1], 'zcolor', [1 1 1])
set(gca, 'XTickLabel', [], 'YTickLabel', [], 'ZTickLabel', [])
set(gca, 'XMinorGrid', 'on', 'YMinorGrid', 'on', 'ZMinorGrid', 'on', 'MinorGridColor', [1 1 1], 'MinorGridLineStyle', '-')
xlabel('u = sin(\theta)cos(\phi)')
ylabel('v = sin(\theta)sin(\phi)')

%Set the dynamic range
caxis([-dynamicRange 0])

%% 2D-array case, different source strengths, use plotSteeredResponseUV function

%Max range in decibels
maxDynamicRange = 30;

%The function interpolates the result, so can use fewer scanning
%angles/points
thetaScanAngles = -90:2:90;
phiScanAngles = 0:2:180;

%Changed scanning angles so update steering vector (input signal is the
%same so we can keep R as before)
[e, u, v] = steeringVector(xPos, yPos, f, c, thetaScanAngles, phiScanAngles);

% Calculate delay-and-sum steered response
S = steeredResponseDelayAndSum(R, e, w);

%Plot the steered response, no need to normalise the
%spectrum or converting to decibel before input
plotSteeredResponseUV(S, u, v, maxDynamicRange, 'log', 'black', '2D')



%% 2D-array case, scanning plane in cartesian coordinates

%Define scanning grid
distanceToScanningPlane = 1.8; %[m]
maxScanningPlaneExtentX = 2;    %[m];
maxScanningPlaneExtentY = 1.5;  %[m];
numberOfScanningPointsX = 40;
numberOfScanningPointsY = 30;

%Define sources
xPosSource = [-1 0 1];
yPosSource = [-0.5 0.75 0.25];
zPosSource = ones(1, numel(xPosSource))*distanceToScanningPlane;
amplitudes = [-3 -2 0];

%Create scanning points
scanningAxisX = -maxScanningPlaneExtentX:2*maxScanningPlaneExtentX/(numberOfScanningPointsX-1):maxScanningPlaneExtentX;
scanningAxisY = -maxScanningPlaneExtentY:2*maxScanningPlaneExtentY/(numberOfScanningPointsY-1):maxScanningPlaneExtentY;
[scanningPointsX, scanningPointsY] = meshgrid(scanningAxisX, scanningAxisY);

%Get angles to scanning points and source positions
[thetaScanAngles, phiScanAngles] = convertCartesianToPolar(scanningPointsX, scanningPointsY, distanceToScanningPlane);
[thetaArrivalAngles, phiArrivalAngles] = convertCartesianToPolar(xPosSource, yPosSource, zPosSource);

% Create input signal
inputSignal = createSignal(xPos, yPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles, amplitudes);

%Calculate steering vector
[e, u, v] = steeringVector(xPos, yPos, f, c, thetaScanAngles, phiScanAngles);

%Calculate cross spectral matrix
R = crossSpectralMatrix(inputSignal);

% Calculate delay-and-sum steered response
S = steeredResponseDelayAndSum(R, e, w);

%Plot the steered response in cartesian coordinate system rather than UV
interpolationFactor = 2; %interpolate for higher resolution, 0 equals original
plotSteeredResponseXY(S, scanningPointsX, scanningPointsY, interpolationFactor)
