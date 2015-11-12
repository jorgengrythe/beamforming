function collectPoints

xPos = [];
yPos = [];
w = [];
f = 1e3;
c = 340;
thetaSteeringAngle = 0;
phiSteeringAngle = 0;
thetaScanningAngles = -90:0.1:90;
phiScanningAngles = 0;


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
box(axResponse, 'on')
title(axResponse,['Beampattern @ ' sprintf('%0.2f', f*1e-3) ' kHz'],'fontweight','normal');
ylabel(axResponse, 'dB');
axResponse.XLim = [thetaScanningAngles(1) thetaScanningAngles(end)];
axResponse.YLim = [-50 0];
axResponse.YTick = [-50 -40 -30 -20 -10 -3 0];
axResponse.XTick = [-90 -60 -30 0 30 60 90];
hold(axResponse, 'on');
grid(axResponse, 'on')
axResponse.NextPlot = 'replacechildren';


%Add frequency slider
frequencySlider = uicontrol('style', 'slider', ...
    'Units', 'normalized',...
    'position', [0.935 0.11 0.035 0.34],...
    'value', f,...
    'min', 0.1e3,...
    'max', 20e3);
addlistener(frequencySlider, 'ContinuousValueChange', @(obj,evt) changeFrequencyOfSource(obj, evt, obj.Value) );
addlistener(frequencySlider,'ContinuousValueChange',@(obj,evt) title(axResponse, ['Beampattern @ ' sprintf('%0.2f', obj.Value*1e-3) ' kHz'],'fontweight','normal'));

%Add steering angle slider
angleSlider = uicontrol('style', 'slider', ...
    'Units', 'normalized',...
    'position', [0.13 0.04 0.78 0.025],...
    'value', thetaSteeringAngle,...
    'min', -90,...
    'max', 90);
addlistener(angleSlider, 'ContinuousValueChange', @(obj,evt) changeAngleOfSource(obj, evt, obj.Value) );


%Add context menu to geometry
cmFigure = uicontextmenu;
cmNor848A4 = uimenu('Parent',cmFigure,'Label','Nor848A-4');
cmNor848A10 = uimenu('Parent',cmFigure,'Label','Nor848A-10');
uimenu('Parent',cmNor848A4,'Label','Weighted', 'Callback', { @changeArray, 'Nor848A-4', 'weighted' });
uimenu('Parent',cmNor848A4,'Label','Unweighted', 'Callback', { @changeArray, 'Nor848A-4', 'unweighted' });
uimenu('Parent',cmNor848A10,'Label','Weighted', 'Callback', { @changeArray, 'Nor848A-10', 'weighted' });
uimenu('Parent',cmNor848A10,'Label','Unweighted', 'Callback', { @changeArray, 'Nor848A-10', 'unweighted' });
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

    function changeFrequencyOfSource(~, ~, selectedFrequency)
        f = selectedFrequency;
        plotBeampattern1D(w)
    end

    function changeAngleOfSource(~, ~, selectedAngle)
        thetaSteeringAngle = selectedAngle;
        plotBeampattern1D(w)
    end

    function plotBeampattern1D(w)
        
        try
            beamPattern = arrayFactor(xPos, yPos, w, f, c, thetaScanningAngles, ...
                phiScanningAngles, thetaSteeringAngle, phiSteeringAngle);
            beamPattern = 20*log10(beamPattern);
            
            plot(axResponse, thetaScanningAngles, beamPattern)
        catch
            %Don't do anything if xPos/yPos doesn't exist
        end
    end

    function clearFigure(~, ~)
        cla(axArray)
        cla(axResponse)
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

