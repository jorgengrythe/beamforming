%% Help figure to visualise vectors in spherical coordinates

%Set angles to vector that shall be visualised
theta = 45;
phi = -20;


%Vector coordinates
u = sin(theta*pi/180)*cos(phi*pi/180);
v = sin(theta*pi/180)*sin(phi*pi/180);
w = cos(theta*pi/180);

%Half sphere
[sx, sy, sz] = sphere(100);
%sz(find(sz < 0)) = 0;

%Set color for lines ++
cmap = [1 1 1];

fig = figure;
fig.Color = 'w';
ax = axes('Parent', fig);
hold(ax, 'on')

%Plot sphere
surf(ax, sx,sy,sz, 'edgecolor', 'none', 'Facecolor', cmap, 'FaceAlpha', 0.2)
plot(ax, cos(0:pi/50:2*pi), sin(0:pi/50:2*pi), 'Color', cmap)

%Plot the vector with help lines
line(ax, [0 u], [0 v], [0 w], 'LineWidth', 1.5, 'Color', [1.0000 0.9059 0.0941])
line(ax, [u u], [v v], [0 w], 'Color', cmap, 'LineStyle',':')
line(ax, [0 u], [0 v], [0 0], 'Color', cmap, 'LineStyle',':')
line(ax, [0 u], [0 v], [w w], 'Color', cmap, 'LineStyle',':')

%Plot coordinate system lines
line(ax, [0 1], [0 0], [0 0], 'Color', cmap)
line(ax, [0 0], [0 1], [0 0], 'Color', cmap)
line(ax, [0 0], [0 0], [-1 1], 'Color', cmap)
text(ax, 0.8, -0.1, 'u', 'color', cmap, 'fontweight', 'bold')
text(ax, -0.2, 0.9, 'v', 'color', cmap, 'fontweight', 'bold')
text(ax, 0, -0.1, 0.9, 'w', 'color', cmap, 'fontweight', 'bold')
text(ax, u/10, v/10,0.2, '\theta', 'color', cmap)
text(ax, 0.1, 0.2,0, '\phi', 'color', cmap)

%Set colors and view axis ++
view(ax, 30, 15)
ax.Color = 'k';
ax.XColor = cmap;
ax.YColor = cmap;
ax.ZColor = cmap;
ax.XMinorGrid = 'on';
ax.YMinorGrid = 'on';
ax.ZMinorGrid = 'on';
ax.MinorGridColor = cmap;
ax.MinorGridLineStyle = '-';
axis(ax, 'equal')
title(ax, ['\theta = ' num2str(theta) ', \phi = ' num2str(phi)], 'FontWeight','Normal')
