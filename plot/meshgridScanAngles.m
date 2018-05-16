function [thetaScanAngles, phiScanAngles, scanPointsX, scanPointsY] = meshgridScanAngles(maxAngleX, maxAngleY, resolution)


%(x,y) position of scanning points
scanAxisX = tan((-maxAngleX:resolution:maxAngleX)*pi/180);
scanAxisY = tan((-maxAngleY:resolution:maxAngleY)*pi/180);

%Scanning points in meshgrid
[scanPointsY, scanPointsX] = meshgrid(scanAxisY,scanAxisX);

%Calculate theta, phi angles to each scanning point
[thetaScanAngles, phiScanAngles] = convertCartesianToSpherical(scanPointsX, scanPointsY, 1);