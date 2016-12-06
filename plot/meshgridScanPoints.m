function [scanPointsX, scanPointsY, thetaScanAngles, phiScanAngles] = meshgridScanPoints(maxX, maxY, zDist, nPointsX, nPointsY)


%(x,y) position of scanning points
scanAxisX = -maxX:2*maxX/(nPointsX-1):maxX;
scanAxisY = -maxY:2*maxY/(nPointsY-1):maxY;

%Scanning points in meshgrid
[scanPointsX, scanPointsY] = meshgrid(scanAxisX, scanAxisY);

%Calculate theta, phi angles to each scanning point
[thetaScanAngles, phiScanAngles] = convertCartesianToSpherical(scanPointsX, scanPointsY, zDist);