function [] = plotWavefield(f, c, fs, T, thetaArrivalAngles, phiArrivalAngles, amplitudes)

if isscalar(f)
    f = f*ones(1,numel(thetaArrivalAngles));
end

if ~exist('amplitudes','var')
    amplitudes = ones(1,numel(thetaArrivalAngles));
end

% Grid-points for calculating the field
[x, y] = meshgrid(-0.5:0.02:0.5,-0.5:0.02:0.5);
nPoints = size(x,1);
xPoints = x(:)';
yPoints = y(:)';
nSamples = T*fs;
t = 0:1/fs:nSamples/fs-1/fs;

signal_field = 0;
for k = 1:numel(thetaArrivalAngles)
    doa = squeeze(steeringVector(xPoints, yPoints, f(k), c, thetaArrivalAngles(k), phiArrivalAngles(k)));
    signal = 10^(amplitudes(k)/20)*doa*exp(1j*2*pi*f(k)*t);
    signal_field = signal_field + signal;  
end


figure(11);clf
set(gcf,'color','w')
colormap('spring')
cmap = [1 1 1]*0.5;
%plot(0.5*cos(0:pi/50:2*pi),0.5*sin(0:pi/50:2*pi),'Color',[1 1 1],'linewidth',1.5)
hold on
set(gca,'color',[0 0 0],'xcolor',cmap,'ycolor',cmap,'zcolor',cmap)
set(gca,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[])
set(gca,'XMinorGrid','on','YMinorGrid','on','ZMinorGrid','on','MinorGridColor',[1 1 1],'MinorGridLineStyle','-')
axis([-0.5 0.5 -0.5 0.5 -0.5 0.5])
view(110,25)
text(0.46,-0.5,-0.45,'x','color',[1 1 1])
text(-0.5,0.46,-0.45,'y','color',[1 1 1])
text(-0.5,-0.5,0.46,'z','color',[1 1 1])

z = reshape(real(signal_field(:,1))'/25,nPoints,nPoints);
h = surf(x,y,z,'edgecolor','none','FaceAlpha',0.7');
h.ZDataSource = 'z';

title(['t = ' num2str(sprintf('%0.1f',t(1)*1e3)) ' ms'],'fontweight','normal')
    
for sample = 2:nSamples
    pause(0.01)
    
    z = reshape(real(signal_field(:,sample))'/25,nPoints,nPoints);
    refreshdata(h, 'caller')
    
    title(['t = ' num2str(sprintf('%0.1f',t(sample)*1e3)) ' ms'],'fontweight','normal')
    
end