function [thetaAngles, phiAngles] = convertCartesianToSpherical(xPos, yPos, zPos)
% Get spherical angles in 3D space from cartesian coordinates
%
%[thetaAngles, phiAngles] = convertCartesianToSpherical(xPos, yPos, zPos)
%
%IN
%xPos - x-positions [m]
%yPos - y-positions [m]
%zPos - z-position [m]
%
%OUT
%thetaAngles - theta angles [deg]
%phiAngles - phi angles [deg]
%
%Created by J?rgen Grythe
%Last updated 2016-11-29

thetaAngles = atan(sqrt(xPos.^2+yPos.^2)./zPos);
phiAngles = atan(yPos./xPos);

thetaAngles = thetaAngles*180/pi;
phiAngles = phiAngles*180/pi;
thetaAngles(xPos<0) = -thetaAngles(xPos<0);

thetaAngles(isnan(thetaAngles)) = 0;
phiAngles(isnan(phiAngles)) = 0;

end
