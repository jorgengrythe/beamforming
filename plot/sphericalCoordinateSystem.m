%% Help figure to visualise vectors in spherical coordinates

theta = 35;
phi = 60;

%Vector coordinates
lx = sin(theta*pi/180)*cos(phi*pi/180);
ly = sin(theta*pi/180)*sin(phi*pi/180);
lz = cos(theta*pi/180);

%Half sphere
[sx, sy, sz] = sphere(100);
sz(find(sz < 0)) = 0;

%Set color for lines ++
cmap = [1 1 1];

h = figure(1);
set(gcf,'color','w')
hold on

%Plot sphere
surf(sx,sy,sz,'edgecolor','none','Facecolor',cmap,'FaceAlpha',0.2)
plot(cos(0:pi/50:2*pi),sin(0:pi/50:2*pi),'Color',cmap)

%Plot the vector with help lines
line([0 lx],[0 ly],[0 lz],'LineWidth',1.5,'Color',[1.0000 0.9059 0.0941])
line([lx lx],[ly ly],[0 lz],'Color',cmap,'LineStyle',':')
line([0 lx],[0 ly],[0 0],'Color',cmap,'LineStyle',':')
line([0 lx],[0 ly],[lz lz],'Color',cmap,'LineStyle',':')

%Plot coordinate system lines
%x-lines
line([0 1],[0 0],[0 0],'Color',cmap)
line([-1 1],[1 1],[0 0],'Color',cmap)
%y-lines
line([0 0],[0 1],[0 0],'Color',cmap)
line([-1 -1],[-1 1],[0 0],'Color',cmap)
%z-lines
line([0 0],[0 0],[0 1],'Color',cmap)
line([-1 -1],[1 1],[0 1],'Color',cmap)
%text
text(0.8,-0.1,'x','color',cmap)
text(-0.2,0.9,'y','color',cmap)
text(0,-0.1,0.9,'z','color',cmap)
text(lx/10,ly/10,0.2,'\theta','color',cmap)
text(0.1,0.2,0,'\phi','color',cmap)

%Set colors and view axis ++
view(30,30)
set(gca,'color',[0 0 0],'xcolor',cmap,'ycolor',cmap,'zcolor',cmap)
set(gca,'XTickLabel',[],'YTickLabel',[],'ZTickLabel',[])
set(gca,'XMinorGrid','on','YMinorGrid','on','ZMinorGrid','on','MinorGridColor',cmap,'MinorGridLineStyle','-')
axis equal
title(['\theta = ' num2str(theta) ', \phi = ' num2str(phi)],'FontWeight','Normal')
