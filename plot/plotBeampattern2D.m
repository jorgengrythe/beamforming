function plotBeampattern2D(xPos, yPos, zPos, w, defaultFrequency, defaultDynamicRange, coveringAngles, resolution)
%plotBeampattern2D - plots the beampattern for various frequencies
%
%plotBeampattern2D(xPos, yPos, zPos, w, defaultFrequency, defaultDynamicRange, coveringAngles, resolution)
%
%IN
%xPos                - 1xP vector of x-positions [m]
%yPos                - 1xP vector of y-positions [m]
%zPos                - 1xP vector of z-positions [m]
%w                   - 1xP vector of element weights (optional)
%coveringAngles      - 1x2 vector of max x,y scanning angle (optional)
%defaultFrequency    - Default frequency to be displayed (optional)
%defaultDynamicRange - Default dynamic range to be displayed (optional)
%resolution          - image resolution in degrees (optional)
%
%OUT
%[]                  - The figure plot
%
%Created by J?rgen Grythe
%Last updated 2016-12-196

%Default values
maxDynamicRange = 60;
c = 340;
xPosSource = 0;
yPosSource = 0;

if ~exist('resolution', 'var')
    resolution = 0.5;
end

if ~exist('coveringAngles', 'var')
    coveringAngleX = 45;
    coveringAngleY = 45;
else
    coveringAngleX = coveringAngles(1);
    coveringAngleY = coveringAngles(2);
end

if ~exist('defaultDynamicRange', 'var')
    dynamicRange = 15;
else
    dynamicRange = defaultDynamicRange;
end

if ~exist('defaultFrequency', 'var')
    f = 5e3;
else
    f = defaultFrequency;
end

if max(coveringAngleX, coveringAngleY) > 60
    projection = 'angles';
else
    projection = 'xy';
end

if ~exist('w', 'var')
    w = ones(1, numel(xPos));
end


%Scanning points and steering angle
distanceToScanningPlane = 1;
scanningAxisX = tan((-coveringAngleX:resolution:coveringAngleX)*pi/180);
scanningAxisY = tan((-coveringAngleY:resolution:coveringAngleY)*pi/180);
[scanningPointsY, scanningPointsX] = meshgrid(scanningAxisY,scanningAxisX);

[thetaScanningAngles, phiScanningAngles] = convertCartesianToSpherical(scanningPointsX, scanningPointsY, distanceToScanningPlane);
[thetaSteeringAngle, phiSteeringAngle] = convertCartesianToSpherical(xPosSource, yPosSource, distanceToScanningPlane);

%Calculate beampattern
W = arrayFactor(xPos, yPos, zPos, w, f, c, thetaScanningAngles, phiScanningAngles, thetaSteeringAngle, phiSteeringAngle);
W = 20*log10(W);


fig = figure;
fig.Color = 'w';

ax = axes;

%Plot the response
beampatternPlot = surf(ax, W, ...
                    'EdgeColor','none',...
                    'FaceAlpha',0.6);



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
colorbar

%Add dynamic range slider
range = [0.01 maxDynamicRange];
dynamicRangeSlider = uicontrol('style', 'slider', ...
    'Units', 'normalized',...
    'position', [0.92 0.1 0.03 0.8],...
    'value', dynamicRange,...
    'min', range(1),...
    'max', range(2));
addlistener(dynamicRangeSlider,'ContinuousValueChange',@(obj, evt) changeDynamicRange(obj, evt, obj.Value));


%Add frequency slider
frequencySlider = uicontrol('style', 'slider', ...
    'Units', 'normalized',...
    'position', [0.13 0.03 0.7 0.02],...
    'value', f,...
    'min', 0.1e3,...
    'max', 20e3);
addlistener(frequencySlider, 'ContinuousValueChange', @(obj,evt) changeFrequencyOfSource(obj, evt, obj.Value) );

        
        
%Create context menu (for easy switching between orientation and projection)
cm = uicontextmenu;
topMenuProjection = uimenu('Parent',cm,'Label','Projection');
topMenuOrientation = uimenu('Parent',cm,'Label','Orientation');
uimenu('Parent',topMenuProjection, 'Label', 'angles', 'Callback',{ @changeProjection, 'angles' });
uimenu('Parent',topMenuProjection, 'Label', 'xy', 'Callback',{ @changeProjection, 'xy' });
uimenu('Parent',topMenuOrientation, 'Label', '2D', 'Callback',{ @changeOrientation, '2D' });
uimenu('Parent',topMenuOrientation, 'Label', '3D', 'Callback',{ @changeOrientation, '3D' });

%Change dynamic range to default
changeDynamicRange(ax, ax, dynamicRange)

%Set orientation
changeOrientation(ax, ax, '2D')

%Change projection
changeProjection(ax, ax, projection)

%Enable context menu and button down for axes and plot
ax.UIContextMenu = cm;
beampatternPlot.UIContextMenu = cm;
ax.ButtonDownFcn = {@changeSteeringAngles};
    
    %Function to be used by dynamic range slider
    function changeDynamicRange(~, ~, selectedDynamicRange)
        dynamicRange = selectedDynamicRange;
        beampatternPlot.ZData = W+dynamicRange;
        
        caxis(ax, [0 dynamicRange]);
        zlim(ax, [0 dynamicRange+0.1])
        title(ax, ['Frequency: ' sprintf('%0.2f', f*1e-3) ' kHz, dynamic range: ' sprintf('%0.2f', dynamicRange) ' dB'], 'fontweight', 'normal','Color',[0 0 0]);
        
        %Make dynamic ZTicks and show as decreasing dB
        if dynamicRange >= 30
            ax.ZTick = fliplr(dynamicRange:-10:0);
            ax.ZTickLabel = -fliplr(0:10:dynamicRange);
        elseif dynamicRange >= 15
            ax.ZTick = fliplr(dynamicRange:-5:0);
            ax.ZTickLabel = -fliplr(0:5:dynamicRange);
        else
            ax.ZTick = fliplr(dynamicRange:-2:0);
            ax.ZTickLabel = -fliplr(0:2:dynamicRange);
        end
    end

    %Function to change between 2D and 3D orientation
    function changeOrientation(~, ~, selectedOrientation)
        if strcmp(selectedOrientation, '2D')
            view(ax, 0, 90)
        else
            view(ax, 30, 20)
        end
    end
    
    %Function to switch between uniformly spaced angles or xy
    function changeProjection(~, ~, selectedProjection)
        projection = selectedProjection;
        tickAnglesX = -coveringAngleX:5:coveringAngleX;
        tickAnglesY = -coveringAngleY:5:coveringAngleY;
        
        switch projection
            case 'angles'
                beampatternPlot.XData = atan(scanningPointsX)*180/pi;
                beampatternPlot.YData = atan(scanningPointsY)*180/pi;

                ax.XTick = tickAnglesX;
                ax.YTick = tickAnglesY;
                
                axis equal
                axis([-coveringAngleX coveringAngleX -coveringAngleY coveringAngleY])
                
                daspect(ax,[1 1 1])
                
            case 'xy'
                beampatternPlot.XData = scanningPointsX;
                beampatternPlot.YData = scanningPointsY;

                ax.XTick = tan(tickAnglesX*pi/180);
                ax.YTick = tan(tickAnglesY*pi/180);
                
                axis equal
                axis([-tan(coveringAngleX*pi/180) tan(coveringAngleX*pi/180) -tan(coveringAngleY*pi/180) tan(coveringAngleY*pi/180)])
                
                
                daspect(ax,[1 1 maxDynamicRange])
        end
        
        ax.XTickLabel = tickAnglesX;
        ax.YTickLabel = tickAnglesY;
    end
    
    %Function to change frequency
    function changeFrequencyOfSource(~, ~, selectedFrequency)
        
        f = selectedFrequency;
        updateBeampatternPlot()
        
        title(ax, ['Frequency: ' sprintf('%0.2f', f*1e-3) ' kHz, dynamic range: ' sprintf('%0.2f', dynamicRange) ' dB'], 'fontweight', 'normal','Color',[0 0 0]);
    end

    function changeSteeringAngles(obj, eventData)
        
        if ~strcmp(obj.Parent.SelectionType,'alt')
            
            switch projection
                case 'xy'
                    xPosSource = eventData.IntersectionPoint(1);
                    yPosSource = eventData.IntersectionPoint(2);
                    
                case 'angles'
                    xPosSource = tan(eventData.IntersectionPoint(1)*pi/180);
                    yPosSource = tan(eventData.IntersectionPoint(2)*pi/180);
            end
            
            [thetaSteeringAngle, phiSteeringAngle] = convertCartesianToSpherical(xPosSource, yPosSource, distanceToScanningPlane);
            updateBeampatternPlot()
        end
    end

    function updateBeampatternPlot()
        W = arrayFactor(xPos, yPos, zPos, w, f, c, thetaScanningAngles, phiScanningAngles, thetaSteeringAngle, phiSteeringAngle);
        W = 20*log10(W);
        
        beampatternPlot.ZData = W+dynamicRange;
    end


end
