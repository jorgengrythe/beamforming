function [ee, u, v] = steeringVector(xPos, yPos, f, c, thetaAngles, phiAngles)
%steeringVector - calculate steering vector of array
%
%Calculates the steering vector for different scanning angles
%
%[ee, u, v] = steeringVector(xPos, yPos, f, c, theta, phi)
%
%IN
%xPos         - 1xP vector of x-positions [m]
%yPos         - 1xP vector of y-positions [m]
%f            - Wave frequency [Hz]
%c            - Speed of sound [m/s]
%thetaAngles  - 1xM vector of theta angles [degrees]
%phiAngles    - 1xN vecor of phi angles [degrees]
%
%OUT
%ee     - MxNxP matrix of steering vectors
%u      - u coordinates in UV-space [sin(theta)*cos(phi)]
%v      - v coordinates in UV space [sin(theta)*sin(phi)]
%
%Created by J?rgen Grythe, Squarehead Technology AS
%Last updated 2016-09-02

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
P = size(xPos, 2);

%Calculating wave vector in spherical coordinates
if isvector(thetaAngles)
    u = sin(thetaAngles)'*cos(phiAngles);
    v = sin(thetaAngles)'*sin(phiAngles);
    
else
    u = sin(thetaAngles).*cos(phiAngles);
    v = sin(thetaAngles).*sin(phiAngles);
end


%Calculate steering vector/matrix 
uu = bsxfun(@times, u, reshape(xPos, 1, 1, P));
vv = bsxfun(@times, v, reshape(yPos, 1, 1, P));
ee = exp(1j*k*(uu+vv));

