function beampattern2D

%Default values
c = 340;
fs = 44.1e3;
f = 3e3;
dynamicRange = 48;
maxDynamicRange = 50;

array = load('data/arrays/Nor848A-10.mat');
xPos = array.xPos;
yPos = array.yPos;
w = array.hiResWeights;
%w = ones(1, numel(xPos));


%Istedenfor un





% Acoustical coverage / listening directions
coverageAngle = 45;

distanceToScanningPlane = 1;
maxScanningPlaneExtentX = tan(coverageAngle*pi/180)*2;
maxScanningPlaneExtentY = tan(coverageAngle*pi/180)*2;

numberOfScanningPointsX = 150;
numberOfScanningPointsY = 100;

scanningAxisX = -maxScanningPlaneExtentX/2:maxScanningPlaneExtentX/(numberOfScanningPointsX-1):maxScanningPlaneExtentX/2;
scanningAxisY = maxScanningPlaneExtentY/2:-maxScanningPlaneExtentY/(numberOfScanningPointsY-1):-maxScanningPlaneExtentY/2;

% Get all (x,y) scanning points
[scanningPointsY, scanningPointsX] = meshgrid(scanningAxisY,scanningAxisX);




%(x,y) position of sources
steeringAngleX = 0;
steeringAngleY = 0;
xPosSource = tan(steeringAngleX*pi/180)
yPosSource = tan(steeringAngleY*pi/180);


%Create input signal
inputSignal = createSignal(xPos, yPos, f, c, fs, xPosSource, yPosSource, distanceToScanningPlane, 0);

%Calculate steered response
S = calculateSteeredResponse(xPos, yPos, w, inputSignal, f, c, scanningPointsX, scanningPointsY, distanceToScanningPlane, numberOfScanningPointsX, numberOfScanningPointsY);

% %Interpolate for higher resolution
% interpolationFactor = 3;
% interpolationMethod = 'spline';
% 
% S = interp2(S, interpolationFactor, interpolationMethod);
% scanningPointsX = interp2(scanningPointsX, interpolationFactor, interpolationMethod);
% scanningPointsY = interp2(scanningPointsY, interpolationFactor, interpolationMethod);

figure(11); clf
ax = axes;


%M? mappe scanningpoints x, y over til vinkler. Med en slags max som er i
%grader, kanskje normalisere p? et vis eller lignende? At max ?pningsvinkel
%er max punkter i x, setter max = 60 og regner seg tilbake eller lignende


%steeredResponsePlot = imagesc(scanningAxisX, scanningAxisY, S);

steeredResponsePlot = surf(ax, S, ...
            'EdgeColor','none',...
            'FaceAlpha',0.6);

grid on
view(0, 90)
%tickAngles = [-45 -30 -15 0 15 30 45 60];
%ax.XTick = sin(tickAngles*pi/180)/sin(60*pi/180)*(maxScanningPlaneExtentX/2);
%ax.XTickLabel = tickAngles;
xlabel(ax, 'Angle in degree');
%ax.YTick = sin(tickAngles*pi/180);
%ax.YTickLabel = tickAngles;


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
    'position', [0.92 0.18 0.03 0.6],...
    'value', log10(dynamicRange),...
    'min', log10(range(1)),...
    'max', log10(range(2)));
addlistener(dynamicRangeSlider,'ContinuousValueChange',@(obj, evt) changeDynamicRange(obj, evt, 10^obj.Value, steeredResponsePlot));
        
changeDynamicRange(ax, ax, dynamicRange, steeredResponsePlot)


    function changeDynamicRange(~, ~, selectedDynamicRange, steeredResponsePlot)
        dynamicRange = selectedDynamicRange;
        steeredResponsePlot.ZData = S+dynamicRange;
        
        caxis(ax, [0 dynamicRange]);
        zlim(ax, [0 dynamicRange+0.1])
        title(ax, ['Dynamic range: ' sprintf('%0.2f', dynamicRange) ' dB'], 'fontweight', 'normal','Color',[0 0 0]);
    end





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
    end


end