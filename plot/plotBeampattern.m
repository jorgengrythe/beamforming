function [] = plotBeampattern(xPos, yPos, zPos, weights, f, c, thetaSteerAngle, phiScanAngle, dynRange)
%plotBeampattern - plots the beampattern for various frequencies
%
%plotBeampattern(xPos, yPos, zPos, w, f, c, thetaSteeringAngle, sliceAngle, dynRange)
%
%IN
%xPos             - 1xP vector of x-positions [m]
%yPos             - 1xP vector of y-positions [m]
%zPos             - 1xP vector of z-positions [m]
%weights          - 1xP vector of element weights
%f                - Wave frequency [Hz]
%c                - Speed of sound [m/s]
%thetaSteerAngle  - 1x1 theta steering angle [degrees]
%phiScanAngle     - Angle slice to show, 0 for xz and 90 for yz view
%dynRange         - Dynamic range in plot [dB]
%
%OUT
%[]               - The figure plot
%
%Created by J?rgen Grythe, Squarehead Technology AS
%Last updated 2016-12-15


if ~exist('dynRange','var')
    dynRange = 50;
end

if ~exist('phiScanAngle', 'var')
    phiScanAngle = 0;
end

if ~exist('thetaSteerAngle', 'var')
    thetaSteerAngle = 0;
end


%Scanning angles
thetaScanAngles = -90:0.01:90;

%Linewidth in plot
lwidth = 1;

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
    plot(axRectangular, thetaScanAngles, W, 'linewidth', lwidth, 'DisplayName', [num2str(ff*1e-3) ' kHz']);
    
    % Polar plot
    xx = (W+dynRange) .* sin(thetaScanAngles*pi/180);
    yy = (W+dynRange) .* cos(thetaScanAngles*pi/180);
    p = plot(axPolar, xx, yy, 'linewidth', lwidth, 'DisplayName', [num2str(ff*1e-3) ' kHz']);
    polarPlotHandles = [polarPlotHandles p];
end

legend(axRectangular, 'show', 'Location','NorthEast')
legend(axPolar, polarPlotHandles, 'Location','NorthEast')



set(bpFig,'position',[500 200 540 600])