function [] = scanningTest()

c = 340;
fs = 44.1e3;
f = 5e3;

array = load('../data/arrays/S1.mat');
w = array.hiResWeights;
% array = load('../data/arrays/ring-72.mat');
% w = array.w;
xPos = array.xPos;
yPos = array.yPos;

imageFile = imread('../data/fig/room.jpg');
grayScaleValues = rgb2gray(imageFile);

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
%amplitudes = [1 2 3 5 3 6 3 5 1 2 3];
amplitudes = [0 0 0 0 0 0 0 0 0 0 0];
zPosSource = distanceToScanningPlane*ones(1,length(xPosSource));

% Convert from cartesian points to polar angles source
thetaArrivalAngles = atan(sqrt(xPosSource.^2+yPosSource.^2)./zPosSource);
phiArrivalAngles = atan(yPosSource./xPosSource);

thetaArrivalAngles = thetaArrivalAngles*180/pi;
phiArrivalAngles = phiArrivalAngles*180/pi;
phiArrivalAngles(xPosSource<0) = phiArrivalAngles(xPosSource<0) + 180;

thetaArrivalAngles(isnan(thetaArrivalAngles)) = 0;
phiArrivalAngles(isnan(phiArrivalAngles)) = 0;


%Create input signal
inputSignal = createSignal(xPos, yPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles, amplitudes);

%Calculate steered response
S = calculateSteeredResponse(xPos, yPos, w, inputSignal, f, c, scanningPointsX, scanningPointsY, distanceToScanningPlane, numberOfScanningPointsX, numberOfScanningPointsY);

%Plot image and steered response
plotImage(imageFile, S, amplitudes, xPosSource, yPosSource, scanningPointsX, scanningPointsY, maxScanningPlaneExtentX, maxScanningPlaneExtentY)





    function inputSignal = createSignal(xPos, yPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles, amplitudes)

        
        nSamples = 1e3;
        
        T = nSamples/fs;
        t = 0:1/fs:T-1/fs;
        
        inputSignal = 0;
        for k = 1:numel(thetaArrivalAngles)
            
            %Number of elements/sensors in the array
            P = size(xPos,2);
            
            %Changing wave vector to spherical coordinates
            kx = sin(thetaArrivalAngles(k)*pi/180).*cos(phiArrivalAngles(k)*pi/180);
            ky = sin(thetaArrivalAngles(k)*pi/180).*sin(phiArrivalAngles(k)*pi/180);
            
            %Calculate steering vector/matrix
            kxx = bsxfun(@times,kx,reshape(xPos,P,1));
            kyy = bsxfun(@times,ky,reshape(yPos,P,1));
            doa = exp(1j*2*pi*f/c*(kxx+kyy));
            signal = 10^(amplitudes(k)/20)*doa*exp(1j*2*pi*(f*t+randn(1,nSamples)));
            
            %Total signal equals sum of individual signals
            inputSignal = inputSignal + signal;
        end
    end

        
        
        

    function S = calculateSteeredResponse(xPos, yPos, w, inputSignal, f, c, scanningPointsX, scanningPointsY, distanceToScanningPlane, numberOfScanningPointsX, numberOfScanningPointsY)
        % Calculate steered response in frequency domain
        nSamples = numel(inputSignal);
        nElements = numel(xPos);
        
        
        % Convert from cartesian points to polar angles scanning
        thetaScanningAngles = atan(sqrt(scanningPointsX.^2+scanningPointsY.^2)/distanceToScanningPlane);
        phiScanningAngles = atan(scanningPointsY./scanningPointsX);
        
        thetaScanningAngles = thetaScanningAngles*180/pi;
        phiScanningAngles = phiScanningAngles*180/pi;
        phiScanningAngles(scanningPointsX<0) = phiScanningAngles(scanningPointsX<0) + 180;
        
        thetaScanningAngles(isnan(thetaScanningAngles)) = 0;
        phiScanningAngles(isnan(phiScanningAngles)) = 0;
        
        
        %Get steering vector to each point
        k = 2*pi*f/c;
        kx = sin(thetaScanningAngles*pi/180).*cos(phiScanningAngles*pi/180);
        ky = sin(thetaScanningAngles*pi/180).*sin(phiScanningAngles*pi/180);
        k_xx = bsxfun(@times,kx,reshape(xPos,nElements,1));
        k_yy = bsxfun(@times,ky,reshape(yPos,nElements,1));
        e = exp(1j*k*(k_xx+k_yy));
        
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
        % Points in space and scanspace
        fig = figure;
        set(fig,'color',[0 0 0])
        
        %Background image
        imagePlot = image(scanningPointsX, scanningPointsY, imageFile);
        hold on
        
        %Coloring of sources
        sourcePlot = imagesc(scanningPointsX, scanningPointsY, S);
        sourcePlot.AlphaData = 0.4;
        cmap = colormap;
        cmap(1,:) = [1 1 1]*0.8;
        colormap(cmap);
        axis xy equal
        box on
        
        
        cmFrequency = uicontextmenu;
        topMenuFreq = uimenu('Parent',cmFrequency,'Label','Frequency');
        topMenuTheme = uimenu('Parent',cmFrequency,'Label','Background');
        uimenu('Parent',topMenuFreq, 'Label', '1 kHz', 'Callback',{ @changeFrequencyOfSource, 1e3 , sourcePlot });
        uimenu('Parent',topMenuFreq, 'Label', '2 kHz', 'Callback',{ @changeFrequencyOfSource, 2e3 , sourcePlot });
        uimenu('Parent',topMenuFreq, 'Label', '3 kHz', 'Callback',{ @changeFrequencyOfSource, 3e3 , sourcePlot });
        uimenu('Parent',topMenuFreq, 'Label', '4 kHz', 'Callback',{ @changeFrequencyOfSource, 4e3 , sourcePlot });
        uimenu('Parent',topMenuFreq, 'Label', '5 kHz', 'Callback',{ @changeFrequencyOfSource, 5e3 , sourcePlot });
        uimenu('Parent',topMenuFreq, 'Label', '6 kHz', 'Callback',{ @changeFrequencyOfSource, 6e3 , sourcePlot });
        uimenu('Parent',topMenuFreq, 'Label', '7 kHz', 'Callback',{ @changeFrequencyOfSource, 7e3 , sourcePlot });
        uimenu('Parent',topMenuFreq, 'Label', '8 kHz', 'Callback',{ @changeFrequencyOfSource, 8e3 , sourcePlot });
        uimenu('Parent',topMenuFreq, 'Label', '9 kHz', 'Callback',{ @changeFrequencyOfSource, 9e3 , sourcePlot });
        uimenu('Parent',topMenuFreq, 'Label', '10 kHz', 'Callback',{ @changeFrequencyOfSource, 10e3 , sourcePlot });
        uimenu('Parent',topMenuFreq, 'Label', '11 kHz', 'Callback',{ @changeFrequencyOfSource, 11e3 , sourcePlot });
        uimenu('Parent',topMenuFreq, 'Label', '12 kHz', 'Callback',{ @changeFrequencyOfSource, 12e3 , sourcePlot });
        uimenu('Parent',topMenuTheme, 'Label', 'Color', 'Callback',{ @changeBackgroundColor, 'color', imagePlot });
        uimenu('Parent',topMenuTheme, 'Label', 'Gray', 'Callback',{ @changeBackgroundColor, 'gray', imagePlot });
        
        sourcePlot.UIContextMenu = cmFrequency;
        
        %Sources with context menu
        for sourceNumber = 1:numel(amplitudes)
            plotSources(sourceNumber) = scatter(xPosSource(sourceNumber), yPosSource(sourceNumber),300, [1 1 1]*0.4);
            cmSourcePower = uicontextmenu;
            for dBVal = [-50 -10 -5 -4 -3 -2 -1 1 2 3 4 5 10 +50]
                if dBVal > 0
                    eval(['uimenu(''Parent'',cmSourcePower,''Label'',''+' num2str(dBVal) ' dB'',''Callback'',{@changeDbOfSource, ' num2str(dBVal) ', sourceNumber, sourcePlot });'])
                else
                    eval(['uimenu(''Parent'',cmSourcePower,''Label'',''' num2str(dBVal) ' dB'',''Callback'',{@changeDbOfSource, ' num2str(dBVal) ', sourceNumber, sourcePlot });'])
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


    function changeDbOfSource(~, ~, dBVal, sourceClicked, sourcePlot)
        
        amplitudes(sourceClicked) = amplitudes(sourceClicked)+dBVal;
        inputSignal = createSignal(xPos, yPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles, amplitudes);
        S = calculateSteeredResponse(xPos, yPos, w, inputSignal, f, c, scanningPointsX, scanningPointsY, distanceToScanningPlane, numberOfScanningPointsX, numberOfScanningPointsY);
        sourcePlot.CData = S;
    end


    function changeFrequencyOfSource(~, ~, frequency, sourcePlot)
        
        f = frequency;
        inputSignal = createSignal(xPos, yPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles, amplitudes);
        S = calculateSteeredResponse(xPos, yPos, w, inputSignal, f, c, scanningPointsX, scanningPointsY, distanceToScanningPlane, numberOfScanningPointsX, numberOfScanningPointsY);
        sourcePlot.CData = S;
    end

    function changeBackgroundColor(~, ~, color, imagePlot)
        
        if strcmp(color, 'color')
            imagePlot.CData = imageFile;
        else
            imagePlot.CData = grayScaleValues;
        end
    end

end