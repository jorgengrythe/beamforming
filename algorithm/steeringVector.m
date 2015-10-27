function [ee, kx, ky] = steeringVector(xPos, yPos, f, c, thetaAngles, phiAngles)
%steeringVector - calculate steering vector of array
%
%Calculates the steering vector for different scanning angles
%
%[ee, kx, ky] = steeringVector(xPos, yPos, f, c, theta, phi)
%
%IN
%xPos	- 1xP vector of x-positions [m]
%yPos	- 1xP vector of y-positions [m]
%f      - Wave frequency [Hz]
%c      - Speed of sound [m/s]
%theta  - 1xM vector of theta angles [degrees]
%phi    - 1xN vecor of phi angles [degrees]
%
%OUT
%ee     - MxNxP matrix of steering vectors
%kx 	- theta scanning angles in polar coordinates
%ky 	- phi scanning angles in polar coordinates
%
%Created by Jørgen Grythe, Norsonic AS
%Last updated 2015-10-27

if ~isvector(xPos)
    error('X-positions of array elements must be a 1xP vector where P is number of elements')
end

if ~isvector(yPos)
    error('Y-positions of array elements must be a 1xP vector where P is number of elements')
end


%theta is the elevation and is the normal incidence angle from -90 to 90
if ~exist('thetaAngles', 'var')
    thetaAngles = -pi/2:pi/180:pi/2;
else
    thetaAngles = thetaAngles*pi/180;
end

%phi is the azimuth, and is the angle in the XY-plane from 0 to 360
if ~exist('phiAngles', 'var')
    phiAngles = 0:pi/180:2*pi;
else
    phiAngles = phiAngles*pi/180;
end
 
%Wavenumber
k = 2*pi*f/c;

%Number of elements/sensors in the array
P = size(xPos,2);

%Changing wave vector to spherical coordinates
kx = sin(thetaAngles)'*cos(phiAngles);
ky = sin(thetaAngles)'*sin(phiAngles);

%Calculate steering vector/matrix 
kxx = bsxfun(@times,kx,reshape(xPos,1,1,P));
kyy = bsxfun(@times,ky,reshape(yPos,1,1,P));
ee = exp(1j*k*(kxx+kyy));

