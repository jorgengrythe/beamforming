function [] = plotBeampatternDynamic(xPos, yPos, zPos, w, phiScanAngle)
%plotBeampatternDynamic - plots the beampattern for all frequencies and any
%steering angle selected in the figure plot by slider bars
%
%plotBeampatternDynamic(xPos, yPos, zPos, w)
%
%IN
%xPos                - 1xP vector of x-positions [m]
%yPos                - 1xP vector of y-positions [m]
%yPos                - 1xP vector of z-positions [m]
%w                   - 1xP vector of element weights (optional)
%
%OUT
%[]                  - The figure plot
%
%Created by J?rgen Grythe
%Last updated 2016-05-02

%If no weights are given use uniform weighting
if ~exist('w','var')
    w = ones(1, numel(xPos))/numel(xPos);
end

if ~exist('phiScanAngle','var')
    phiScanAngle = 0;
end

%Default values
f = 3e3;
c = 340;
dynamicRange = 50;
thetaSteeringAngle = 0;
thetaScanAngles = -90:0.1:90;
phiScanAngle = 0;
minFrequency = 20;
maxFrequency = 15e3;


% Create figure and axes
fig = figure;
fig.Position = [400 150 470 750];
fig.Name = 'Beampattern';
fig.NumberTitle = 'off';
fig.Color = 'w';
%fig.ToolBar = 'none';
%fig.MenuBar = 'none';
%fig.Resize = 'off';

%Axis for beampattern
axResponse = subplot(211);
box(axResponse, 'on')
title(axResponse,['Beampattern @ ' sprintf('%0.2f', f*1e-3) ' kHz'],'fontweight','normal');
ylabel(axResponse, 'dB');
axResponse.XLim = [thetaScanAngles(1) thetaScanAngles(end)];
axResponse.YLim = [-dynamicRange 0];
axResponse.YTick = [-50 -40 -30 -20 -10 -3 0];
axResponse.XTick = [-90 -60 -30 0 30 60 90];
hold(axResponse, 'on');
grid(axResponse, 'on')
axResponse.NextPlot = 'replacechildren';

%Polar plot axis
axPolarResponse = subplot(212);
axPolarResponse.Visible = 'off';
hold(axPolarResponse, 'on')
axis(axPolarResponse, 'equal')
ylim(axPolarResponse, [0 dynamicRange])
xlim(axPolarResponse, [-dynamicRange dynamicRange])
polarPlot = plot(axPolarResponse, 0, 0);

dBTicks = -(10:10:dynamicRange-10);
angleTicks = [-90 -60 -30 0 30 60 90];

%Set background color for polar plot to white (inside half circle)
patch('XData', cos(0:pi/50:2*pi) * dynamicRange, ...
    'YData', sin(0:pi/50:2*pi) * dynamicRange,...
    'FaceColor', [1 1 1], ...
    'Parent', axPolarResponse);

%Plot angle spokes in polar plot
for tick = angleTicks
    line(dynamicRange * [-sin(tick*pi/180) sin(tick*pi/180)], ...
        dynamicRange * [-cos(tick*pi/180) cos(tick*pi/180)], ...
        'LineStyle', '-', ...
        'Color', [1 1 1]*0.8, ...
        'LineWidth', 0.5, ...
        'Parent', axPolarResponse);
    
    text((dynamicRange*1.08) * sin(tick*pi/180), ...
        (dynamicRange*1.08) * cos(tick*pi/180), ...
        [int2str(tick) '^\circ'],...
        'HorizontalAlignment', 'center', ...
        'fontSize', 10, ...
        'Parent', axPolarResponse);
end

    
%Plot dB ticks in polar plot
txtAngle = 10;
for tick = dBTicks
    line(cos(0:pi/50:2*pi)*(dynamicRange+tick), sin(0:pi/50:2*pi)*(dynamicRange+tick), ...
        'LineStyle', '-', ...
        'Color', [1 1 1]*0.8, ...
        'LineWidth', 0.5, ...
        'Parent', axPolarResponse);
    
    text((dynamicRange+tick)*cos(txtAngle*pi/180), ...
        (dynamicRange+tick)*sin(txtAngle*pi/180), ...
        ['  ' num2str(tick)], ...
        'fontsize',8, ...
        'Parent', axPolarResponse);
end
line(cos(0:pi/50:2*pi)*dynamicRange, sin(0:pi/50:2*pi)*dynamicRange, ...
    'LineStyle', '-', ...
    'Color', [0 0 0], ...
    'LineWidth', 1, ...
    'Parent', axPolarResponse);
line([-dynamicRange dynamicRange], [0 0], ...
    'LineStyle', '-', ...
    'Color', [0 0 0], ...
    'LineWidth', 1, ...
    'Parent', axPolarResponse);



%Add frequency slider to figure
frequencySlider = uicontrol('style', 'slider', ...
    'Units', 'normalized',...
    'position', [0.935 0.11 0.035 0.34],...
    'value', f,...
    'min', minFrequency, ...
    'max', maxFrequency);
addlistener(frequencySlider, 'ContinuousValueChange', @(obj,evt) changeFrequencyOfSource(obj, evt, obj.Value) );
addlistener(frequencySlider,'ContinuousValueChange',@(obj,evt) title(axResponse, ['Beampattern @ ' sprintf('%0.2f', obj.Value*1e-3) ' kHz'],'fontweight','normal'));

%Add steering angle slider to figure
angleSlider = uicontrol('style', 'slider', ...
    'Units', 'normalized',...
    'position', [0.13 0.04 0.78 0.025],...
    'value', thetaSteeringAngle,...
    'min', -90,...
    'max', 90);
addlistener(angleSlider, 'ContinuousValueChange', @(obj,evt) changeAngleOfSource(obj, evt, obj.Value) );


%Plot the beampattern
plotBeampattern1D

    %Function used by frequency slider
    function changeFrequencyOfSource(~, ~, selectedFrequency)
        f = selectedFrequency;
        plotBeampattern1D
    end
    
    %Function used by steering angle slider
    function changeAngleOfSource(~, ~, selectedAngle)
        thetaSteeringAngle = selectedAngle;
        plotBeampattern1D
    end
    
    %Calculating the beampattern and updating beampattern plot
    function plotBeampattern1D
        beamPattern = arrayFactor(xPos, yPos, zPos, w, f, c, thetaScanAngles, ...
            phiScanAngle, thetaSteeringAngle, phiScanAngle);
        beamPattern = 20*log10(beamPattern);
        beamPattern = reshape(beamPattern, 1, numel(beamPattern));
        
        plot(axResponse, thetaScanAngles, beamPattern, 'LineWidth', 1)
        
        delete(polarPlot)
        xx = (beamPattern+dynamicRange) .* sin(thetaScanAngles*pi/180);
        yy = (beamPattern+dynamicRange) .* cos(thetaScanAngles*pi/180);
        polarPlot = plot(axPolarResponse, xx, yy, 'LineWidth', 1, 'Color', [0 0.4470 0.7410]);
    end



end

