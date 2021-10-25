function [] = plotBeampatternSpherical(xPos, yPos, zPos, elementWeights)
%plotBeampatternSpherical - plots the beampattern for various frequencies
%
%plotBeampatternSpherical(xPos, yPos, zPos, elementWeights)
%
%IN
%xPos                - 1xP vector of x-positions [m]
%yPos                - 1xP vector of y-positions [m]
%zPos                - 1xP vector of z-positions [m]
%elementWeights      - 1xP vector of element weights (optional)
%
%OUT
%[]                  - The figure plot
%
%Created by J?rgen Grythe
%Last updated 2017-08-02


%If no weights are given use uniform weighting
if ~exist('elementWeights','var')
    elementWeights = ones(1, numel(xPos));
end


%Default values
maxDynamicRange = 30;
displayTheme = 'White';

f = 1e3;
c = 340;

%Initialise with half sphere view and omnidirectional mics
thetaSteeringAngle = 0;
phiSteeringAngle = 0;
phiScanningAngles = 0:2:180;
thetaScanningAngles = -180:1:180;
microphoneType = 'omni';
sphereView = 'half';

beamPattern = 0;
u = 0;
v = 0;
w = 0;

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
fAlpha = 0.35;
ax.View = [30, 20];

%Default colormap for the beampattern
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
colormap(fig, cmap);

%Create context menu
cm = uicontextmenu;
cmDirectivity = uimenu('Parent', cm, 'Label', 'Microphone type');
uimenu('Parent', cmDirectivity, 'Label', 'Omni', 'Callback', { @setMicDirectivity });
uimenu('Parent', cmDirectivity, 'Label', 'Cardioid', 'Callback', { @setMicDirectivity });
cmView = uimenu('Parent', cm, 'Label', 'View');
uimenu('Parent', cmView, 'Label', 'Full sphere', 'Callback', { @changeView });
uimenu('Parent', cmView, 'Label', 'Half sphere', 'Callback', { @changeView });
cmTheme = uimenu('Parent', cm, 'Label', 'Color theme');
uimenu('Parent', cmTheme, 'Label', 'Black', 'Callback',{ @setTheme, 'Black' });
uimenu('Parent', cmTheme, 'Label', 'White', 'Callback',{ @setTheme, 'White' });

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
    'min', 0.1e3,...
    'max', 15e3);
addlistener(frequencySlider, 'ContinuousValueChange', @(obj,evt) calculateBeamPattern(obj, evt, 'frequency') );
txtF = annotation('textbox', [0.52, 0.115, 0, 0], 'string', 'f');

dynamicRangeSlider = uicontrol('style', 'slider', ...
    'Units', 'normalized',...
    'position', [0.55 0.01 0.3 0.04],...
    'value', maxDynamicRange,...
    'min', 0.01,...
    'max', 60);
addlistener(dynamicRangeSlider, 'ContinuousValueChange', @(obj,evt) calculateBeamPattern(obj, evt, 'dynamicRange') );
txtdB = annotation('textbox', [0.5, 0.065, 0, 0], 'string', 'dB');


%Plot the beampattern
calculateBeamPattern(fig, fig, 'init')

%Set default theme and orientation of the figure
setTheme(fig, fig, displayTheme);

%Enable the context menu regardless of right clicking on figure, axes or plot
ax.UIContextMenu = cm;
fig.UIContextMenu = cm;
spherePlot.UIContextMenu = cm;
circlePlot.UIContextMenu = cm;
bpPlot.UIContextMenu = cm;



    %Function to calculate and plot the beampattern
    function calculateBeamPattern(obj, ~, type)
        
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
            [beamPattern, u, v, w] = arrayFactor(xPos, yPos, zPos, elementWeights, f, c, thetaScanningAngles, ...
                phiScanningAngles, thetaSteeringAngle, phiSteeringAngle);
            
            %Multiply with microphone directivity if it exist
            if strcmp(microphoneType, 'cardioid')
                elementResponse = 0.5 + 0.5*cos(thetaScanningAngles*pi/180)';
                beamPattern = beamPattern.*elementResponse;
            end
            
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
        
        %Create spherical beampattern representation
        beampatternDynamicRange = beamPattern + maxDynamicRange;
        beampatternDynamicRange(beampatternDynamicRange < 0) = 0;
        
        xx = (beampatternDynamicRange) .* u;
        yy = (beampatternDynamicRange) .* v;
        zz = (beampatternDynamicRange) .* w;
        
        %Interpolate for increased resolution
        interpolationFactor = 2;
        interpolationMethod = 'spline';
        
        xx = interp2(xx, interpolationFactor, interpolationMethod);
        yy = interp2(yy, interpolationFactor, interpolationMethod);
        zz = interp2(zz, interpolationFactor, interpolationMethod);
        beampatternDynamicRange = interp2(beampatternDynamicRange, interpolationFactor, interpolationMethod);
        
        %Plot the beampattern        
        bpPlot = surf(ax, xx, yy, zz);
        bpPlot.EdgeColor = 'none';
        
        %Scale the figure
        if strcmp(sphereView, 'half')
            ax.ZLim = [0 maxDynamicRange];
        else
            ax.ZLim = [-maxDynamicRange maxDynamicRange];
        end
        ax.XLim = [-maxDynamicRange maxDynamicRange];
        ax.YLim = [-maxDynamicRange maxDynamicRange];
        
        %Set coloring as max extent, not max z-value
        bpPlot.CData = beampatternDynamicRange;
        caxis(ax, [0 maxDynamicRange])
        
        %Enable contextmenu
        spherePlot.UIContextMenu = cm;
        circlePlot.UIContextMenu = cm;
        bpPlot.UIContextMenu = cm;
        
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
    
    %Function to change between omni and cardiod microphones
    function setMicDirectivity(obj, ~)
        if strcmp(obj.Label, 'Omni')
            microphoneType = 'omni';
        else
            microphoneType = 'cardioid';
        end
        calculateBeamPattern(fig, fig, 'null')   
    end
    
    %Function to change between full sphere view og half sphere
    function changeView(obj, ~)
        if strcmp(obj.Label, 'Full sphere')
            thetaScanningAngles = -180:1:180;
            sphereView = 'full';
        else
            thetaScanningAngles = -90:1:90;
            sphereView = 'half';
        end
        calculateBeamPattern(fig, fig, 'null')  
    end

    %Function to change between black and white theme
    function setTheme(~, ~, selectedTheme)
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
    end

end
