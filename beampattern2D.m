function beampattern2D(xPos, yPos, w, f, coveringAngle, sourceAngleX, sourceAngleY, amplitudes)


%Default values
projection = 'angles';
dynamicRange = 15;
maxDynamicRange = 30;
c = 340;
fs = 44.1e3;

if ~exist('w', 'var')
    w = ones(1, numel(xPos));
end

if ~exist('f', 'var')
    f = 3e3;
end

if ~exist('coveringAngle', 'var')
    coveringAngleX = 45;
    coveringAngleY = 45;
else
    coveringAngleX = coveringAngle(1);
    coveringAngleY = coveringAngle(2);
end

%(x,y) position of scanning points
distanceToScanningPlane = 1;
maxScanningPlaneExtentX = tan(coveringAngleX*pi/180)*2;
maxScanningPlaneExtentY = tan(coveringAngleY*pi/180)*2;

numberOfScanningPointsX = coveringAngleX*3;
numberOfScanningPointsY = coveringAngleY*3;

scanningAxisX = -maxScanningPlaneExtentX/2:maxScanningPlaneExtentX/(numberOfScanningPointsX-1):maxScanningPlaneExtentX/2;
scanningAxisY = maxScanningPlaneExtentY/2:-maxScanningPlaneExtentY/(numberOfScanningPointsY-1):-maxScanningPlaneExtentY/2;

[scanningPointsY, scanningPointsX] = meshgrid(scanningAxisY,scanningAxisX);


%(x,y) position of sources
if ~exist('sourceAngleX', 'var')
    xPosSource = 0;
else
    xPosSource = tan(sourceAngleX*pi/180);
end
if ~exist('sourceAngleY', 'var')
    yPosSource = 0;
else
    yPosSource = tan(sourceAngleY*pi/180);
end
if ~exist('amplitudes', 'var')
    amplitudes = zeros(1, numel(xPos));
end


%Create input signal
inputSignal = createSignal(xPos, yPos, f, c, fs, xPosSource, yPosSource, distanceToScanningPlane, amplitudes);

%Calculate steered response
S = calculateSteeredResponse(xPos, yPos, w, inputSignal, f, c, scanningPointsX, scanningPointsY, distanceToScanningPlane, numberOfScanningPointsX, numberOfScanningPointsY);

%Convert plotting grid to uniformely spaced angles
%[x, y] = meshgrid(scanningAxisX, scanningAxisY);
[x, y] = meshgrid(linspace(-maxScanningPlaneExtentX/2,maxScanningPlaneExtentX/2,size(S,2)), ...
    linspace(-maxScanningPlaneExtentY/2,maxScanningPlaneExtentY/2,size(S,1)));

fig = figure;
fig.Color = 'w';

ax = axes;
xlabel(ax, 'Angle in degree');

%Plot the response
steeredResponsePlot = surf(ax, S, ...
                    'EdgeColor','none',...
                    'FaceAlpha',0.6);
                
%Change projection
changeProjection(ax, ax, 'angles')



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
addlistener(dynamicRangeSlider,'ContinuousValueChange',@(obj, evt) changeDynamicRange(obj, evt, obj.Value, steeredResponsePlot));


%Add frequency slider
frequencySlider = uicontrol('style', 'slider', ...
    'Units', 'normalized',...
    'position', [0.13 0.03 0.78 0.02],...
    'value', f,...
    'min', 0.1e3,...
    'max', 20e3);
addlistener(frequencySlider, 'ContinuousValueChange', @(obj,evt) changeFrequencyOfSource(obj, evt, obj.Value, steeredResponsePlot) );

        
        
%Create context menu (for easy switching between orientation and projection)
cm = uicontextmenu;
topMenuProjection = uimenu('Parent',cm,'Label','Projection');
topMenuOrientation = uimenu('Parent',cm,'Label','Orientation');
uimenu('Parent',topMenuProjection, 'Label', 'angles', 'Callback',{ @changeProjection, 'angles' });
uimenu('Parent',topMenuProjection, 'Label', 'xy', 'Callback',{ @changeProjection, 'xy' });
uimenu('Parent',topMenuOrientation, 'Label', '2D', 'Callback',{ @changeOrientation, '2D' });
uimenu('Parent',topMenuOrientation, 'Label', '3D', 'Callback',{ @changeOrientation, '3D' });
ax.UIContextMenu = cm;
steeredResponsePlot.UIContextMenu = cm;

%Change dynamic range to default
changeDynamicRange(ax, ax, dynamicRange, steeredResponsePlot)

%Set orientation
changeOrientation(ax, ax, '2D')


    % Convert from cartesian points to polar angles
    function [thetaAngles, phiAngles] = convertCartesianToPolar(xPos, yPos, zPos)
        thetaAngles = atan(sqrt(xPos.^2+yPos.^2)./zPos);
        phiAngles = atan(yPos./xPos);
        
        thetaAngles = thetaAngles*180/pi;
        phiAngles = phiAngles*180/pi;
        phiAngles(xPos<0) = phiAngles(xPos<0) + 180;
        
        thetaAngles(isnan(thetaAngles)) = 0;
        phiAngles(isnan(phiAngles)) = 0;
    end

    %Calculate steering vector for various angles
    function [e, kx, ky] = steeringVector(xPos, yPos, f, c, thetaAngles, phiAngles)
        
        %Change from degrees to radians
        thetaAngles = thetaAngles*pi/180;
        phiAngles = phiAngles*pi/180;
        
        %Wavenumber
        k = 2*pi*f/c;
        
        %Number of elements/sensors in the array
        P = size(xPos,2);
        
        %Changing wave vector to spherical coordinates
        kx = sin(thetaAngles).*cos(phiAngles);
        ky = sin(thetaAngles).*sin(phiAngles);
        
        %Calculate steering vector/matrix
        kxx = bsxfun(@times,kx,reshape(xPos,P,1));
        kyy = bsxfun(@times,ky,reshape(yPos,P,1));
        e = exp(1j*k*(kxx+kyy));
        
    end

    %Generate input signal to all sensors
    function inputSignal = createSignal(xPos, yPos, f, c, fs, xPosSource, yPosSource, zPosSource, amplitudes)
        
        %Get arrival angles from/to sources
        [thetaArrivalAngles, phiArrivalAngles] = convertCartesianToPolar(xPosSource, yPosSource, zPosSource);
        
        %Number of samples to be used
        nSamples = 1e3;
        
        T = nSamples/fs;
        t = 0:1/fs:T-1/fs;
        
        inputSignal = 0;
        for source = 1:numel(thetaArrivalAngles)
            
            %Calculate direction of arrival for the signal for each sensor
            doa = steeringVector(xPos, yPos, f, c, thetaArrivalAngles(source), phiArrivalAngles(source));
            
            %Generate the signal at each microphone
            signal = 10^(amplitudes(source)/20)*doa*exp(1j*2*pi*(f*t+randn(1,nSamples)));
            
            %Total signal equals sum of individual signals
            inputSignal = inputSignal + signal;
        end
        
    end

    %Calculate delay-and-sum or minimum variance power at scanning points
    function S = calculateSteeredResponse(xPos, yPos, w, inputSignal, f, c, scanningPointsX, scanningPointsY, distanceToScanningPlane, numberOfScanningPointsX, numberOfScanningPointsY)
        
        nSamples = numel(inputSignal);
        
        %Get scanning angles from scanning points
        [thetaScanningAngles, phiScanningAngles] = convertCartesianToPolar(scanningPointsX(:)', scanningPointsY(:)', distanceToScanningPlane);
        

        
        %Get steering vector to each point
        e = steeringVector(xPos, yPos, f, c, thetaScanningAngles, phiScanningAngles);
        
        % Multiply input signal by weighting vector
        inputSignal = diag(w)*inputSignal;
        
        %Calculate correlation matrix
        R = inputSignal*inputSignal';
        R = R/nSamples;

        
        %Calculate power as a function of steering vector/scanning angle
        %with either delay-and-sum or minimum variance algorithm
        S = zeros(numberOfScanningPointsY,numberOfScanningPointsX);
        for scanningPointY = 1:numberOfScanningPointsY
            for scanningPointX = 1:numberOfScanningPointsX
                ee = e(:,scanningPointX+(scanningPointY-1)*numberOfScanningPointsX);
                S(scanningPointY,scanningPointX) = ee'*R*ee;
            end
        end
       
        
        S = abs(S)/max(max(abs(S)));
        S = 10*log10(S);
        
        %Interpolate for higher resolution
        interpolationFactor = 2;
        interpolationMethod = 'spline';
        
        S = interp2(S, interpolationFactor, interpolationMethod);
        
    end
    
    %Function to be used by dynamic range slider
    function changeDynamicRange(~, ~, selectedDynamicRange, steeredResponsePlot)
        dynamicRange = selectedDynamicRange;
        steeredResponsePlot.ZData = S+dynamicRange;
        
        caxis(ax, [0 dynamicRange]);
        zlim(ax, [0 dynamicRange+0.1])
        title(ax, ['Frequency: ' sprintf('%0.1f', f*1e-3) ' kHz, dynamic range: ' sprintf('%0.2f', dynamicRange) ' dB'], 'fontweight', 'normal','Color',[0 0 0]);
        
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
                xAngles = atan(x)*180/pi;
                yAngles = atan(y)*180/pi;
                steeredResponsePlot.XData = xAngles;
                steeredResponsePlot.YData = yAngles;

                ax.XTick = tickAnglesX;
                ax.YTick = tickAnglesY;
                
                axis equal
                axis([-coveringAngleX coveringAngleX -coveringAngleY coveringAngleY])
                
            case 'xy'
                steeredResponsePlot.XData = x;
                steeredResponsePlot.YData = y;

                ax.XTick = tan(tickAnglesX*pi/180);
                ax.XTickLabel = tickAnglesX;
                ax.YTick = tan(tickAnglesY*pi/180);
                ax.YTickLabel = tickAnglesY;
                
                axis equal
                axis([-tan(coveringAngleX*pi/180) tan(coveringAngleX*pi/180) -tan(coveringAngleY*pi/180) tan(coveringAngleY*pi/180)])
        end
    end
    
    %Function to change frequency
    function changeFrequencyOfSource(~, ~, selectedFrequency, steeredResponsePlot)
        
        f = selectedFrequency;
        inputSignal = createSignal(xPos, yPos, f, c, fs, xPosSource, yPosSource, distanceToScanningPlane, amplitudes);
        S = calculateSteeredResponse(xPos, yPos, w, inputSignal, f, c, scanningPointsX, scanningPointsY, distanceToScanningPlane, numberOfScanningPointsX, numberOfScanningPointsY);
        
        changeDynamicRange(ax, ax, dynamicRange, steeredResponsePlot)
    end

end