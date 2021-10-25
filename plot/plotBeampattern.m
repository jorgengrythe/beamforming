function [] = plotBeampattern(xPos, yPos, zPos, weights, f, c, thetaSteerAngle, phiScanAngle, dynRange, plotType)
%plotBeampattern - plots the beampattern for various frequencies
%
%plotBeampattern(xPos, yPos, zPos, weights, f, c, thetaSteerAngle, phiScanAngle, dynRange, plotType)
%
%IN
%xPos             - 1xP vector of x-positions [m]
%yPos             - 1xP vector of y-positions [m]
%zPos             - 1xP vector of z-positions [m]
%weights          - 1xP vector of element weights (optional, default uniform weighting)
%f                - Wave frequency [Hz] (optional, default 0.5, 1, 1.5, 3 kHz)
%c                - Speed of sound [m/s] (optional, default 340 m/s)
%thetaSteerAngle  - 1x1 theta steering angle [degrees]  (optional)
%phiScanAngle     - Angle slice to show, 0 for xz and 90 for yz view  (optional)
%dynRange         - Dynamic range in plot [dB]  (optional)
%plotType         - Use 'rect' or 'polar' (optional)
%
%OUT
%[]               - The figure plot
%
%Created by J?rgen Grythe
%Last updated 2017-10-10

if ~exist('plotType','var')
    plotType = 'full';
end

if ~exist('dynRange','var')
    dynRange = 50;
end

if ~exist('phiScanAngle', 'var')
    phiScanAngle = 0;
end

if ~exist('thetaSteerAngle', 'var')
    thetaSteerAngle = 0;
end

if ~exist('c', 'var')
    c = 340;
end

if ~exist('f', 'var')
    f = [0.5 1 1.5 3]*1e3;
end

if ~exist('weights', 'var')
    weights = ones(1, numel(xPos))/numel(xPos);
end


%Scanning angles
thetaScanAngles = -90:0.01:90;

%Linewidth in plot
lwidth = 1.5;

% Plot beampattern
bpFig = figure;
bpFig.Color = [1 1 1];

%Rectangular plot axis
axRectangular = subplot(211);
hold(axRectangular, 'on')
xlabel(axRectangular, 'Angle (deg)')
ylabel(axRectangular, 'Attenuation (dB)')
grid(axRectangular, 'on')
axis(axRectangular, [thetaScanAngles(1) thetaScanAngles(end) -dynRange 0])
axRectangular.YTick = [-50 -45 -40 -35 -30 -25 -20 -15 -10 -6 -3 0];
axRectangular.XTick = [-90 -80 -70 -60 -50 -40 -30 -20 -10 0 10 20 30 40 50 60 70 80 90];

%Polar plot axis
axPolar = subplot(212);
axPolar.Visible = 'off';
hold(axPolar, 'on')
axis(axPolar, 'equal')
ylim(axPolar, [0 dynRange])
xlim(axPolar, [-dynRange dynRange])


dBTicks = [-3 -(10:10:dynRange-10)];
angleTicks = [-90 -60 -30 0 30 60 90];

%Set background color for polar plot to white (inside half circle)
patch('XData', cos(0:pi/50:2*pi) * dynRange, ...
    'YData', sin(0:pi/50:2*pi) * dynRange,...
    'FaceColor', [1 1 1], ...
    'Parent', axPolar);

%Plot angle spokes in polar plot
for tick = angleTicks
    line(dynRange * [-sin(tick*pi/180) sin(tick*pi/180)], ...
        dynRange * [-cos(tick*pi/180) cos(tick*pi/180)], ...
        'LineStyle', '-', ...
        'Color', [1 1 1]*0.8, ...
        'LineWidth', 0.5, ...
        'Parent', axPolar);
    
    text((dynRange*1.08) * sin(tick*pi/180), ...
        (dynRange*1.08) * cos(tick*pi/180), ...
        [int2str(tick) '^\circ'],...
        'HorizontalAlignment', 'center', ...
        'fontSize', 10, ...
        'Parent', axPolar);
end

    
%Plot dB ticks in polar plot
txtAngle = 10;
for tick = dBTicks
    line(cos(0:pi/50:2*pi)*(dynRange+tick), sin(0:pi/50:2*pi)*(dynRange+tick), ...
        'LineStyle', '-', ...
        'Color', [1 1 1]*0.8, ...
        'LineWidth', 0.5, ...
        'Parent', axPolar);
    
    text((dynRange+tick)*cos(txtAngle*pi/180), ...
        (dynRange+tick)*sin(txtAngle*pi/180), ...
        ['  ' num2str(tick) ' dB'], ...
        'fontsize',8, ...
        'Parent', axPolar);
end
line(cos(0:pi/50:2*pi)*dynRange, sin(0:pi/50:2*pi)*dynRange, ...
    'LineStyle', '-', ...
    'Color', [0 0 0], ...
    'LineWidth', 1, ...
    'Parent', axPolar);
line([-dynRange dynRange], [0 0], ...
    'LineStyle', '-', ...
    'Color', [0 0 0], ...
    'LineWidth', 1, ...
    'Parent', axPolar);



%Calculate and plot the beampattern(s) in the figure
polarPlotHandles = [];
for ff = f
	W = arrayFactor(xPos, yPos, zPos, weights, ff, c, thetaScanAngles, phiScanAngle, thetaSteerAngle, phiScanAngle);
    
    W = 20*log10(W);
    W = reshape(W, 1, numel(W));
    
    % Rectangular plot
    if ff < 1e3
        displayName = [num2str(ff) ' Hz'];
    else
        displayName = [num2str(ff*1e-3) ' kHz'];
    end
    plot(axRectangular, thetaScanAngles, W, 'linewidth', lwidth, 'DisplayName', displayName);
    
    % Polar plot
    xx = (W+dynRange) .* sin(thetaScanAngles*pi/180);
    yy = (W+dynRange) .* cos(thetaScanAngles*pi/180);
    p = plot(axPolar, xx, yy, 'linewidth', lwidth, 'DisplayName', displayName);
    polarPlotHandles = [polarPlotHandles p];
end

legend(axRectangular, 'show', 'Location','NorthEast')
legend(axPolar, polarPlotHandles, 'Location','NorthEast')


bpFig.Position = [500 200 540 600];

%Only show rectangular or polar plot if plotType is given
switch plotType
    case 'rect'
        delete(axPolar)
        bpFig.Position = [500 200 540 300];
        axRectangular.Position = [0.1300 0.1100 0.7750 0.7750];
    case 'polar'
        delete(axRectangular)
        bpFig.Position = [500 200 540 300];
        axPolar.Position = [0.1300 0.1100 0.7750 0.7750];
end
