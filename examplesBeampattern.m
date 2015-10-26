%% Examples on how to calculate array factor / beampattern

%% Create 2D array

% Position of sensors and weighting of 2D array
[x, y] = meshgrid(-0.5:0.25:0.5,-0.5:0.25:0.5);
xPos = x(:)'; % 1xP vector of x-positions
yPos = y(:)'; % 1xP vector of y-positions
w = ones(1,length(xPos)); % 1xP vector of weighting factors

%% Plot array geometry and array factor for different frequencies

% Wave-frequency and wave-speed
f = [250 500 1e3 1.3e3];
c = 340;

% Scanning angles
theta = -90:90;
phi = 0;

%Calculate and plot the array pattern for various frequencies
figure(1);clf
subplot(121)
scatter(xPos, yPos,'filled')
title('Array geometry','FontWeight','Normal')
axis square
for ff = f
    W = arrayFactor(xPos, yPos, w, ff, c, theta, phi);
    W = 20*log10(W);
    
    subplot(122)
    plot(theta,W);
    hold on
end
xlabel('\theta');ylabel('dB');axis square
grid on
title('Array factor','FontWeight','Normal')
axis([theta(1) theta(end) -30 0])

%% View 3D plot for all scanning angles for single frequency

% Wave-frequency and wave-speed
f = 1e3;
c = 340;

[W, theta, phi, k_x, k_y] = arrayFactor(xPos, yPos, w, f, c, -90:90, 90:270, 20);
W = 20*log10(W);

%Don't display values below a certain threshold
dBmin = 50;
W(W<-dBmin) = NaN;

%Plot array factor
figure(2);clf
colormap('jet')

subplot(211)
h = surf(repmat(phi',1,length(theta))'/pi*180,repmat(theta,length(phi),1)'/pi*180,W);
set(h,'edgecolor','none')
xlabel('\phi');ylabel('\theta');colorbar
zlim([-dBmin 0])

subplot(212)
h = surf(k_x,k_y,W);
set(h,'edgecolor','none')
xlabel('k_x');ylabel('k_y');colorbar;
zlim([-dBmin 0])

%% Plot with steering

% Wave-frequency and wave-speed
f = [750 1e3];
c = 340;

% Scanning angles
theta = -60:0.5:60;
phi = 0;

% Steering angle
s_theta = -20;

% Calculate and plot the array factor
figure(3);clf
hold on
for ff = f
    W = arrayFactor(xPos, yPos, w, ff, c, theta, phi, s_theta);
    W = 20*log10(W);
    
    plot(theta,W,'DisplayName',[num2str(ff*1e-3) 'kHz']);
end

xlabel('\theta');ylabel('dB')
grid on
axis([theta(1) theta(end) -30 0])
legend(gca,'show')
title(['Steering angle ' num2str(s_theta) ' degrees'],'FontWeight','Normal')
yL = get(gca,'YLim');
indx = find(theta >= s_theta,1);
line([theta(indx) theta(indx)],yL,'LineWidth',1,'Color','r','LineStyle','--');


%% Plot array factor from 0 to 10 kHz

% Wave-frequency and wave-speed
f = 0:10:10e3;
c = 340;

% Scanning angles
theta = -90:0.2:90;
phi = 0;

%Preallocating for speed
W_all = zeros(numel(f),numel(theta));

%Calculate array factor
for k = 1:length(f)
    W = arrayFactor(xPos, yPos, w, f(k), c, theta, phi);
    W_all(k,:) = 20*log10(W);
end

%Don't display values below a certain threshold
dBmin = 30;
W_all(W_all<-dBmin) = NaN;

%Plot array factor
figure(4);clf
imagesc(f*1e-3,theta,W_all')
xlabel('kHz');ylabel('\theta')
colorbar('northoutside','direction','reverse')

    
    
    
    