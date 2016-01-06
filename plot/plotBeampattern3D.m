function [] = plotBeampattern3D(xPos, yPos, w)
%plotBeampattern3D - plots the beampattern for various frequencies
%
%plotBeampattern3D(xPos, yPos, w)
%
%IN
%xPos                - 1xP vector of x-positions [m]
%yPos                - 1xP vector of y-positions [m]
%w                   - 1xP vector of element weights
%
%OUT
%[]                  - The figure plot
%
%Created by Jørgen Grythe, Norsonic AS
%Last updated 2016-01-06


displayStyle = '3D';
displayTheme = 'Black';
maxDynamicRange = 50;

f = 3e3;
c = 340;

thetaSteeringAngle = 0;
phiSteeringAngle = 0;
thetaScanningAngles = -90:1:90;
phiScanningAngles = 0:1:180;
beamPattern = 0;
thetaScanningAnglesRadians = 0;
phiScanningAnglesRadians = 0;


%Prepare the figure
fig = figure;
ax = axes;
t = title(['Dynamic range: ' sprintf('%0.2f', maxDynamicRange) ...
    ' dB, \theta = ' sprintf('%0.0f', thetaSteeringAngle) ...
    ', \phi = ' sprintf('%0.0f', phiSteeringAngle) ...
    ', f = ' sprintf('%0.1f', f*1e-3) ' kHz'],'fontweight','normal');
ax.MinorGridLineStyle = '-';
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';
ax.ZMinorGrid = 'on';
ax.Box = 'on';
ax.XTickLabel = [];
ax.YTickLabel = [];
ax.NextPlot = 'replacechildren';
axis(ax, 'equal')
hold(ax, 'on')
fColor = [1 1 1];
fAlpha = 0.25;



%Create context menu (for easy switching between orientation and theme)
cm = uicontextmenu;
topMenuOrientation = uimenu('Parent',cm,'Label','Orientation');
topMenuTheme = uimenu('Parent',cm,'Label','Theme');
uimenu('Parent',topMenuOrientation, 'Label', '2D', 'Callback',{ @setOrientation, '2D' });
uimenu('Parent',topMenuOrientation, 'Label', '3D', 'Callback',{ @setOrientation, '3D' });
uimenu('Parent',topMenuTheme, 'Label', 'Black', 'Callback',{ @setTheme, 'Black' });
uimenu('Parent',topMenuTheme, 'Label', 'White', 'Callback',{ @setTheme, 'White' });

%Generate a sphere to be displayed over the beampattern
[sx, sy, sz] = sphere(100);

%Create sliders to change dynamic range, scanning angle and frequency
thetaAngleSlider = uicontrol('style', 'slider', ...
    'Units', 'normalized',...
    'position', [0.2 0.06 0.3 0.04],...
    'value', thetaSteeringAngle,...
    'min', -90,...
    'max', 90);
addlistener(thetaAngleSlider, 'ContinuousValueChange', @(obj,evt) calculateBeamPattern(obj, evt, 'thetaAngle') );
txtTheta = annotation('textbox', [0.16, 0.115, 0, 0], 'string', '\theta');

phiAngleSlider = uicontrol('style', 'slider', ...
    'Units', 'normalized',...
    'position', [0.2 0.01 0.3 0.04],...
    'value', phiSteeringAngle,...
    'min', -180,...
    'max', 180);
addlistener(phiAngleSlider, 'ContinuousValueChange', @(obj,evt) calculateBeamPattern(obj, evt, 'phiAngle') );
txtPhi = annotation('textbox', [0.16, 0.065, 0, 0], 'string', '\phi');

frequencySlider = uicontrol('style', 'slider', ...
    'Units', 'normalized',...
    'position', [0.55 0.06 0.3 0.04],...
    'value', f,...
    'min', 0.2e3,...
    'max', 10e3);
addlistener(frequencySlider, 'ContinuousValueChange', @(obj,evt) calculateBeamPattern(obj, evt, 'frequency') );
txtF = annotation('textbox', [0.52, 0.115, 0, 0], 'string', 'f');

dynamicRangeSlider = uicontrol('style', 'slider', ...
    'Units', 'normalized',...
    'position', [0.55 0.01 0.3 0.04],...
    'value', maxDynamicRange,...
    'min', 0.01,...
    'max', 80);
addlistener(dynamicRangeSlider, 'ContinuousValueChange', @(obj,evt) calculateBeamPattern(obj, evt, 'dynamicRange') );
txtdB = annotation('textbox', [0.5, 0.065, 0, 0], 'string', 'dB');


%Plot the beampattern
calculateBeamPattern(fig, fig, 'init')

%Set default theme and orientation of the figure
setTheme(fig, fig, displayTheme);
setOrientation(fig, fig, displayStyle)


%Enable the context menu regardless of right clicking on figure, axes or plot
ax.UIContextMenu = cm;
fig.UIContextMenu = cm;
spherePlot.UIContextMenu = cm;
circlePlot.UIContextMenu = cm;
bpPlot.UIContextMenu = cm;






    %Function to calculate and plot the beampattern
    function calculateBeamPattern(obj, evt, type)
        
        if ~strcmp(type, 'init')
            delete(bpPlot)
        else
            %Plot the half sphere and a circle (at the bottom)
            spherePlot = surf(ax, sx*maxDynamicRange,sy*maxDynamicRange,sz*maxDynamicRange, ...
                'edgecolor','none', 'FaceColor', fColor, 'FaceAlpha', fAlpha);
            circlePlot = plot(ax, cos(0:pi/50:2*pi)*maxDynamicRange, sin(0:pi/50:2*pi)*maxDynamicRange, ...
                'Color', fColor);
        end
        
        if ~strcmp(type, 'dynamicRange')
            if strcmp(type, 'frequency')
                f = obj.Value;
            elseif strcmp(type, 'thetaAngle')
                thetaSteeringAngle = obj.Value;
            elseif strcmp(type, 'phiAngle')
                phiSteeringAngle = obj.Value;
            end
            
            %Calculating the beampattern
            [beamPattern, thetaScanningAnglesRadians, phiScanningAnglesRadians] = arrayFactor(xPos, yPos, w, f, c, thetaScanningAngles, ...
                phiScanningAngles, thetaSteeringAngle, phiSteeringAngle);
            [phiScanningAnglesRadians, thetaScanningAnglesRadians] = meshgrid(phiScanningAnglesRadians, thetaScanningAnglesRadians);
            beamPattern = 20*log10(beamPattern);
            
        else
            maxDynamicRange = obj.Value;
            delete(spherePlot)
            delete(circlePlot)
            spherePlot = surf(ax, sx*maxDynamicRange,sy*maxDynamicRange,sz*maxDynamicRange, ...
                'edgecolor','none', 'FaceColor', fColor, 'FaceAlpha', fAlpha);
            circlePlot = plot(ax, cos(0:pi/50:2*pi)*maxDynamicRange, sin(0:pi/50:2*pi)*maxDynamicRange, ...
                'Color', fColor);
        end
        
        
        beamPatternDynamicRange = beamPattern + maxDynamicRange;
        
        xx = (beamPatternDynamicRange) .* sin(thetaScanningAnglesRadians) .* cos(phiScanningAnglesRadians);
        yy = (beamPatternDynamicRange) .* sin(thetaScanningAnglesRadians) .* sin(phiScanningAnglesRadians);
        zz = (beamPatternDynamicRange) .* cos(thetaScanningAnglesRadians);
        
        %Interpolate for increased resolution
        interpolationFactor = 2;
        interpolationMethod = 'spline';
        
        xx = interp2(xx, interpolationFactor, interpolationMethod);
        yy = interp2(yy, interpolationFactor, interpolationMethod);
        zz = interp2(zz, interpolationFactor, interpolationMethod);
        
        %Plot the beampattern        
        bpPlot = surf(ax, xx, yy, zz);
        bpPlot.EdgeColor = 'none';
        
        %Enable contextmenu
        spherePlot.UIContextMenu = cm;
        circlePlot.UIContextMenu = cm;
        bpPlot.UIContextMenu = cm;
        
        %Scale the figure
        maxHeight = max(max(zz));
        caxis(ax, [0 maxHeight])
        ax.ZLim = [0 maxDynamicRange];
        ax.XLim = [-maxDynamicRange maxDynamicRange];
        ax.YLim = [-maxDynamicRange maxDynamicRange];
        
        
        %Make dynamic ZTicks and show as decreasing dB
        if maxDynamicRange > 30
            ax.ZTick = fliplr(maxDynamicRange:-10:0);
            ax.ZTickLabel = -fliplr(0:10:maxDynamicRange);
        elseif maxDynamicRange > 15
            ax.ZTick = fliplr(maxDynamicRange:-5:0);
            ax.ZTickLabel = -fliplr(0:5:maxDynamicRange);
        else
            ax.ZTick = fliplr(maxDynamicRange:-2:0);
            ax.ZTickLabel = -fliplr(0:2:maxDynamicRange);
        end
        
        %Change title to display frequency, dynamic range and angle
        t = title(ax, ['Dynamic range: ' sprintf('%0.1f', maxDynamicRange) ...
            ' dB, \theta = ' sprintf('%0.0f', thetaSteeringAngle) ...
            ', \phi = ' sprintf('%0.0f', phiSteeringAngle) ...
            ', f = ' sprintf('%0.1f', f*1e-3) ' kHz'],'fontweight','normal');
    end




    %Function to change between 2D and 3D orientation
    function setOrientation(~, ~, selectedOrientation)
        displayStyle = selectedOrientation;
        if strcmp(selectedOrientation, '2D')
            view(ax, 0, 90)
        elseif strcmp(selectedOrientation, '3D')
            view(ax, 30, 20)
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
            txtTheta.Color = 'w';
            txtPhi.Color = 'w';
            txtF.Color = 'w';
            txtdB.Color = 'w';
            cmap(1,:) = [1 1 1]*0.2;
            ax.Color = [0 0 0];
            ax.XColor = [1 1 1];
            ax.YColor = [1 1 1];
            ax.ZColor = [1 1 1];
            ax.MinorGridColor = [1 1 1];
            fColor = [1 1 1];
            fAlpha = 0.25;
            spherePlot.FaceColor = fColor;
            spherePlot.FaceAlpha = fAlpha;
            circlePlot.Color = fColor;
        elseif strcmp(selectedTheme,'White')
            fig.Color = 'w';
            t.Color = 'k';
            txtTheta.Color = 'k';
            txtPhi.Color = 'k';
            txtF.Color = 'k';
            txtdB.Color = 'k';
            cmap(1,:) = [1 1 1]*0.9;
            ax.Color = [1 1 1];
            ax.XColor = [0 0 0];
            ax.YColor = [0 0 0];
            ax.ZColor = [0 0 0];
            ax.MinorGridColor = [0 0 0];
            fColor = [0 0 0];
            fAlpha = 0.05;
            spherePlot.FaceColor = fColor;
            spherePlot.FaceAlpha = fAlpha;
            circlePlot.Color = fColor;
        else
            error('Use black or white for displayStyle')
        end
        colormap(ax, cmap);
    end

end