function [thetaScanningAngles, phiScanningAngles] = meshgridScanningAngles(coveringAngleX, coveringAngleY, resolution)


%(x,y) position of scanning points
distanceToScanningPlane = 1;
scanningAxisX = tan((-coveringAngleX:resolution:coveringAngleX)*pi/180);
scanningAxisY = tan((-coveringAngleY:resolution:coveringAngleY)*pi/180);

[scanningPointsY, scanningPointsX] = meshgrid(scanningAxisY,scanningAxisX);
[thetaScanningAngles, phiScanningAngles] = convertCartesianToPolar(scanningPointsX, scanningPointsY, distanceToScanningPlane);