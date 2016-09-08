function [] = plotSteeredResponseUV(S, u, v, maxDynamicRange, scaleView, displayTheme, displayStyle)
%plotSteeredResponseUV - plot the steered response in UV-space
%
%Plots the steered response with a slider bar in either linear or
%logarithmic scale and in black or white theme. Right click anywhere in the
%figure to change between 2D and 3D view and white or black theme.
%
%plotSteeredResponse(S, u, v, maxDynamicRange, scaleView, displayTheme, displayStyle)
%
%IN
%S               - NxM matrix of delay-and-sum steered response power
%u               - NxM matrix of u coordinates in UV space [sin(theta)*cos(phi)]  
%v               - NxM matrix of v coordinates in UV space [sin(theta)*sin(phi)] 
%maxDynamicRange - max dynamic range in decibels in the image (optional)
%scaleView       - slider scale, use 'lin' or 'log' (optional)
%displayTheme    - color theme, use 'white' or 'black' (optional)
%displayStyle    - view style, use '2D' or '3D' (optional)
%
%OUT
%[]              - The figure plot
%
%Created by J?rgen Grythe, Squarehead Technology AS
%Last updated 2016-09-07

if ~exist('displayStyle','var')
    displayStyle = '2D';
end

if ~exist('displayTheme','var')
    displayTheme = 'black';
end

if ~exist('scaleView','var')
    scaleView = 'log';
end

if ~exist('maxDynamicRange','var')
    maxDynamicRange = 60;
end

%Interpolate for higher resolution
interpolationFactor = 2;
interpolationMethod = 'spline';

S = interp2(S, interpolationFactor, interpolationMethod);
u = interp2(u, interpolationFactor, interpolationMethod);
v = interp2(v, interpolationFactor, interpolationMethod);

%The input is a power signal, normalize and convert to decibel
S = abs(S)/max(max(abs(S)));
S = 10*log10(S);
S(S<-maxDynamicRange) = -maxDynamicRange;

%Default display value
defaultDisplayValue = 6;
if defaultDisplayValue > maxDynamicRange
    defaultDisplayValue = maxDynamicRange/2;
end


%Plot the steered response
fig = figure;
ax = axes;


steeredResponsePlot = surf(ax, u, v, S, 'edgecolor', 'none', 'FaceAlpha', 0.8);


xlabel(ax, 'u = sin(\theta)cos(\phi)')
ylabel(ax, 'v = sin(\theta)sin(\phi)')
t = title(['Dynamic range: ' sprintf('%0.2f', defaultDisplayValue) ' dB'], 'FontWeight', 'normal');
axis square
ax.MinorGridLineStyle = '-';
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';
ax.ZMinorGrid = 'on';
ax.Box = 'on';
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.ZTickLabel = [];

%Set display style
if isequal(displayStyle, '2D')
    setOrientation(fig, fig, '2D')
elseif isequal(displayStyle, '3D')
    setOrientation(fig, fig, '3D')
else
    error('Use 2D or 3D for displayStyle')
end

%Set color theme
if isequal(displayTheme,'black')
    setTheme(fig, fig, 'Black');
elseif isequal(displayTheme,'white')
    setTheme(fig, fig, 'White');
else
    error('Use black or white for displayStyle')
end


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
topMenuOrientation = uimenu('Parent',cm,'Label','Orientation');
topMenuTheme = uimenu('Parent',cm,'Label','Theme');
uimenu('Parent',topMenuOrientation, 'Label', '2D', 'Callback',{ @setOrientation, '2D' });
uimenu('Parent',topMenuOrientation, 'Label', '3D', 'Callback',{ @setOrientation, '3D' });
uimenu('Parent',topMenuTheme, 'Label', 'Black', 'Callback',{ @setTheme, 'Black' });
uimenu('Parent',topMenuTheme, 'Label', 'White', 'Callback',{ @setTheme, 'White' });

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


    %Function to change between black and white theme
    function setTheme(~, ~, selectedTheme)
        cmap = colormap;
        if strcmp(selectedTheme,'Black')
            fig.Color = 'k';
            t.Color = 'w';
            cmap(1,:) = [1 1 1]*0.2;
            ax.Color = [0 0 0];
            ax.XColor = [1 1 1];
            ax.YColor = [1 1 1];
            ax.ZColor = [1 1 1];
            ax.MinorGridColor = [1 1 1];
        elseif strcmp(selectedTheme,'White')
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