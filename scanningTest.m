function [] = scanningTest()

c = 340;
fs = 44.1e3;
f = 5e3;

load ../data/arrays/S1.mat
w = hiResWeights;
% load data/arrays/ring-72.mat
% w = ones(1,numel(xPos));

[imageFile, imageMap] = imread('../data/fig/room.jpg');

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
xPosSource = [-2.147 -2.147 -2.147 -1.28 -0.3 0.1 0.37 1.32 2.18 2.18 2.18];
yPosSource = [0.26 -0.15 -0.55 -0.34 1.47 0.5 1.47 -0.33 0.26 -0.15 -0.55];
amplitudes = [1 2 3 5 3 6 3 5 1 2 3];
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
    



    function plotImage(imageFile, S, amplitudes, xPosSource, yPosSource, scanningPointsX, scanningPointsY, maxScanningPlaneExtentX, maxScanningPlaneExtentY)
        % Points in space and scanspace
        fig = figure(1);clf
        set(fig,'color',[0 0 0])
        
        %Background image
        imagePlot = image(scanningPointsX, scanningPointsY, imageFile);
        hold on
        
        %Coloring of sources
        sPlot = imagesc(scanningPointsX, scanningPointsY, S);
        sPlot.AlphaData = 0.4;
        cmap = colormap;
        cmap(1,:) = [1 1 1]*0.8;
        colormap(cmap);
        axis xy equal
        box on
        
        %Sources with context menu
        for sourceNumber = 1:numel(amplitudes)
            plotSources(sourceNumber) = scatter(xPosSource(sourceNumber), yPosSource(sourceNumber),100, [1 1 1]*0.5);
            cm = uicontextmenu;
            for dBVal = [0 1 2 3 4 5 10 15]
                eval(['uimenu(''Parent'',cm,''Label'',''+' num2str(dBVal) ' dB'',''Callback'',{@changeDbOfSource, ' num2str(dBVal) ', sourceNumber });'])
            end
            plotSources(sourceNumber).UIContextMenu = cm;
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
    

