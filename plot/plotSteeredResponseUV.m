function [] = plotSteeredResponseUV(S, u, v, w, projection, scaleView, displayTheme, displayStyle)
%plotSteeredResponseUV - plot the steered response in UV or UVW-space
%
%Plots the steered response with a slider bar in either linear or
%logarithmic scale and in black or white theme. Right click anywhere in the
%figure to change between 2D and 3D view and white or black theme.
%
%plotSteeredResponseUV(S, u, v, w, projection, scaleView, displayTheme, displayStyle)
%
%IN
%S               - NxM matrix of delay-and-sum steered response power
%u               - NxM matrix of u coordinates in UV space [sin(theta)*cos(phi)]
%v               - NxM matrix of v coordinates in UV space [sin(theta)*sin(phi)]
%w               - NxM matrix of w coordinates in UV space [cos(theta)]
%projection      - 'uv' for UV space (2D arrays), and 'uvw' or UVW space (3D arrays)
%scaleView       - slider scale, use 'lin' or 'log' (optional)
%displayTheme    - color theme, use 'white' or 'black' (optional)
%displayStyle    - view style, use '2D' or '3D' (optional)
%
%OUT
%[]              - The figure plot
%
%Created by J?rgen Grythe
%Last updated 2016-12-07

if ~exist('displayStyle', 'var')
    displayStyle = '2D';
end

if ~exist('displayTheme', 'var')
    displayTheme = 'black';
end

if ~exist('scaleView', 'var')
    scaleView = 'log';
end

if ~exist('projection', 'var')
    projection = 'uv';
end

defaultDisplayValue = 6;
maxDynamicRange = 50;

%Interpolate for higher resolution
interpolationFactor = 2;
interpolationMethod = 'spline';

S = interp2(S, interpolationFactor, interpolationMethod);
u = interp2(u, interpolationFactor, interpolationMethod);
v = interp2(v, interpolationFactor, interpolationMethod);
w = interp2(w, interpolationFactor, interpolationMethod);

%The input is a power signal, normalize and convert to decibel
S = abs(S)/max(max(abs(S)));
S = 10*log10(S);
S(S<-maxDynamicRange) = -maxDynamicRange;

%Plot the steered response in either UV or UVW space
fig = figure;
ax = axes;

steeredResponsePlot = surf(ax, u, v, w, S, 'edgecolor', 'none', 'FaceAlpha', 0.7);

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


xlabel(ax, 'u = sin(\theta)cos(\phi)')
ylabel(ax, 'v = sin(\theta)sin(\phi)')
t = title(['Dynamic range: ' sprintf('%0.2f', defaultDisplayValue) ' dB'], 'FontWeight', 'normal');
axis square
ax.MinorGridLineStyle = '-';
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';
ax.ZMinorGrid = 'on';
ax.Box = 'on';
ax.XTick = [-1 -0.5 0 0.5 1];
ax.YTick = [-1 -0.5 0 0.5 1];
ax.XLim = [-1 1];
ax.YLim = [-1 1];


%Set display style, projection and color theme
setOrientation(fig, fig, displayStyle)
setProjection(fig, fig, projection)
setTheme(fig, fig, displayTheme)


%Just show color from defaultDisplayValue up to dBmax
caxis([-defaultDisplayValue 0])


%Add slider that goes from 0.01 dB up to dBmax and changes color/title
range = [0.01 maxDynamicRange];
if isequal(scaleView,'log')
    h = uicontrol('style', 'slider', ...
        'Units', 'normalized',...
        'position', [0.9 0.1 0.03 0.6],...
        'value', log10(defaultDisplayValue),...
        'min', log10(range(1)),...
        'max', log10(range(2)));
    addlistener(h,'ContinuousValueChange',@(hObject,eventdata) caxis([-10^hObject.Value 0]));
    addlistener(h,'ContinuousValueChange',@(hObject,eventdata) title(['Dynamic range: ' sprintf('%0.2f', 10^hObject.Value) ' dB'],'fontweight','normal'));
    
elseif isequal(scaleView,'lin')
    h = uicontrol('style', 'slider', ...
        'Units', 'normalized',...
        'position', [0.9 0.1 0.03 0.6],...
        'value', defaultDisplayValue,...
        'min', range(1),...
        'max', range(2));
    addlistener(h,'ContinuousValueChange',@(hObject,eventdata) caxis([-hObject.Value 0]));
    addlistener(h,'ContinuousValueChange',@(hObject,eventdata) title(['Dynamic range: ' sprintf('%0.2f', hObject.Value) ' dB'],'fontweight','normal'));
    
else
    error('Use log or lin for scale value')
end


%Create context menu (for easy switching between orientation and theme)
cm = uicontextmenu;
topMenuOrientation = uimenu('Parent',cm,'Label', 'Orientation');
topMenuProjection = uimenu('Parent',cm,'Label', 'Projection');
topMenuTheme = uimenu('Parent',cm,'Label','Theme');
uimenu('Parent',topMenuOrientation, 'Label', '2D', 'Callback',{ @setOrientation, '2D' });
uimenu('Parent',topMenuOrientation, 'Label', '3D', 'Callback',{ @setOrientation, '3D' });
uimenu('Parent',topMenuProjection, 'Label', 'UV', 'Callback',{ @setProjection, 'uv' });
uimenu('Parent',topMenuProjection, 'Label', 'UVW', 'Callback',{ @setProjection, 'uvw' });
uimenu('Parent',topMenuTheme, 'Label', 'Black', 'Callback',{ @setTheme, 'black' });
uimenu('Parent',topMenuTheme, 'Label', 'White', 'Callback',{ @setTheme, 'white' });

%Enable the context menu regardless of right clicking on figure, axes or plot
ax.UIContextMenu = cm;
steeredResponsePlot.UIContextMenu = cm;
fig.UIContextMenu = cm;

    %Function to change between 2D and 3D in plot
    function setOrientation(~, ~, selectedOrientation)
        if strcmp(selectedOrientation, '2D')
            view(ax, 0, 90)
        elseif strcmp(selectedOrientation, '3D')
            view(ax, 40, 40)
        else
            error('Use 2D or 3D for displayStyle')
        end
        
    end

    %Function to change between UV and UVW space in plot
    function setProjection(~, ~, selectedProjection)
        if strcmp(selectedProjection, 'uv')
            steeredResponsePlot.XData = u;
            steeredResponsePlot.YData = v;
            steeredResponsePlot.ZData = S;
            
            ax.ZTick = -maxDynamicRange:10:0;
            ax.ZLim = [-maxDynamicRange 0];
            zlabel(ax, 'dB')
            
        elseif strcmp(selectedProjection, 'uvw')
            steeredResponsePlot.XData = u;
            steeredResponsePlot.YData = v;
            steeredResponsePlot.ZData = w;
            steeredResponsePlot.CData = S;
            
            ax.ZTick = [-1 -0.5 0 0.5 1];
            ax.ZLim = [-1 1];
            zlabel(ax, 'w = cos(\theta)')
        else
            error('Use uv or uvw for projection')
        end
        
    end

    %Function to change between black and white theme
    function setTheme(~, ~, selectedTheme)
        cmap = colormap;
        if strcmp(selectedTheme, 'black')
            fig.Color = 'k';
            t.Color = 'w';
            cmap(1,:) = [1 1 1]*0.2;
            ax.Color = [0 0 0];
            ax.XColor = [1 1 1];
            ax.YColor = [1 1 1];
            ax.ZColor = [1 1 1];
            ax.MinorGridColor = [1 1 1];
        elseif strcmp(selectedTheme, 'white')
            fig.Color = 'w';
            t.Color = 'k';
            cmap(1,:) = [1 1 1]*0.9;
            ax.Color = [1 1 1];
            ax.XColor = [0 0 0];
            ax.YColor = [0 0 0];
            ax.ZColor = [0 0 0];
            ax.MinorGridColor = [0 0 0];
        else
            error('Use black or white for displayStyle')
        end
        colormap(ax, cmap);
    end

end
