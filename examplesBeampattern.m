%% Examples on how to calculate array factor / beampattern

%% Create 2D array

% Position of sensors and weighting of 2D array
% Create circular array

nElements = 20;
radius = 0.6;

[xPos, yPos] = pol2cart(linspace(0,2*pi-2*pi/nElements,nElements),ones(1,nElements)*radius);
zPos = zeros(1, numel(xPos));
elementWeights = ones(1, numel(xPos))/numel(xPos);


%% Plot array geometry and array factor for different frequencies

% Wave-frequency and wave-speed
f = [250 500 1e3 1.3e3];
c = 340;

% Scanning angles
thetaScanningAngles = -90:90;
phiScanningAngles = 0;

%Calculate and plot the array pattern for various frequencies
fig = figure;
fig.Color = 'w';

axGeometry = subplot(121, 'Parent', fig);
scatter(axGeometry, xPos, yPos, 20, 'filled')
title(axGeometry, 'Array geometry','FontWeight','Normal')
axis(axGeometry, [-radius-0.1 radius+0.1 -radius-0.1 radius+0.1])
axis(axGeometry, 'square')
grid(axGeometry, 'minor')

axResponse = subplot(122, 'Parent', fig);
for ff = f
    AF = arrayFactor(xPos, yPos, zPos, elementWeights, ff, c, thetaScanningAngles, phiScanningAngles);
    AF = 20*log10(AF);
    
    plot(axResponse, thetaScanningAngles, AF, 'LineWidth', 1, 'DisplayName', [num2str(ff*1e-3) ' kHz']);
    hold on
end
xlabel(axResponse, '\theta')
ylabel(axResponse, 'dB')
axis(axResponse, 'square')
grid(axResponse, 'on')
title(axResponse, 'Array factor', 'FontWeight', 'Normal')
axis(axResponse, [thetaScanningAngles(1) thetaScanningAngles(end) -30 0])
legend(axResponse, 'show', 'Location','SouthEast')

%% Plot with steering

% Wave-frequency and wave-speed
f = [750 1e3];
c = 340;

% Scanning angles
thetaScanningAngles = -60:0.5:60;
phiScanningAngles = 0;

% Steering angle
thetaSteeringAngle = -20;

% Calculate and plot the array factor
fig = figure;
fig.Color = 'w';
ax = axes('Parent', fig);
hold(ax, 'on')
for ff = f
    AF = arrayFactor(xPos, yPos, zPos, elementWeights, ff, c, thetaScanningAngles, phiScanningAngles, thetaSteeringAngle);
    AF = 20*log10(AF);
    
    plot(thetaScanningAngles, AF, 'LineWidth', 1, 'DisplayName', [num2str(ff*1e-3) 'kHz']);
end

xlabel(ax, '\theta')
ylabel(ax, 'dB')
grid(ax, 'on')
axis(ax, [thetaScanningAngles(1) thetaScanningAngles(end) -30 0])
legend(ax, 'show', 'Location','SouthEast')
title(ax, ['Steering angle ' num2str(thetaSteeringAngle) ' degrees'],'FontWeight','Normal')
indx = find(thetaScanningAngles >= thetaSteeringAngle, 1);
line(ax, [thetaScanningAngles(indx) thetaScanningAngles(indx)], ax.YLim, 'LineWidth', 1, 'Color', 'r', 'LineStyle','--');


%% Plot array factor from 0 to 10 kHz

% Wave-frequency and wave-speed
f = 0:10:10e3;
c = 340;

% Scanning angles
thetaScanningAngles = -90:0.2:90;
phiScanningAngles = 0;

%Preallocating for speed
W_all = zeros(numel(f), numel(thetaScanningAngles));

%Calculate array factor
for k = 1:length(f)
    AF = arrayFactor(xPos, yPos, zPos, elementWeights, f(k), c, thetaScanningAngles, phiScanningAngles);
    W_all(k,:) = 20*log10(AF);
end

%Don't display values below a certain threshold
dynRange = 30;
W_all(W_all<-dynRange) = NaN;

%Plot array factor
fig = figure;
fig.Color = 'w';
ax = axes('Parent', fig);
imagesc(ax, f*1e-3,thetaScanningAngles, W_all')
xlabel(ax, 'kHz')
ylabel(ax, '\theta')
colorbar(ax, 'northoutside', 'direction', 'reverse')

%% Plot the beampattern for various frequencies with plotBeampattern()

f = [0.5e3 1e3 3e3];
c = 340;
thetaSteeringAngle = -10;

plotBeampattern(xPos, yPos, zPos, elementWeights, f, c, thetaSteeringAngle)


%% Plot the spherical beampattern of the array with plotBeampatternSpherical function

plotBeampatternSpherical(xPos, yPos, zPos, elementWeights)


%% Create 3D array and plot beampattern in UVW space

%Create array and weighting
[xPos, yPos, zPos] = sphere(7);
xPos = xPos(:)*radius;
yPos = yPos(:)*radius;
zPos = zPos(:)*radius;
elementWeights = ones(1,numel(xPos))/numel(xPos);

%Scanning angles
thetaScanAngles = 0:1:360;
phiScanAngles = 0:180;

%Steering angles
thetaSteerAngle = 60;
phiSteerAngle = -120;

%Frequency and dynamic range
dynRange = 15;
f = 0.5e3;


%Calculate the array factor
[AF, u, v, w] = arrayFactor(xPos, yPos, zPos, elementWeights, f, 340, thetaScanAngles, phiScanAngles, thetaSteerAngle, phiSteerAngle);
AF = 20*log10(AF);

%Plot geometry and response
fig = figure;
fig.Color = 'w';

axGeometry = subplot(121, 'Parent', fig);
scatter3(axGeometry, xPos, yPos, zPos, 20, 'filled')
title(axGeometry, 'Array geometry','FontWeight','Normal')
axis(axGeometry, [-1 1 -1 1 -1 1])
axis(axGeometry, 'square')
grid(axGeometry, 'minor')

axResponse = subplot(122, 'Parent', fig);
surf(axResponse, u, v, w, AF, 'edgecolor', 'none')
axis(axResponse, 'square')
title(axResponse, 'Array factor', 'FontWeight', 'Normal')
axis(axResponse, [-1 1 -1 1 -1 1])
xlabel(axResponse, 'u = sin(\theta)cos(\phi)')
ylabel(axResponse, 'v = sin(\theta)sin(\phi)')
zlabel(axResponse, 'w = cos(\theta)')
view(axResponse, -40, 30)
caxis(axResponse, [-dynRange 0])
