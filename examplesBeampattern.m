%% Examples on how to calculate array factor / beampattern

%% Create 2D array

% Position of sensors and weighting of 2D array
% Create circular array

nElements = 20;
radius = 0.6;

[xPos, yPos] = pol2cart(linspace(0,2*pi-2*pi/nElements,nElements),ones(1,nElements)*radius);
w = ones(1,numel(xPos))/numel(xPos);


%% Plot array geometry and array factor for different frequencies

% Wave-frequency and wave-speed
f = [250 500 1e3 1.3e3];
c = 340;

% Scanning angles
thetaScanningAngles = -90:90;
phiScanningAngles = 0;

%Calculate and plot the array pattern for various frequencies
figure(1);clf
subplot(121)
plot(xPos, yPos,'.')
title('Array geometry','FontWeight','Normal')
axis([-radius-0.1 radius+0.1 -radius-0.1 radius+0.1])
axis square; grid minor
for ff = f
    W = arrayFactor(xPos, yPos, w, ff, c, thetaScanningAngles, phiScanningAngles);
    W = 20*log10(W);
    
    subplot(122)
    plot(thetaScanningAngles,W);
    hold on
end
xlabel('\theta');ylabel('dB');axis square
grid on
title('Array factor','FontWeight','Normal')
axis([thetaScanningAngles(1) thetaScanningAngles(end) -30 0])

%% Plot with steering

% Wave-frequency and wave-speed
f = [750 1e3];
c = 340;

% Scanning angles
thetaScanningAngles = -60:0.5:60;
phiScanningAngles = 0;

% Steering angle
thetaSteeringAngle = -20;

% Calculate and plot the array factor
figure(3);clf
hold on
for ff = f
    W = arrayFactor(xPos, yPos, w, ff, c, thetaScanningAngles, phiScanningAngles, thetaSteeringAngle);
    W = 20*log10(W);
    
    plot(thetaScanningAngles,W,'DisplayName',[num2str(ff*1e-3) 'kHz']);
end

xlabel('\theta');ylabel('dB')
grid on
axis([thetaScanningAngles(1) thetaScanningAngles(end) -30 0])
legend(gca,'show')
title(['Steering angle ' num2str(thetaSteeringAngle) ' degrees'],'FontWeight','Normal')
yL = get(gca,'YLim');
indx = find(thetaScanningAngles >= thetaSteeringAngle,1);
line([thetaScanningAngles(indx) thetaScanningAngles(indx)],yL,'LineWidth',1,'Color','r','LineStyle','--');


%% Plot array factor from 0 to 10 kHz

% Wave-frequency and wave-speed
f = 0:10:10e3;
c = 340;

% Scanning angles
thetaScanningAngles = -90:0.2:90;
phiScanningAngles = 0;

%Preallocating for speed
W_all = zeros(numel(f),numel(thetaScanningAngles));

%Calculate array factor
for k = 1:length(f)
    W = arrayFactor(xPos, yPos, w, f(k), c, thetaScanningAngles, phiScanningAngles);
    W_all(k,:) = 20*log10(W);
end

%Don't display values below a certain threshold
dBmin = 30;
W_all(W_all<-dBmin) = NaN;

%Plot array factor
figure(4);clf
imagesc(f*1e-3,thetaScanningAngles,W_all')
xlabel('kHz');ylabel('\theta')
colorbar('northoutside','direction','reverse')

%% Plot the beampattern for various frequencies with plotBeampattern()

f = [0.5e3 1e3 3e3];
c = 340;
thetaSteeringAngle = -10;
dynRange = 50;

plotBeampattern(xPos, yPos, w, f, c, thetaSteeringAngle)

%% Plot the 3D polar beampattern of the array with plotBeampattern3D()

plotBeampattern3D(xPos, yPos, w)


    
    