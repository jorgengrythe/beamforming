function [] = plotBeampattern(xPos, yPos, w, f, c, dBmin, thetaScanningAngles, thetaSteeringAngle)
%plotBeampattern - plots the beampattern for various frequencies
%
%plotBeampattern(xPos, yPos, w, f, c, dBmin, thetaScanningAngles, thetaSteeringAngle)
%
%IN
%xPos                - 1xP vector of x-positions [m]
%yPos                - 1xP vector of y-positions [m]
%w                   - 1xP vector of element weights
%f                   - Wave frequency [Hz]
%c                   - Speed of sound [m/s]
%thetaScanningAngles - 1xN vector of theta scanning angles [degrees]
%thetaSteeringAngle  - 1x1 theta steering angle
%
%OUT
%[]              - The figure plot
%
%Created by Jørgen Grythe, Norsonic AS
%Last updated 2015-12-15


if ~exist('thetaSteeringAngle','var')
    thetaSteeringAngle = 0;
end

if ~exist('theta','var')
    thetaScanningAngles = -90:0.2:90;
end


if ~exist('dBmin','var')
    dBmin = 50;
end

%Linewidth
lwidth = 1;

% Plot beampattern
bpFig = figure;clf

axRectangular = subplot(211);
hold(axRectangular, 'on')
xlabel(axRectangular, 'Angle (deg)')
ylabel(axRectangular, 'Attenuation (dB)')
grid(axRectangular, 'on')
axis(axRectangular, [thetaScanningAngles(1) thetaScanningAngles(end) -dBmin 0])
axRectangular.YTick = [-50 -45 -40 -35 -30 -25 -20 -15 -10 -6 -3 0];
axRectangular.XTick = [-90 -80 -70 -60 -50 -40 -30 -20 -10 0 10 20 30 40 50 60 70 80 90];


axPolar = subplot(212);
axPolar.Visible = 'off';
hold(axPolar, 'on')
axis(axPolar, 'equal')
ylim(axPolar,[0 dBmin])
xlim(axPolar, [-dBmin dBmin])

dBTicks = [-10 -20 -30 -40];
angleTicks = [-90 -60 -30 0 30 60 90];

%Set background color to white (inside half circle)
patch('XData', cos(0:pi/50:2*pi) * dBmin, ...
    'YData', sin(0:pi/50:2*pi) * dBmin,...
    'FaceColor', [1 1 1], ...
    'Parent', axPolar);

%Plot angle spokes
for tick = angleTicks
    line(dBmin * [-sin(tick*pi/180) sin(tick*pi/180)], ...
        dBmin * [-cos(tick*pi/180) cos(tick*pi/180)], ...
        'LineStyle', '-', ...
        'Color', [1 1 1]*0.8, ...
        'LineWidth', 0.5, ...
        'Parent', axPolar);
    
    text((dBmin*1.08) * sin(tick*pi/180), ...
        (dBmin*1.08) * cos(tick*pi/180), ...
        [int2str(tick) '^\circ'],...
        'HorizontalAlignment', 'center', ...
        'fontSize', 10, ...
        'Parent', axPolar);
end

    
%Plot dB ticks
txtAngle = 10;
for tick = dBTicks
    line(cos(0:pi/50:2*pi)*(dBmin+tick), sin(0:pi/50:2*pi)*(dBmin+tick), ...
        'LineStyle', '-', ...
        'Color', [1 1 1]*0.8, ...
        'LineWidth', 0.5, ...
        'Parent', axPolar);
    
    text((dBmin+tick)*cos(txtAngle*pi/180), ...
        (dBmin+tick)*sin(txtAngle*pi/180), ...
        ['  ' num2str(tick)], ...
        'fontsize',8, ...
        'Parent', axPolar);
end
line(cos(0:pi/50:2*pi)*dBmin, sin(0:pi/50:2*pi)*dBmin, ...
    'LineStyle', '-', ...
    'Color', [0 0 0], ...
    'LineWidth', 1, ...
    'Parent', axPolar);
line([-dBmin dBmin], [0 0], ...
    'LineStyle', '-', ...
    'Color', [0 0 0], ...
    'LineWidth', 1, ...
    'Parent', axPolar);




for ff = f
	W = arrayFactor(xPos, yPos, w, ff, c, thetaScanningAngles, 0, thetaSteeringAngle);
    W = 20*log10(W);
    W = reshape(W, 1, numel(W));
    
    % Rectangular plot
    plot(axRectangular, thetaScanningAngles,W,'DisplayName',[num2str(ff*1e-3) ' kHz'],'linewidth',lwidth);
    
    % Polar plot
    xx = (W+dBmin) .* sin(thetaScanningAngles*pi/180);
    yy = (W+dBmin) .* cos(thetaScanningAngles*pi/180);
    plot(axPolar, xx, yy, 'linewidth', lwidth);
end

legend(axRectangular, 'show','Location','NorthEast')


set(bpFig,'position',[500 200 540 600])