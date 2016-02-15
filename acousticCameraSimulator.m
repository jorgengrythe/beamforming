function [] = acousticCameraSimulator()

%Default values
c = 340;
fs = 44.1e3;
f = 5e3;

array = load('data/arrays/Nor848A-10.mat');
w = array.hiResWeights;
xPos = array.xPos;
yPos = array.yPos;
algorithm = 'DAS';
dynamicRange = 10;
maxDynamicRange = 50;

imageFileColor = imread('data/fig/room.jpg');
imageFileGray = imread('data/fig/roombw.jpg');

fig = figure;
ax = axes('Parent', fig);

% Acoustical coverage / listening points
maxAcousticalCoveringAngleHorizontal = 42;
maxAcousticalCoveringAngleVertical = 30;
distanceToScanningPlane = 3; %[m]
numberOfScanningPointsX = 40;
numberOfScanningPointsY = 30;

maxScanningPlaneExtentX = tan(maxAcousticalCoveringAngleHorizontal*pi/180)*distanceToScanningPlane;
maxScanningPlaneExtentY = tan(maxAcousticalCoveringAngleVertical*pi/180)*distanceToScanningPlane;

scanningAxisX = -maxScanningPlaneExtentX:2*maxScanningPlaneExtentX/(numberOfScanningPointsX-1):maxScanningPlaneExtentX;
scanningAxisY = -maxScanningPlaneExtentY:2*maxScanningPlaneExtentY/(numberOfScanningPointsY-1):maxScanningPlaneExtentY;

% Get all (x,y) points
[scanningPointsY, scanningPointsX] = meshgrid(scanningAxisY,scanningAxisX);

%(x,y) position of sources
%Loudspeakers
xPosSource = [-2.147 -2.147 -2.147 -1.28 -0.3 0.37 1.32 2.18 2.18 2.18];
yPosSource = [0.26 -0.15 -0.55 -0.34 1.47 1.47 -0.33 0.26 -0.15 -0.55];
amplitudes = [0 -100 0 -100 0 -100 0 -100 -100 -100];
zPosSource = distanceToScanningPlane*ones(1,length(xPosSource));

% Line sources for the tv?
% [a, b] = meshgrid(0.1:0.1:1, [-0.8 0.8]);
% xPosSource = [xPosSource b(:)'];
% yPosSource = [yPosSource a(:)'];
% amplitudes = [amplitudes zeros(1,numel(a))];




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


%Create input signal
inputSignal = createSignal(xPos, yPos, f, c, fs, xPosSource, yPosSource, zPosSource, amplitudes);

%Calculate steered response
S = calculateSteeredResponse(xPos, yPos, w, inputSignal, f, c, scanningPointsX, scanningPointsY, distanceToScanningPlane, numberOfScanningPointsX, numberOfScanningPointsY);

%Plot image and steered response
plotImage(imageFileGray, S, amplitudes, xPosSource, yPosSource, scanningPointsX, scanningPointsY, maxScanningPlaneExtentX, maxScanningPlaneExtentY)




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

        
        
        
    %Calculate delay-and-sum power at scanning points
    function S = calculateSteeredResponse(xPos, yPos, w, inputSignal, f, c, scanningPointsX, scanningPointsY, distanceToScanningPlane, numberOfScanningPointsX, numberOfScanningPointsY)
        
        nSamples = numel(inputSignal);
        nSensors = numel(xPos);
        
        %Get scanning angles from scanning points
        [thetaScanningAngles, phiScanningAngles] = convertCartesianToPolar(scanningPointsX(:)', scanningPointsY(:)', distanceToScanningPlane);

        %Get steering vector to each point
        e = steeringVector(xPos, yPos, f, c, thetaScanningAngles, phiScanningAngles);
        
        % Multiply input signal by weighting vector
        inputSignal = diag(w)*inputSignal;
        
        if strcmp('DAS', algorithm)
            % Multiply input signal by weighting vector
            inputSignal = diag(w)*inputSignal;
            
            %Calculate correlation matrix
            R = inputSignal*inputSignal';
            R = R/nSamples;
            useDAS = 1;
        else
            %Calculate correlation matrix
            R = inputSignal*inputSignal';
            R = R + trace(R)/(nSensors^2)*eye(nSensors, nSensors);
            R = R/nSamples;
            R = inv(R);
            useDAS = 0;
        end
        
        %Calculate power as a function of steering vector/scanning angle
        %with either delay-and-sum or minimum variance algorithm
        S = zeros(numberOfScanningPointsY,numberOfScanningPointsX);
        for scanningPointY = 1:numberOfScanningPointsY
            for scanningPointX = 1:numberOfScanningPointsX
                ee = e(:,scanningPointX+(scanningPointY-1)*numberOfScanningPointsX);
                if useDAS
                    S(scanningPointY,scanningPointX) = ee'*R*ee;
                else
                    S(scanningPointY,scanningPointX) = 1./(ee'*R*ee);
                end
            end
        end
        
        %Interpolate for higher resolution
        interpolationFactor = 4;
        interpolationMethod = 'spline';
        
        S = interp2(S, interpolationFactor, interpolationMethod);
        
        S = abs(S)/max(max(abs(S)));
        S = 10*log10(S);
    end



    %Plot the image with overlaid steered response power
    function plotImage(imageFile, S, amplitudes, xPosSource, yPosSource, scanningPointsX, scanningPointsY, maxScanningPlaneExtentX, maxScanningPlaneExtentY)

        
        fig.Name = 'Acoustic camera test';
        fig.NumberTitle = 'off';
        fig.ToolBar = 'none';
        fig.MenuBar = 'none';
        fig.Color = [0 0 0];
        fig.Resize = 'off';
        
        
        %Background image
        [x, y] = meshgrid(linspace(-maxScanningPlaneExtentX,maxScanningPlaneExtentX,size(S,2)), ...
            linspace(-maxScanningPlaneExtentY,maxScanningPlaneExtentY,size(S,1)));
        
        imagePlot = surf(ax, x, y, ones(size(x))*distanceToScanningPlane,...
            'edgecolor','none',...
            'CData',flipud(imageFile),...
            'FaceColor','TextureMap');

        hold(ax, 'on')
        
        %Coloring of sources
        steeredResponsePlot = surf(ax, x, y, S+distanceToScanningPlane+dynamicRange,...
            'EdgeColor','none',...
            'FaceAlpha',0.5);
                
        colormap(cmap);

        %Add dynamic range slider
        range = [0.01 maxDynamicRange];  
        dynamicRangeSlider = uicontrol('style', 'slider', ...
            'Units', 'normalized',...
            'position', [0.92 0.18 0.03 0.6],...
            'value', log10(dynamicRange),...
            'min', log10(range(1)),...
            'max', log10(range(2)));
        addlistener(dynamicRangeSlider,'ContinuousValueChange',@(obj, evt) changeDynamicRange(obj, evt, 10^obj.Value, steeredResponsePlot));
        
        
        %Add frequency slider
        frequencySlider = uicontrol('style', 'slider', ...
            'Units', 'normalized',...
            'position', [0.13 0.03 0.78 0.04],...
            'value', f,...
            'min', 0.1e3,...
            'max', 20e3);
        addlistener(frequencySlider, 'ContinuousValueChange', @(obj,evt) changeFrequencyOfSource(obj, evt, obj.Value, steeredResponsePlot) );
        addlistener(frequencySlider,'ContinuousValueChange',@(obj,evt) xlabel(ax, ['Frequency: ' sprintf('%0.1f', obj.Value*1e-3) ' kHz'],'fontweight','normal'));
        
        %Axes
        box(ax, 'on')    
        xlabel(ax, ['Frequency: ' sprintf('%0.1f', f*1e-3) ' kHz'],'fontweight','normal')
        ylim(ax, [-maxScanningPlaneExtentY maxScanningPlaneExtentY])
        xlim(ax, [-maxScanningPlaneExtentX maxScanningPlaneExtentX])
        zlim(ax, [-maxDynamicRange maxDynamicRange])
        ax.Color = [0 0 0];
        ax.XColor = [1 1 1];
        ax.YColor = [1 1 1];
%         ax.XTick = [];
%         ax.YTick = [];
        axis(ax,'equal')
        daspect(ax,[1 1 30])
        
        
        %Set defaults
        changeView(ax, ax, '2D')
        changeDynamicRange(ax, ax, dynamicRange, steeredResponsePlot)
        addContextMenu(ax, ax, imagePlot, amplitudes, xPosSource, yPosSource, steeredResponsePlot)
        
    end


    
    
    function changeDynamicRange(~, ~, selectedDynamicRange, steeredResponsePlot)
        dynamicRange = selectedDynamicRange;
        steeredResponsePlot.ZData = S+distanceToScanningPlane+dynamicRange;
        
        caxis(ax, [distanceToScanningPlane distanceToScanningPlane+dynamicRange]);
        title(ax, ['Dynamic range: ' sprintf('%0.2f', dynamicRange) ' dB'], 'fontweight', 'normal','Color',[1 1 1]);
    end


    function changeAlgorithm(~, ~, selectedAlgorithm, steeredResponsePlot)
        algorithm = selectedAlgorithm;
        S = calculateSteeredResponse(xPos, yPos, w, inputSignal, f, c, scanningPointsX, scanningPointsY, distanceToScanningPlane, numberOfScanningPointsX, numberOfScanningPointsY);
                
        changeDynamicRange(ax, ax, dynamicRange, steeredResponsePlot)
    end


    function changeFrequencyOfSource(~, ~, selectedFrequency, steeredResponsePlot)
        
        f = selectedFrequency;
        inputSignal = createSignal(xPos, yPos, f, c, fs, xPosSource, yPosSource, zPosSource, amplitudes);
        S = calculateSteeredResponse(xPos, yPos, w, inputSignal, f, c, scanningPointsX, scanningPointsY, distanceToScanningPlane, numberOfScanningPointsX, numberOfScanningPointsY);
        
        changeDynamicRange(ax, ax, dynamicRange, steeredResponsePlot)
    end


    function changeArray(~, ~, arrayClicked, steeredResponsePlot)
        
        if strcmp(arrayClicked,'Nor848A-10-ring')
            array = load('data/arrays/Nor848A-10.mat');
            xPos = array.xPos(225:256);
            yPos = array.yPos(225:256);
            w = ones(1,32)/32;
        else
            array = load(['data/arrays/' arrayClicked '.mat']);
            if strncmp(arrayClicked, 'Nor', 3)
                w = array.hiResWeights;
            else
                w = array.w;
            end
            xPos = array.xPos;
            yPos = array.yPos;
        end
        
        inputSignal = createSignal(xPos, yPos, f, c, fs, xPosSource, yPosSource, zPosSource, amplitudes);
        S = calculateSteeredResponse(xPos, yPos, w, inputSignal, f, c, scanningPointsX, scanningPointsY, distanceToScanningPlane, numberOfScanningPointsX, numberOfScanningPointsY);
        
        changeDynamicRange(ax, ax, dynamicRange, steeredResponsePlot)
    end


    function changeDbOfSource(~, ~, dBVal, sourceClicked, steeredResponsePlot, sourcePlot)
        
        %Generate a new context menu for the source if it is
        %enabled/disabled
        if ischar(dBVal)
            
            cmSourcePower = uicontextmenu;
            if strcmp(dBVal,'enable')
                amplitudes(sourceClicked) = 0;
                uimenu('Parent',cmSourcePower,'Label','disable','Callback', { @changeDbOfSource, 'disable', sourceClicked, steeredResponsePlot, sourcePlot });
                for dBVal = [-10 -5 -4 -3 -2 -1 1 2 3 4 5 10]
                    if dBVal > 0
                        uimenu('Parent',cmSourcePower,'Label',['+' num2str(dBVal) 'dB'],'Callback', { @changeDbOfSource, dBVal, sourceClicked, steeredResponsePlot, sourcePlot  });
                    else
                        
                        uimenu('Parent',cmSourcePower,'Label',[num2str(dBVal) 'dB'],'Callback', { @changeDbOfSource, dBVal, sourceClicked, steeredResponsePlot, sourcePlot  });
                    end
                end
            else
                amplitudes(sourceClicked) = -100;
                uimenu('Parent',cmSourcePower,'Label','enable','Callback', { @changeDbOfSource, 'enable', sourceClicked, steeredResponsePlot, sourcePlot });
            end
            sourcePlot(sourceClicked).UIContextMenu = cmSourcePower;
            
        else
            amplitudes(sourceClicked) = amplitudes(sourceClicked)+dBVal;
        end
        
        inputSignal = createSignal(xPos, yPos, f, c, fs, xPosSource, yPosSource, zPosSource, amplitudes);
        S = calculateSteeredResponse(xPos, yPos, w, inputSignal, f, c, scanningPointsX, scanningPointsY, distanceToScanningPlane, numberOfScanningPointsX, numberOfScanningPointsY);
        
        changeDynamicRange(ax, ax, dynamicRange, steeredResponsePlot)
    end


    function addContextMenu(~, ~, imagePlot, amplitudes, xPosSource, yPosSource, steeredResponsePlot)
        
        %Context menu to change frequency, background color and array
        cmFigure = uicontextmenu;
        
        %Array
        topMenuArray = uimenu('Parent', cmFigure, 'Label', 'Array');
        arrayMenuNorsonic = uimenu('Parent', topMenuArray, 'Label', 'Norsonic');
        uimenu('Parent', arrayMenuNorsonic, 'Label', 'Nor848A-4', 'Callback',{ @changeArray, 'Nor848A-4', steeredResponsePlot });
        uimenu('Parent', arrayMenuNorsonic, 'Label', 'Nor848A-10', 'Callback',{ @changeArray, 'Nor848A-10', steeredResponsePlot });
        uimenu('Parent', arrayMenuNorsonic, 'Label', 'Nor848A-16', 'Callback',{ @changeArray, 'Nor848A-16', steeredResponsePlot });
        uimenu('Parent', arrayMenuNorsonic, 'Label', 'Nor848A-10-ring', 'Callback',{ @changeArray, 'Nor848A-10-ring', steeredResponsePlot });
        arrayMenuGfai = uimenu('Parent', topMenuArray, 'Label', 'GfaI');
        uimenu('Parent', arrayMenuGfai, 'Label', 'Ring-32', 'Callback',{ @changeArray, 'Ring-32', steeredResponsePlot });
        uimenu('Parent', arrayMenuGfai, 'Label', 'Ring-48', 'Callback',{ @changeArray, 'Ring-48', steeredResponsePlot });
        uimenu('Parent', arrayMenuGfai, 'Label', 'Ring-72', 'Callback',{ @changeArray, 'Ring-72', steeredResponsePlot });
        arrayMenuCAE = uimenu('Parent', topMenuArray, 'Label', 'CAE');
        uimenu('Parent', arrayMenuCAE, 'Label', 'CAE XS', 'Callback',{ @changeArray, 'CAE_XS', steeredResponsePlot });
        uimenu('Parent', arrayMenuCAE, 'Label', 'CAE S', 'Callback',{ @changeArray, 'CAE_S', steeredResponsePlot });
        uimenu('Parent', arrayMenuCAE, 'Label', 'CAE Bionic M', 'Callback',{ @changeArray, 'CAE_bionic_m', steeredResponsePlot });
        uimenu('Parent', arrayMenuCAE, 'Label', 'CAE L', 'Callback',{ @changeArray, 'CAE_L', steeredResponsePlot });
        uimenu('Parent', arrayMenuCAE, 'Label', 'CAE XL', 'Callback',{ @changeArray, 'CAE_XL', steeredResponsePlot });
        arrayBK= uimenu('Parent', topMenuArray, 'Label', 'B&K');
        uimenu('Parent', arrayBK, 'Label', 'B&K Wheel', 'Callback',{ @changeArray, 'bk', steeredResponsePlot });
        uimenu('Parent', arrayBK, 'Label', 'B&K Half Wheel', 'Callback',{ @changeArray, 'bk_half', steeredResponsePlot });
        uimenu('Parent', topMenuArray, 'Label', 'SeeSV', 'Callback',{ @changeArray, 'SeesV', steeredResponsePlot });
        uimenu('Parent', topMenuArray, 'Label', 'Head', 'Callback',{ @changeArray, 'head', steeredResponsePlot });
        
        %Algorithm
        topMenuAlgorithm = uimenu('Parent', cmFigure, 'Label', 'Algorithm');
        uimenu('Parent', topMenuAlgorithm, 'Label', 'Delay-and-sum', 'Callback',{ @changeAlgorithm, 'DAS', steeredResponsePlot });
        uimenu('Parent', topMenuAlgorithm, 'Label', 'Minimum variance', 'Callback',{ @changeAlgorithm, 'MV', steeredResponsePlot });
        
        %View/background
        topMenuView = uimenu('Parent', cmFigure, 'Label', 'View');
        uimenu('Parent', topMenuView, 'Label', '2D', 'Callback',{ @changeView, '2D' });
        uimenu('Parent', topMenuView, 'Label', '3D', 'Callback',{ @changeView, '3D' });
        uimenu('Parent', topMenuView, 'Label', 'Color', 'Callback',{ @changeBackgroundColor, 'color', imagePlot });
        uimenu('Parent', topMenuView, 'Label', 'Gray', 'Callback',{ @changeBackgroundColor, 'gray', imagePlot });
        
%         %Export of steered response to .mat file
%         uimenu('Parent', cmFigure, 'Label', 'Export response', 'Callback',{ @(hObject, eventdata) assignin('base','S',steeredResponsePlot.CData) });
        
        imagePlot.UIContextMenu = cmFigure;
        steeredResponsePlot.UIContextMenu = cmFigure;
        
        
        %Plot sources with context menu (to enable/disable and change power)
        for sourceNumber = 1:numel(amplitudes)
            sourcePlot(sourceNumber) = scatter3(xPosSource(sourceNumber), yPosSource(sourceNumber),distanceToScanningPlane+maxDynamicRange, 300, [1 1 1]*0.4);
            
            cmSourcePower = uicontextmenu;
            if amplitudes(sourceNumber) == -100
                uimenu('Parent',cmSourcePower,'Label','enable','Callback', { @changeDbOfSource, 'enable', sourceNumber, steeredResponsePlot, sourcePlot });
            else
                uimenu('Parent',cmSourcePower,'Label','disable','Callback', { @changeDbOfSource, 'disable', sourceNumber, steeredResponsePlot, sourcePlot });
                for dBVal = [-10 -5 -4 -3 -2 -1 1 2 3 4 5 10]
                    if dBVal > 0
                        uimenu('Parent',cmSourcePower,'Label',['+' num2str(dBVal) 'dB'],'Callback', { @changeDbOfSource, dBVal, sourceNumber, steeredResponsePlot });
                    else
                        
                        uimenu('Parent',cmSourcePower,'Label',[num2str(dBVal) 'dB'],'Callback', { @changeDbOfSource, dBVal, sourceNumber, steeredResponsePlot });
                    end
                end
            end
            sourcePlot(sourceNumber).UIContextMenu = cmSourcePower;
        end
        
    end
    

    function changeView(~, ~, selectedView)
        if strcmp(selectedView,'2D')
            view(ax, [0 90])
        else
            ax.CameraPosition = [20, 12, 700];
            ax.CameraUpVector = [0 1 0];
        end
    end


    function changeBackgroundColor(~, ~, color, imagePlot)
        
        if strcmp(color, 'color')
            imagePlot.CData = flipud(imageFileColor);
        else
            imagePlot.CData = flipud(imageFileGray);
        end
    end


end
        
