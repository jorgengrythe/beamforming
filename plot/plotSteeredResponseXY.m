function plotSteeredResponseXY(S, scanningPointsX, scanningPointsY, defaultDynamicRange, interpolationFactor)
%plotSteeredResponseXY - plot the steered response in cartesian coordinate system
%
%Plots the steered response with a slider bar in logarithmic scale and in
%white theme. Right click anywhere in the figure to change between 2D and
%3D view
%
%plotSteeredResponseXY(S, scanningPointsX, scanningPointsY, defaultDynamicRange, interpolationFactor)
%
%IN
%S                   - NxM matrix of delay-and-sum steered response power
%scanningPointsX     - NxM matrix of x-coordinates  
%scanningPointsY     - NxM matrix of y-coordinates
%defaultdynamicRange - Default dynamic range in view
%interpolationFactor - 1x1 int to decide how much to interpolate the final image (optional)
%
%OUT
%[]                  - The figure plot
%
%Created by J?rgen Grythe
%Last updated 2016-10-14

if ~exist('interpolationFactor', 'var')
    interpolationFactor = 2;
end

if exist('defaultDynamicRange', 'var')
    dynamicRange = defaultDynamicRange;
else
    dynamicRange = 6;
end

maxDynamicRange = 30;
display = '2D';

fig = figure;
ax = axes('Parent', fig);
fig.Name = 'Steered response';


%Interpolate for higher resolution
interpolationMethod = 'spline';

S = interp2(S, interpolationFactor, interpolationMethod);
scanningPointsX = interp2(scanningPointsX, interpolationFactor, interpolationMethod);
scanningPointsY = interp2(scanningPointsY, interpolationFactor, interpolationMethod);

S = abs(S)/max(max(abs(S)));
S = 10*log10(S);


steeredResponsePlot = surf(ax, scanningPointsX, scanningPointsY, S,...
    'EdgeColor','none',...
    'FaceAlpha',0.5, ...
    'PickAbleParts', 'none');

%Default colormap
cmap = [0    0.7500    1.0000
    0    0.8125    1.0000
    0    0.8750    1.0000
    0    0.9375    1.0000
    0    1.0000    1.0000
    0.0625    1.0000    0.9375
    0.1250    1.0000    0.8750
    0.1875    1.0000    0.8125
    0.2500    1.0000    0.7500
    0.3125    1.0000    0.6875
    0.3750    1.0000    0.6250
    0.4375    1.0000    0.5625
    0.5000    1.0000    0.5000
    0.5625    1.0000    0.4375
    0.6250    1.0000    0.3750
    0.6875    1.0000    0.3125
    0.7500    1.0000    0.2500
    0.8125    1.0000    0.1875
    0.8750    1.0000    0.1250
    0.9375    1.0000    0.0625
    1.0000    1.0000         0
    1.0000    0.9375         0
    1.0000    0.8750         0
    1.0000    0.8125         0
    1.0000    0.7500         0
    1.0000    0.6875         0
    1.0000    0.6250         0
    1.0000    0.5625         0
    1.0000    0.5000         0
    1.0000    0.4375         0
    1.0000    0.3750         0
    1.0000    0.3125         0
    1.0000    0.2500         0
    1.0000    0.1875         0
    1.0000    0.1250         0
    1.0000    0.0625         0
    1.0000         0         0
    0.9375         0         0];

colormap(cmap);

%Axes
xlabel(ax, 'x [m]')
ylabel(ax, 'y [m]')
zlabel(ax, 'dB');

ylim(ax, [min(scanningPointsY(:)) max(scanningPointsY(:))])
xlim(ax, [min(scanningPointsX(:)) max(scanningPointsX(:))])
zlim(ax, [0 maxDynamicRange])

fig.Color = [1 1 1];
ax.Color = [1 1 1];
ax.XColor = [1 1 1]*0;
ax.YColor = [1 1 1]*0;
ax.ZColor = [1 1 1]*0;

if maxDynamicRange <= 30
    dynamicRangeTickStep = 5;
else
    dynamicRangeTickStep = 10;
end
ax.ZTick = 0:dynamicRangeTickStep:maxDynamicRange;


daspect(ax, [1 1 maxDynamicRange/max(max(scanningPointsX(:)))])
box(ax, 'off')
grid(ax, 'minor')

%Add dynamic range slider
range = [0.01 maxDynamicRange];
dynamicRangeSlider = uicontrol('style', 'slider', ...
    'Units', 'normalized',...
    'position', [0.92 0.18 0.03 0.6],...
    'value', log10(dynamicRange),...
    'min', log10(range(1)),...
    'max', log10(range(2)));
addlistener(dynamicRangeSlider,'ContinuousValueChange',@(obj, evt) changeDynamicRange(obj, evt, 10^obj.Value, steeredResponsePlot));

%Set defaults
changeView(ax, ax, display)
changeDynamicRange(ax, ax, dynamicRange, steeredResponsePlot)

%Context menu to change 2D/3D view
cmFigure = uicontextmenu;
uimenu('Parent', cmFigure, 'Label', '2D', 'Callback',{ @changeView, '2D' });
uimenu('Parent', cmFigure, 'Label', '3D', 'Callback',{ @changeView, '3D' });
ax.UIContextMenu = cmFigure;
steeredResponsePlot.UIContextMenu = cmFigure;

    function changeDynamicRange(~, ~, selectedDynamicRange, steeredResponsePlot)
        dynamicRange = selectedDynamicRange;
        steeredResponsePlot.ZData = S+dynamicRange;
        
        caxis(ax, [0 dynamicRange]);
        zlim(ax, [0 maxDynamicRange])
        title(ax, ['Dynamic range: ' sprintf('%0.2f', dynamicRange) ' dB'], 'fontweight', 'normal','Color',[0 0 0]);
    end

    function changeView(~, ~, selectedView)
        display = selectedView;
        if strcmp(display,'2D')
            view(ax, [0 90])
        else
            %ax.CameraPosition = [20, 12, 700];
            %ax.CameraUpVector = [0 1 0];
            view(ax, [30 30])
        end
    end

end
