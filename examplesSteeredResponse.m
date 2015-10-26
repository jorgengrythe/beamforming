%% Examples on delay-and-sum response for different arrays and input signals


%% 1D-array case
clear all

% Create vectors of x- and y-coordinates of microphone positions 
xPos = -1:0.2:1; % 1xP vector of x-positions in meters
yPos = zeros(1,numel(xPos)); % 1xP vector of y-positions in meters
w = ones(1,numel(xPos))/numel(xPos); % 1xP vector of weightings

% Define arriving angles and frequency of input signals
thetaArrivalAngles = [-30 10]; % degrees
phiArrivalAngles = [0 0]; % degrees
f = 800; % Hz
c = 340; % m/s
fs = 44.1e3; % Hz

% Define array scanning angles (1D, so phi = 0)
thetaScanningAngles = -90:0.1:90; % degrees
phiScanningAngles = 0; % degrees


% Create input signal
inputSignal = createSignal(xPos, yPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles);

% Calculate delay-and-sum steered response
S = steeredResponseDelayAndSum(xPos, yPos, w, inputSignal, f, c,...
   thetaScanningAngles, phiScanningAngles);

%Normalise spectrum
spectrumNormalized = abs(S)/max(abs(S));

%Convert to decibel
spectrumLog = 10*log10(spectrumNormalized);

%Plot steered response
figure(1);clf
plot(thetaScanningAngles,spectrumLog)
grid on
xlim([thetaScanningAngles(1) thetaScanningAngles(end)])

yL = get(gca,'YLim');
for j=1:numel(thetaArrivalAngles)
    indx = find(thetaScanningAngles >= thetaArrivalAngles(j),1);
    line([thetaScanningAngles(indx) thetaScanningAngles(indx)],yL,'LineWidth',1,'Color','r','LineStyle','--');
end
xlabel('\theta')
ylabel('dB')

%% 1D-array case different source strengths

%Relative amplitude difference in decibel
amplitudes = [0 -5];

% Create input signal
inputSignal = createSignal(xPos, yPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles, amplitudes);

% Calculate delay-and-sum steered response
S = steeredResponseDelayAndSum(xPos, yPos, w, inputSignal, f, c,...
   thetaScanningAngles, phiScanningAngles);

%Normalise spectrum
spectrumNormalized = abs(S)/max(abs(S));

%Convert to decibel
spectrumLog = 10*log10(spectrumNormalized);

%Plot steered response
figure(2);clf
plot(thetaScanningAngles,spectrumLog)
grid on
xlim([thetaScanningAngles(1) thetaScanningAngles(end)])

yL = get(gca,'YLim');
for j=1:numel(thetaArrivalAngles)
    indx = find(thetaScanningAngles >= thetaArrivalAngles(j),1);
    line([thetaScanningAngles(indx) thetaScanningAngles(indx)],yL,'LineWidth',1,'Color','r','LineStyle','--');
end
xlabel('\theta')
ylabel('dB')


%% 2D-array case, spectrum in linear scale

% Create vectors of x- and y-coordinates of microphone positions 
[x, y] = meshgrid(-1:0.25:1,-1:0.25:1);
xPos = x(:)'; % 1xP vector of x-positions
yPos = y(:)'; % 1xP vector of y-positions
w = ones(1,numel(xPos))/numel(xPos); % 1xP vector of weighting

% Define arriving angles of input signals
thetaArrivalAngles = [30 20 30];
phiArrivalAngles = [10 70 210];

% Define array scanning angles
thetaScanningAngles = -90:0.5:90;
phiScanningAngles = 0:180;

% Create input signal
inputSignal = createSignal(xPos, yPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles);

% Calculate delay-and-sum steered response
[S, kx, ky] = steeredResponseDelayAndSum(xPos, yPos, w, inputSignal, f, c,...
   thetaScanningAngles, phiScanningAngles);

%Normalise spectrum
spectrumNormalized = abs(S)/max(max(abs(S)));

%Plot steered response
figure(3);clf
surf(kx, ky, spectrumNormalized, 'edgecolor', 'none', 'FaceAlpha', 0.8)
view(0, 90)
axis square

%Do some magic to make the figure look nice
set(gcf,'color','k')
cmap = colormap;
cmap(1,:) = [1 1 1]*0.2;
colormap(cmap);
set(gca,'color',[0 0 0],'xcolor',[1 1 1],'ycolor',[1 1 1],'zcolor',[1 1 1])
set(gca,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[])
set(gca,'XMinorGrid','on','YMinorGrid','on','ZMinorGrid','on','MinorGridColor',[1 1 1],'MinorGridLineStyle','-')
xlabel('k_x = sin(\theta)cos(\phi)')
ylabel('k_y = sin(\theta)sin(\phi)')

%% 2D-array case, different source strengths, spectrum in linear scale

%Relative amplitude difference between sources in decibel,
%could also have written amplitudes = [3 1 0]
amplitudes = [0 -2 -3];

% Create input signal
inputSignal = createSignal(xPos, yPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles, amplitudes);

% Calculate delay-and-sum steered response
[S, kx, ky] = steeredResponseDelayAndSum(xPos, yPos, w, inputSignal, f, c,...
   thetaScanningAngles, phiScanningAngles);

%Normalise spectrum
spectrumNormalized = abs(S)/max(max(abs(S)));

% Plot the steered response
figure(4);clf
surf(kx, ky, spectrumNormalized, 'edgecolor', 'none', 'FaceAlpha', 0.8)
view(0, 90)
axis square

%Do some magic to make the figure look nice
set(gcf,'color','k')
cmap = colormap;
cmap(1,:) = [1 1 1]*0.2;
colormap(cmap);
set(gca,'color',[0 0 0],'xcolor',[1 1 1],'ycolor',[1 1 1],'zcolor',[1 1 1])
set(gca,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[])
set(gca,'XMinorGrid','on','YMinorGrid','on','ZMinorGrid','on','MinorGridColor',[1 1 1],'MinorGridLineStyle','-')
xlabel('k_x = sin(\theta)cos(\phi)')
ylabel('k_y = sin(\theta)sin(\phi)')

%% 2D-array case, different source strengths, spectrum in logarithmic scale

%Convert the delay-and-sum steered response to decibel
spectrumLog = 10*log10(spectrumNormalized);

% Plot the steered response
figure(5);clf
surf(kx, ky, spectrumLog, 'edgecolor', 'none', 'FaceAlpha', 0.8)
view(0, 90)
axis square

%Do some magic to make the figure look nice
set(gcf,'color','k')
cmap = colormap;
cmap(1,:) = [1 1 1]*0.2;
colormap(cmap);
set(gca,'color',[0 0 0],'xcolor',[1 1 1],'ycolor',[1 1 1],'zcolor',[1 1 1])
set(gca,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[])
set(gca,'XMinorGrid','on','YMinorGrid','on','ZMinorGrid','on','MinorGridColor',[1 1 1],'MinorGridLineStyle','-')
xlabel('k_x = sin(\theta)cos(\phi)')
ylabel('k_y = sin(\theta)sin(\phi)')

%% 2D-array case, different source strengths, spectrum in logarithmic scale with dynamic range 

%Dynamic range in decibels
dynamicRange = 5;

% Plot the steered response
figure(6);clf
surf(kx, ky, spectrumLog, 'edgecolor', 'none', 'FaceAlpha', 0.8)
view(0, 90)
axis square

%Do some magic to make the figure look nice
set(gcf,'color','k')
cmap = colormap;
cmap(1,:) = [1 1 1]*0.2;
colormap(cmap);
set(gca,'color',[0 0 0],'xcolor',[1 1 1],'ycolor',[1 1 1],'zcolor',[1 1 1])
set(gca,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[])
set(gca,'XMinorGrid','on','YMinorGrid','on','ZMinorGrid','on','MinorGridColor',[1 1 1],'MinorGridLineStyle','-')
xlabel('k_x = sin(\theta)cos(\phi)')
ylabel('k_y = sin(\theta)sin(\phi)')

%Set the dynamic range
caxis([-dynamicRange 0])

%% 2D-array case, different source strengths, use plotSteeredResponse function

%Max range in decibels
maxDynamicRange = 30;

%Plot the steered response, no need to normalise the
%spectrum or converting to decibel before input
plotSteeredResponse(S, kx, ky, maxDynamicRange, 'lin', 'black', '3D')

