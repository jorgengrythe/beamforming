function [] = scanningTest()

c = 340;
fs = 44.1e3;
f = 5e3;

array = load('../data/arrays/S2.mat');
w = array.hiResWeights;
% array = load('../data/arrays/ring-72.mat');
% w = array.w;
xPos = array.xPos;
yPos = array.yPos;

imageFileColor = imread('../data/fig/room.jpg');
imageFileGray = imread('../data/fig/roombw.jpg');

% Acoustical coverage / listening points
maxAcousticalCoveringAngleHorizontal = 42;
maxAcousticalCoveringAngleVertical = 30;
distanceToScanningPlane = 3; %in meters
numberOfScanningPointsX = 40;
numberOfScanningPointsY = 30;

maxScanningPlaneExtentX = tan(maxAcousticalCoveringAngleHorizontal*pi/180)*distanceToScanningPlane;
maxScanningPlaneExtentY = tan(maxAcousticalCoveringAngleVertical*pi/180)*distanceToScanningPlane;

scanningAxisX = -maxScanningPlaneExtentX:2*maxScanningPlaneExtentX/(numberOfScanningPointsX-1):maxScanningPlaneExtentX;
scanningAxisY = maxScanningPlaneExtentY:-2*maxScanningPlaneExtentY/(numberOfScanningPointsY-1):-maxScanningPlaneExtentY;

% Get all (x,y) points, organize such that scanning will be left-right-top-bottom
[scanningPointsY, scanningPointsX] = meshgrid(scanningAxisY,scanningAxisX);
scanningPointsX = scanningPointsX(:)';
scanningPointsY = scanningPointsY(:)';


%Sources
xPosSource = [-2.147 -2.147 -2.147 -1.28 -0.3 0 0.37 1.32 2.18 2.18 2.18];
yPosSource = [0.26 -0.15 -0.55 -0.34 1.47 0.5 1.47 -0.33 0.26 -0.15 -0.55];
amplitudes = [-100 -100 -100 0 -100 -100 -100 0 -100 -100 -100];
zPosSource = distanceToScanningPlane*ones(1,length(xPosSource));

[thetaArrivalAngles, phiArrivalAngles] = convertCartesianToPolar(xPosSource, yPosSource, zPosSource);


%Create input signal
inputSignal = createSignal(xPos, yPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles, amplitudes);

%Calculate steered response
S = calculateSteeredResponse(xPos, yPos, w, inputSignal, f, c, scanningPointsX, scanningPointsY, distanceToScanningPlane, numberOfScanningPointsX, numberOfScanningPointsY);

%Plot image and steered response
plotImage(imageFileColor, S, amplitudes, xPosSource, yPosSource, scanningPointsX, scanningPointsY, maxScanningPlaneExtentX, maxScanningPlaneExtentY)


    function [thetaAngles, phiAngles] = convertCartesianToPolar(xPos, yPos, zPos)
        % Convert from cartesian points to polar angles source
        thetaAngles = atan(sqrt(xPos.^2+yPos.^2)./zPos);
        phiAngles = atan(yPos./xPos);
        
        thetaAngles = thetaAngles*180/pi;
        phiAngles = phiAngles*180/pi;
        phiAngles(xPos<0) = phiAngles(xPos<0) + 180;
        
        thetaAngles(isnan(thetaAngles)) = 0;
        phiAngles(isnan(phiAngles)) = 0;
    end

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

    function inputSignal = createSignal(xPos, yPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles, amplitudes)
              
        nSamples = 1e3;
        
        T = nSamples/fs;
        t = 0:1/fs:T-1/fs;
        
        inputSignal = 0;
        for source = 1:numel(thetaArrivalAngles)
            
            doa = steeringVector(xPos, yPos, f, c, thetaArrivalAngles(source), phiArrivalAngles(source));
            
            signal = 10^(amplitudes(source)/20)*doa*exp(1j*2*pi*(f*t+randn(1,nSamples)));
            
            %Total signal equals sum of individual signals
            inputSignal = inputSignal + signal;
        end
    end

        
        
        

    function S = calculateSteeredResponse(xPos, yPos, w, inputSignal, f, c, scanningPointsX, scanningPointsY, distanceToScanningPlane, numberOfScanningPointsX, numberOfScanningPointsY)

        nSamples = numel(inputSignal);
        
        [thetaScanningAngles, phiScanningAngles] = convertCartesianToPolar(scanningPointsX, scanningPointsY, distanceToScanningPlane);
               
        
        %Get steering vector to each point
        e = steeringVector(xPos, yPos, f, c, thetaScanningAngles, phiScanningAngles);
        
        % Multiply input signal by weighting vector
        inputSignal = diag(w)*inputSignal;
        
        %Calculate correlation matrix
        R = inputSignal*inputSignal';
        R = R/nSamples;
        
        %Calculate power as a function of steering vector/scanning angle (delay-and-sum)
        S = zeros(numberOfScanningPointsY,numberOfScanningPointsX);
        
        for scanningPointY = 1:numberOfScanningPointsY
            for scanningPointX = 1:numberOfScanningPointsX
                ee = e(:,scanningPointX+(scanningPointY-1)*numberOfScanningPointsX);
                S(scanningPointY,scanningPointX) = ee'*R*ee;
            end
        end
        
        %Interpolate for higher resolution
        interpolationFactor = 4;
        interpolationMethod = 'spline';
        
        S = interp2(S, interpolationFactor, interpolationMethod);
        
        S = abs(S)/max(max(abs(S)));
        S = 10*log10(S);
    end



    function plotImage(imageFile, S, amplitudes, xPosSource, yPosSource, scanningPointsX, scanningPointsY, maxScanningPlaneExtentX, maxScanningPlaneExtentY)

        fig = figure;
        set(fig,'color',[0 0 0])
        
        %Background image
        plotImage = image(scanningPointsX, scanningPointsY, imageFile);
        hold on
        
        %Coloring of sources
        plotSteeredResponse = imagesc(scanningPointsX, scanningPointsY, S);
        plotSteeredResponse.AlphaData = 0.4;
        cmap = colormap;
        cmap(1,:) = [1 1 1]*0.8;
        colormap(cmap);
        axis xy equal
        box on
        
        %Context menu to change frequency and background color
        cmFrequency = uicontextmenu;
        topMenuFreq = uimenu('Parent',cmFrequency,'Label','Frequency');
        topMenuTheme = uimenu('Parent',cmFrequency,'Label','Background');
        for freq = [0.5e3 0.8e3 1e3 2e3 3e3 4e3 5e3 6e3 7e3 8e3 9e3 10e3 11e3 12e3]
         uimenu('Parent',topMenuFreq, 'Label', [num2str(freq*1e-3) 'kHz'], 'Callback',{ @changeFrequencyOfSource, freq , plotSteeredResponse });
        end
        uimenu('Parent',topMenuTheme, 'Label', 'Color', 'Callback',{ @changeBackgroundColor, 'color', plotImage });
        uimenu('Parent',topMenuTheme, 'Label', 'Gray', 'Callback',{ @changeBackgroundColor, 'gray', plotImage });
        
        plotSteeredResponse.UIContextMenu = cmFrequency;
        
        %Sources with context menu
        for sourceNumber = 1:numel(amplitudes)
            plotSources(sourceNumber) = scatter(xPosSource(sourceNumber), yPosSource(sourceNumber),300, [1 1 1]*0.4);
            
            cmSourcePower = uicontextmenu;
            if amplitudes(sourceNumber) == -100
                uimenu('Parent',cmSourcePower,'Label','enable','Callback', { @changeDbOfSource, 'enable', sourceNumber, plotSteeredResponse, plotSources });
            else
                uimenu('Parent',cmSourcePower,'Label','disable','Callback', { @changeDbOfSource, 'disable', sourceNumber, plotSteeredResponse, plotSources });
                for dBVal = [-10 -5 -4 -3 -2 -1 1 2 3 4 5 10]
                    if dBVal > 0
                        uimenu('Parent',cmSourcePower,'Label',['+' num2str(dBVal) 'dB'],'Callback', { @changeDbOfSource, dBVal, sourceNumber, plotSteeredResponse });
                    else
                        
                        uimenu('Parent',cmSourcePower,'Label',[num2str(dBVal) 'dB'],'Callback', { @changeDbOfSource, dBVal, sourceNumber, plotSteeredResponse });
                    end
                end
            end
            plotSources(sourceNumber).UIContextMenu = cmSourcePower;
        end
               
        xlabel('x [m]')
        ylabel('y [m]')
        ylim([-maxScanningPlaneExtentY maxScanningPlaneExtentY])
        xlim([-maxScanningPlaneExtentX maxScanningPlaneExtentX])
        
        set(gca,'color',[0 0 0],'xcolor',[1 1 1],'ycolor',[1 1 1],'zcolor',[1 1 1])
        
        maxDynamicRange = 60;
        defaultDisplayValue = 10;
        range = [0.01 maxDynamicRange];
        caxis([-defaultDisplayValue 0])
        
        title(['Dynamic range: ' sprintf('%0.2f', defaultDisplayValue) ' dB'], 'FontWeight', 'normal','Color',[1 1 1]);
        
        h = uicontrol('style', 'slider', ...
            'Units', 'normalized',...
            'position', [0.92 0.18 0.03 0.6],...
            'value', log10(defaultDisplayValue),...
            'min', log10(range(1)),...
            'max', log10(range(2)));
        addlistener(h,'ContinuousValueChange',@(hObject,eventdata) caxis([-10^get(hObject, 'Value') 0]));
        addlistener(h,'ContinuousValueChange',@(hObject,eventdata) title(['Dynamic range: ' sprintf('%0.2f', 10^get(hObject, 'Value')) ' dB'],'fontweight','normal'));
    end


    function changeDbOfSource(~, ~, dBVal, sourceClicked, plotSteeredResponse, plotSources)
        if ischar(dBVal)
            
            cmSourcePower = uicontextmenu;
            if strcmp(dBVal,'enable')
                amplitudes(sourceClicked) = 0;
                uimenu('Parent',cmSourcePower,'Label','disable','Callback', { @changeDbOfSource, 'disable', sourceClicked, plotSteeredResponse, plotSources });
                for dBVal = [-10 -5 -4 -3 -2 -1 1 2 3 4 5 10]
                    if dBVal > 0
                        uimenu('Parent',cmSourcePower,'Label',['+' num2str(dBVal) 'dB'],'Callback', { @changeDbOfSource, dBVal, sourceClicked, plotSteeredResponse, plotSources  });
                    else
                        
                        uimenu('Parent',cmSourcePower,'Label',[num2str(dBVal) 'dB'],'Callback', { @changeDbOfSource, dBVal, sourceClicked, plotSteeredResponse, plotSources  });
                    end
                end
            else
                amplitudes(sourceClicked) = -100;
                uimenu('Parent',cmSourcePower,'Label','enable','Callback', { @changeDbOfSource, 'enable', sourceClicked, plotSteeredResponse, plotSources });
            end
            plotSources(sourceClicked).UIContextMenu = cmSourcePower;
            
        else
            amplitudes(sourceClicked) = amplitudes(sourceClicked)+dBVal;
        end
        
        inputSignal = createSignal(xPos, yPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles, amplitudes);
        S = calculateSteeredResponse(xPos, yPos, w, inputSignal, f, c, scanningPointsX, scanningPointsY, distanceToScanningPlane, numberOfScanningPointsX, numberOfScanningPointsY);
        plotSteeredResponse.CData = S;
    end


    function changeFrequencyOfSource(~, ~, frequency, sourcePlot)
        
        f = frequency;
        inputSignal = createSignal(xPos, yPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles, amplitudes);
        S = calculateSteeredResponse(xPos, yPos, w, inputSignal, f, c, scanningPointsX, scanningPointsY, distanceToScanningPlane, numberOfScanningPointsX, numberOfScanningPointsY);
        sourcePlot.CData = S;
    end

    function changeBackgroundColor(~, ~, color, imagePlot)
        
        if strcmp(color, 'color')
            imagePlot.CData = imageFileColor;
        else
            imagePlot.CData = imageFileGray;
        end
    end

end