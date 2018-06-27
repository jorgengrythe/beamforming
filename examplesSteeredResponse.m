%% Examples on delay-and-sum response for different arrays and input signals


%% 1D-array case

% Create vectors of x- and y-coordinates of microphone positions 
xPos = -0.8:0.2:0.8; % 1xP vector of x-positions [m]
yPos = zeros(1, numel(xPos)); % 1xP vector of y-positions [m]
zPos = zeros(1, numel(xPos));
elementWeights = ones(1, numel(xPos))/numel(xPos); % 1xP vector of weightings

% Define arriving angles and frequency of input signals
thetaArrivalAngles = [-30 10]; % degrees
phiArrivalAngles = [0 0]; % degrees
f = 800; % [Hz]
c = 340; % [m/s]
fs = 44.1e3; % [Hz]

% Define array scanning angles (1D, so phi = 0)
thetaScanAngles = -90:0.1:90; % degrees
phiScanAngles = 0; % degrees


% Create input signal
inputSignal = createSignal(xPos, yPos, zPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles);

% Create steering vector/matrix
e = steeringVector(xPos, yPos, zPos, f, c, thetaScanAngles, phiScanAngles);

% Create cross spectral matrix
R = inputSignal*inputSignal';

% Calculate delay-and-sum steered response
S = steeredResponseDelayAndSum(R, e, elementWeights);

%Normalise spectrum
spectrumNormalized = abs(S)/max(abs(S));

%Convert to decibel
spectrumLog = 10*log10(spectrumNormalized);


%Plot array
fig1 = figure;
fig1.Color = 'w';
ax = axes('Parent', fig1);
scatter(ax, xPos, yPos, 20, 'filled')
axis(ax, 'square')
ax.XLim = [-1 1];
ax.YLim = [-1 1];
grid(ax, 'on')
title(ax, 'Microphone positions')

%Plot steered response with indicator lines
fig2 = figure;
fig2.Color = 'w';
ax = axes('Parent', fig2);
plot(ax, thetaScanAngles, spectrumLog)
grid(ax, 'on')
ax.XLim = [thetaScanAngles(1) thetaScanAngles(end)];

for j=1:numel(thetaArrivalAngles)
    indx = find(thetaScanAngles >= thetaArrivalAngles(j), 1);
    line(ax, [thetaScanAngles(indx) thetaScanAngles(indx)], ax.YLim, ...
        'LineWidth', 1, 'Color', 'r', 'LineStyle', '--');
end
xlabel(ax, '\theta')
ylabel(ax, 'dB')

%% 1D-array case different source strengths

%Relative amplitude difference in decibel
amplitudes = [0 -5];

% Create input signal
inputSignal = createSignal(xPos, yPos, zPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles, amplitudes);

% Input signal is changed so update cross spectral matrix
R = inputSignal*inputSignal';

% Calculate delay-and-sum steered response, steering vector/matrix is same as before
S = steeredResponseDelayAndSum(R, e, elementWeights);

%Normalise spectrum
spectrumNormalized = abs(S)/max(abs(S));

%Convert to decibel
spectrumLog = 10*log10(spectrumNormalized);


%Plot steered response with indicator lines
fig3 = figure;
fig3.Color = 'w';
ax = axes('Parent', fig3);
plot(ax, thetaScanAngles, spectrumLog)
grid(ax, 'on')
ax.XLim = [thetaScanAngles(1) thetaScanAngles(end)];

for j=1:numel(thetaArrivalAngles)
    indx = find(thetaScanAngles >= thetaArrivalAngles(j), 1);
    line(ax, [thetaScanAngles(indx) thetaScanAngles(indx)], ax.YLim, ...
        'LineWidth', 1, 'Color', 'r', 'LineStyle', '--');
end
xlabel(ax, '\theta')
ylabel(ax, 'dB')


%% 2D-array case, spectrum in linear scale in UV-space

% Position of sensors and weighting of 2D array
% Create circular array
nElements = 20;
radius = 0.6;

[xPos, yPos] = pol2cart((0:1/nElements:1-1/nElements)*2*pi, ones(1,nElements)*radius);
zPos = zeros(1, numel(xPos));
elementWeights = ones(1,numel(xPos))/numel(xPos);

% Define arriving angles of input signals
thetaArrivalAngles = [30 20 30];
phiArrivalAngles = [10 70 210];

% Define array scanning angles
thetaScanAngles = -90:0.5:90;
phiScanAngles = 0:1:180;

% Create input signal
inputSignal = createSignal(xPos, yPos, zPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles);

% Update steering vector and also save UV-space coordinates
[e, u, v] = steeringVector(xPos, yPos, zPos, f, c, thetaScanAngles, phiScanAngles);

% Update cross spectral matrix
R = inputSignal*inputSignal';

% Calculate delay-and-sum steered response
S = steeredResponseDelayAndSum(R, e, elementWeights);

%Normalise spectrum
spectrumNormalized = abs(S)/max(max(abs(S)));


%Plot array
fig3 = figure;
fig3.Color = 'w';
ax = axes('Parent', fig3);
scatter(ax, xPos, yPos, 20, 'filled')
axis(ax, 'square')
ax.XLim = [-1 1];
ax.YLim = [-1 1];
grid(ax, 'on')
title(ax, 'Microphone positions')

%Plot steered response in UV-space
fig4 = figure;
ax = axes('Parent', fig4);
surf(ax, u, v, spectrumNormalized, 'edgecolor', 'none', 'FaceAlpha', 0.8)

%Do some magic to make the figure look nice (black theme)
fig4.Color = 'k';
ax.Color = 'k';
cmap = colormap;
cmap(1,:) = [1 1 1]*0.2;
colormap(ax, cmap);
view(ax, 0, 90)
axis(ax, 'square')
ax.XColor = 'w';
ax.YColor = 'w';
ax.ZColor = 'w';
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.ZTickLabel = [];
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';
ax.ZMinorGrid = 'on';
ax.MinorGridColor = 'w';
ax.MinorGridLineStyle = '-';
xlabel(ax, 'u = sin(\theta)cos(\phi)')
ylabel(ax, 'v = sin(\theta)sin(\phi)')

%% 2D-array case, different source strengths, spectrum in linear scale in UV-space

%Relative amplitude difference between sources in decibel,
%could also have written amplitudes = [3 1 0]
amplitudes = [0 -2 -3];

% Create input signal
inputSignal = createSignal(xPos, yPos, zPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles, amplitudes);

% Update cross spectral matrix (same scanning angles so steering vector is the same)
R = inputSignal*inputSignal';

% Calculate delay-and-sum steered response
S = steeredResponseDelayAndSum(R, e, elementWeights);

%Normalise spectrum
spectrumNormalized = abs(S)/max(max(abs(S)));

%Plot steered response in UV-space
fig5 = figure;
ax = axes('Parent', fig5);
surf(ax, u, v, spectrumNormalized, 'edgecolor', 'none', 'FaceAlpha', 0.8)

%Do some magic to make the figure look nice (black theme)
fig5.Color = 'k';
ax.Color = 'k';
cmap = colormap;
cmap(1,:) = [1 1 1]*0.2;
colormap(ax, cmap);
view(ax, 0, 90)
axis(ax, 'square')
ax.XColor = 'w';
ax.YColor = 'w';
ax.ZColor = 'w';
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.ZTickLabel = [];
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';
ax.ZMinorGrid = 'on';
ax.MinorGridColor = 'w';
ax.MinorGridLineStyle = '-';
xlabel(ax, 'u = sin(\theta)cos(\phi)')
ylabel(ax, 'v = sin(\theta)sin(\phi)')

%% 2D-array case, different source strengths, spectrum in logarithmic scale in UV-space

%Convert the delay-and-sum steered response to decibel
spectrumLog = 10*log10(spectrumNormalized);


%Plot steered response in UV-space
fig6 = figure;
ax = axes('Parent', fig6);
surf(ax, u, v, spectrumLog, 'edgecolor', 'none', 'FaceAlpha', 0.8)

%Do some magic to make the figure look nice (black theme)
fig6.Color = 'k';
ax.Color = 'k';
cmap = colormap;
cmap(1,:) = [1 1 1]*0.2;
colormap(ax, cmap);
view(ax, 0, 90)
axis(ax, 'square')
ax.XColor = 'w';
ax.YColor = 'w';
ax.ZColor = 'w';
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.ZTickLabel = [];
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';
ax.ZMinorGrid = 'on';
ax.MinorGridColor = 'w';
ax.MinorGridLineStyle = '-';
xlabel(ax, 'u = sin(\theta)cos(\phi)')
ylabel(ax, 'v = sin(\theta)sin(\phi)')

%% 2D-array case, different source strengths, spectrum in logarithmic scale with dynamic range in UV-space

%Dynamic range in decibels
dynamicRange = 6;


%Plot steered response in UV-space
fig7 = figure;
ax = axes('Parent', fig7);
surf(ax, u, v, spectrumLog, 'edgecolor', 'none', 'FaceAlpha', 0.8)

%Do some magic to make the figure look nice (black theme)
fig7.Color = 'k';
ax.Color = 'k';
cmap = colormap;
cmap(1,:) = [1 1 1]*0.2;
colormap(ax, cmap);
view(ax, 0, 90)
axis(ax, 'square')
ax.XColor = 'w';
ax.YColor = 'w';
ax.ZColor = 'w';
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.ZTickLabel = [];
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';
ax.ZMinorGrid = 'on';
ax.MinorGridColor = 'w';
ax.MinorGridLineStyle = '-';
xlabel(ax, 'u = sin(\theta)cos(\phi)')
ylabel(ax, 'v = sin(\theta)sin(\phi)')

%Set the dynamic range
caxis(ax, [-dynamicRange 0])

%% 2D-array case, different source strengths, use plotSteeredResponseUV function


%The function interpolates the result, so can use fewer scanning
%angles/points
thetaScanAngles = -90:2:90;
phiScanAngles = 0:2:180;

%Changed scanning angles so update steering vector (input signal is the
%same so we can keep R as before)
[e, u, v, w] = steeringVector(xPos, yPos, zPos, f, c, thetaScanAngles, phiScanAngles);

% Calculate delay-and-sum steered response
S = steeredResponseDelayAndSum(R, e, elementWeights);

%Plot the steered response, no need to normalise the
%spectrum or converting to decibel before input

plotSteeredResponseUV(S, u, v, w, 'uv', 'log', 'black', '2D')

%% 2D-array case, scanning plane in cartesian coordinates

%Define scanning grid
distanceToScanningPlane = 1.8; %[m]
maxScanningPlaneExtentX = 2;    %[m];
maxScanningPlaneExtentY = 1.5;  %[m];
numberOfScanningPointsX = 15;
numberOfScanningPointsY = 10;

%Define sources
xPosSource = [-1 0 1];
yPosSource = [-0.5 0.75 0.25];
zPosSource = ones(1, numel(xPosSource))*distanceToScanningPlane;
amplitudes = [0 -1 -2];

%Create scanning points
scanningAxisX = -maxScanningPlaneExtentX:2*maxScanningPlaneExtentX/(numberOfScanningPointsX-1):maxScanningPlaneExtentX;
scanningAxisY = -maxScanningPlaneExtentY:2*maxScanningPlaneExtentY/(numberOfScanningPointsY-1):maxScanningPlaneExtentY;
[scanningPointsX, scanningPointsY] = meshgrid(scanningAxisX, scanningAxisY);

%Get angles to scanning points and source positions
[thetaScanAngles, phiScanAngles] = convertCartesianToSpherical(scanningPointsX, scanningPointsY, distanceToScanningPlane);
[thetaArrivalAngles, phiArrivalAngles] = convertCartesianToSpherical(xPosSource, yPosSource, zPosSource);

% Create input signal
inputSignal = createSignal(xPos, yPos, zPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles, amplitudes);

%Calculate steering vector
[e, u, v, w] = steeringVector(xPos, yPos, zPos, f, c, thetaScanAngles, phiScanAngles);

%Calculate cross spectral matrix
R = inputSignal*inputSignal';

% Calculate delay-and-sum steered response
S = steeredResponseDelayAndSum(R, e, elementWeights);


%Plot the steered response in cartesian coordinate system rather than UV
interpolationFactor = 1; %interpolate for higher resolution, 0 equals original
plotSteeredResponseXY(S, scanningPointsX, scanningPointsY, interpolationFactor)

%See the scanning grid and calculated points in UV-space as well
%plotSteeredResponseUV(S, u, v, w, 'uv', 'log', 'white', '2D')

%% 3D-array case

% Position of sensors and weighting of 3D array
% Create spherical array
[xPos, yPos, zPos] = sphere(9);
xPos = xPos(:);
yPos = yPos(:);
zPos = zPos(:);
elementWeights = ones(1, numel(xPos))/numel(xPos);

% Define arriving angles of input signals
thetaArrivalAngles = [0 45 100];
phiArrivalAngles = [0 -60 -30];

% Define array scanning angles
thetaScanAngles = 0:1:360;
phiScanAngles = 0:2:180;

%Source frequency
f = 600; % [Hz]

%Default dynamic range [dB]
dynamicRange = 6;

% Create input signal
inputSignal = createSignal(xPos, yPos, zPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles);

% Update steering vector and also save UV-space coordinates
[e, u, v, w] = steeringVector(xPos, yPos, zPos, f, c, thetaScanAngles, phiScanAngles);

% Update cross spectral matrix
R = inputSignal*inputSignal';

% Calculate delay-and-sum steered response
S = steeredResponseDelayAndSum(R, e, elementWeights);

%Normalise and convert to decibel spectrum
spectrumNormalized = abs(S)/max(max(abs(S)));

%Convert the delay-and-sum steered response to decibel
spectrumLog = 10*log10(spectrumNormalized);


% Plot array geometry
fig8 = figure;
fig8.Color = 'w';
ax = axes('Parent', fig8);
scatter3(ax, xPos, yPos, zPos, 20, 'filled')
axis(ax, 'square')
ax.XLim = [-1 1];
ax.YLim = [-1 1];
ax.ZLim = [-1 1];
grid(ax, 'on')
title(ax, 'Microphone positions')

%Plot steered response in UVW-space
fig9 = figure;
ax = axes('Parent', fig9);
surf(ax, u, v, w, spectrumLog, 'edgecolor', 'none', 'FaceAlpha', 0.8)

%Do some magic to make the figure look nice (black theme)
fig9.Color = 'k';
ax.Color = 'k';
cmap = colormap;
cmap(1,:) = [1 1 1]*0.2;
colormap(ax, cmap);
view(ax, 40, 40)
axis(ax, 'square')
ax.XColor = 'w';
ax.YColor = 'w';
ax.ZColor = 'w';
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.ZTickLabel = [];
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';
ax.ZMinorGrid = 'on';
ax.MinorGridColor = 'w';
ax.MinorGridLineStyle = '-';
xlabel(ax, 'u = sin(\theta)cos(\phi)')
ylabel(ax, 'v = sin(\theta)sin(\phi)')
zlabel(ax, 'w = cos(\theta)')

%Set the dynamic range
caxis(ax, [-dynamicRange 0])

%% 3D-array case, use plotSteeredResponseUV function


%The function interpolates the result, so can use fewer scanning angles/points
thetaScanAngles = 0:2:360;
phiScanAngles = 0:4:180;

%Changed scanning angles so update steering vector (input signal is the
%same so we can keep R as before)
[e, u, v, w] = steeringVector(xPos, yPos, zPos, f, c, thetaScanAngles, phiScanAngles);

% Calculate delay-and-sum steered response
S = steeredResponseDelayAndSum(R, e, elementWeights);

%Plot the steered response, no need to normalise the
%spectrum or converting to decibel before input
plotSteeredResponseUV(S, u, v, w, 'uvw', 'log', 'black', '3D')



