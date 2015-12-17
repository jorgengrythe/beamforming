function collectPointsPolar

addpath('algorithm', 'beampattern')

xPos = [];
yPos = [];
w = [];
f = 1e3;
c = 340;
thetaSteeringAngle = 0;
phiSteeringAngle = 0;
thetaScanningAngles = -90:0.1:90;
phiScanningAngles = 0;
dBmin = 50;


% Create figure and axes
fig = figure;
fig.Position = [400 150 470 750];
fig.Name = 'Beampattern';
fig.NumberTitle = 'off';
fig.ToolBar = 'none';
fig.MenuBar = 'none';
fig.Resize = 'off';

%Axis for geometry
axArray = subplot(211);
axArray.XLim = [-1 1]*0.6;
axArray.YLim = [-1 1]*0.6;
axArray.ButtonDownFcn = {@drawPoint};
hold(axArray, 'on');
box(axArray, 'on')
axArray.XTick = [-1 -0.75 -0.5 -0.25 0 0.25 0.5 0.75 1];
axArray.YTick = [-1 -0.75 -0.5 -0.25 0 0.25 0.5 0.75 1];
grid(axArray, 'on')
grid(axArray,'minor')
title(axArray,'Microphone positions', 'fontweight', 'normal');
axis(axArray, 'square')
      

%Axis for beampattern
axResponse = subplot(212);
header = text(0,dBmin*1.2, ...
    ['Beampattern @ ' sprintf('%0.2f', f*1e-3) ' kHz'],...
    'HorizontalAlignment', 'center', ...
    'fontSize', 12);
axResponse.NextPlot = 'replacechildren';
axResponse.Visible = 'off';
axis(axResponse, 'equal')
ylim(axResponse,[0 dBmin])
xlim(axResponse, [-dBmin dBmin])
hold(axResponse, 'on')
           
%Set background color to white (inside half circle)
patch('XData', cos(0:pi/50:2*pi) * dBmin, ...
    'YData', sin(0:pi/50:2*pi) * dBmin,...
    'FaceColor', [1 1 1], ...
    'Parent', axResponse);

%Plot angle spokes
spokeTicks = [-90 -60 -30 -0 30 60 90];
for tick = spokeTicks
    line(dBmin * [-sin(tick*pi/180) sin(tick*pi/180)], ...
        dBmin * [-cos(tick*pi/180) cos(tick*pi/180)], ...
    'LineStyle', '-', ...
    'Color', [1 1 1]*0.8, ...
    'LineWidth', 0.5, ...
    'Parent', axResponse);

    text((dBmin*1.08) * sin(tick*pi/180), ...
        (dBmin*1.08) * cos(tick*pi/180), ...
        [int2str(tick) '^\circ'],...
        'HorizontalAlignment', 'center', ...
        'fontSize', 10, ...
        'Parent', axResponse);
end

%Plot dB ticks
dBTicks = [-10 -20 -30 -40];
txtAngle = 10;
for tick = dBTicks
    line(cos(0:pi/50:2*pi)*(dBmin+tick), sin(0:pi/50:2*pi)*(dBmin+tick), ...
        'LineStyle', '-', ...
        'Color', [1 1 1]*0.8, ...
        'LineWidth', 0.5, ...
        'Parent', axResponse);
    
    text((dBmin+tick)*cos(txtAngle*pi/180), ...
        (dBmin+tick)*sin(txtAngle*pi/180), ...
        ['  ' num2str(tick)], ...
        'fontsize',8, ...
        'Parent', axResponse);
end
line(cos(0:pi/50:2*pi)*dBmin, sin(0:pi/50:2*pi)*dBmin, ...
    'LineStyle', '-', ...
    'Color', [0 0 0], ...
    'LineWidth', 1, ...
    'Parent', axResponse);
line([-dBmin dBmin], [0 0], ...
    'LineStyle', '-', ...
    'Color', [0 0 0], ...
    'LineWidth', 1, ...
    'Parent', axResponse);

bpPlot = plot(axResponse,0,0);


%Add frequency slider
frequencySlider = uicontrol('style', 'slider', ...
    'Units', 'normalized',...
    'position', [0.96 0.15 0.035 0.25],...
    'value', f,...
    'min', 0.1e3,...
    'max', 20e3);
addlistener(frequencySlider, 'ContinuousValueChange', @(obj,evt) changeFrequencyOfSource(obj, evt) );

%Add steering angle slider
angleSlider = uicontrol('style', 'slider', ...
    'Units', 'normalized',...
    'position', [0.13 0.1 0.78 0.025],...
    'value', thetaSteeringAngle,...
    'min', -90,...
    'max', 90);
addlistener(angleSlider, 'ContinuousValueChange', @(obj,evt) changeAngleOfSource(obj, evt) );


%Add context menu to geometry
cmFigure = uicontextmenu;
cmNor848A4 = uimenu('Parent',cmFigure,'Label','Nor848A-4');
cmNor848A10 = uimenu('Parent',cmFigure,'Label','Nor848A-10');
uimenu('Parent',cmNor848A4,'Label','Weighted', 'Callback', { @changeArray, 'Nor848A-4', 'weighted' });
uimenu('Parent',cmNor848A4,'Label','Unweighted', 'Callback', { @changeArray, 'Nor848A-4', 'unweighted' });
uimenu('Parent',cmNor848A10,'Label','Weighted', 'Callback', { @changeArray, 'Nor848A-10', 'weighted' });
uimenu('Parent',cmNor848A10,'Label','Unweighted', 'Callback', { @changeArray, 'Nor848A-10', 'unweighted' });
uimenu('Parent',cmFigure,'Label','Ring-32', 'Callback', { @changeArray, 'Ring-32', 'unweighted' });
uimenu('Parent',cmFigure,'Label','Ring-72', 'Callback', { @changeArray, 'Ring-72', 'unweighted' });
uimenu('Parent',cmFigure,'Label','Clear all', 'Callback', { @clearFigure });
axArray.UIContextMenu = cmFigure;


    function drawPoint(obj, eventData)
        %Don't draw a point on right click
        if strcmp(obj.Parent.SelectionType,'alt')

        else
            plot(axArray,eventData.IntersectionPoint(1),...
                eventData.IntersectionPoint(2),'Marker','.','Color',[0 0.4470 0.7410],...
                'MarkerSize',15);
                      
            xPos = [xPos eventData.IntersectionPoint(1)];
            yPos = [yPos eventData.IntersectionPoint(2)];
            
            w = ones(1, numel(xPos))/numel(xPos);
            plotBeampattern1D(w)
        end
    end

    function changeFrequencyOfSource(obj, ~)
        header.String = ['Beampattern @ ' sprintf('%0.2f', obj.Value*1e-3) ' kHz'];
        f = obj.Value;
        plotBeampattern1D(w)
    end

    function changeAngleOfSource(obj, ~)
        thetaSteeringAngle = obj.Value;
        plotBeampattern1D(w)
    end

    function plotBeampattern1D(w)
        
        try
            beamPattern = arrayFactor(xPos, yPos, w, f, c, thetaScanningAngles, ...
                phiScanningAngles, thetaSteeringAngle, phiSteeringAngle);
            beamPattern = 20*log10(beamPattern);
            beamPattern = reshape(beamPattern, 1, numel(beamPattern));
            
            xx = (beamPattern+dBmin) .* sin(thetaScanningAngles*pi/180);
            yy = (beamPattern+dBmin) .* cos(thetaScanningAngles*pi/180);
            
            delete(bpPlot);
            bpPlot = plot(axResponse, xx, yy, 'Color', [0 0.4470 0.7410]);


        catch
            %Don't do anything if xPos/yPos doesn't exist
        end
    end

    function clearFigure(~, ~)
        cla(axArray)
        delete(bpPlot);
        xPos = [];
        yPos = [];
    end

    function changeArray(~, ~, selectedArray, selectedWeighting)
        clearFigure
        array = load(['data/arrays/' selectedArray '.mat']);
        xPos = array.xPos;
        yPos = array.yPos;
        if strcmp(selectedWeighting, 'weighted')
            w = array.hiResWeights;
        else
            w = ones(1, numel(xPos));
        end
        plot(axArray,xPos,yPos,'.','Color',[0 0.4470 0.7410],...
            'MarkerSize',10);
        plotBeampattern1D(w)
    end

end


