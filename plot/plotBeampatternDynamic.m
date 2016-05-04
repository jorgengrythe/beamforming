function [] = plotBeampatternDynamic(xPos, yPos, w)
%plotBeampatternDynamic - plots the beampattern for all frequencies and any
%steering angle selected in the figure plot by slider bars
%
%plotBeampatternDynamic(xPos, yPos, w)
%
%IN
%xPos                - 1xP vector of x-positions [m]
%yPos                - 1xP vector of y-positions [m]
%w                   - 1xP vector of element weights (optional)
%
%OUT
%[]                  - The figure plot
%
%Created by J?rgen Grythe, Squarehead Technology
%Last updated 2016-05-02

%If no weights are given use uniform weighting
if ~exist('w','var')
    nMics = size(xPos,2);
    w = ones(1,nMics)/nMics;
end

%Default values
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


%Add frequency slider to figure
frequencySlider = uicontrol('style', 'slider', ...
    'Units', 'normalized',...
    'position', [0.935 0.11 0.035 0.34],...
    'value', f,...
    'min', 0.1e3,...
    'max', 20e3);
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


%Plot array geometry and beampattern
scatter(axArray, xPos, yPos, 20, [0    0.4470    0.7410], 'filled')
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
        beamPattern = arrayFactor(xPos, yPos, w, f, c, thetaScanningAngles, ...
            phiScanningAngles, thetaSteeringAngle, phiSteeringAngle);
        beamPattern = 20*log10(beamPattern);
        
        plot(axResponse, thetaScanningAngles, beamPattern,'LineWidth',1)
    end



end

