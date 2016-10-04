function [W, u, v] = arrayFactor(xPos, yPos, w, f, c, thetaScanAngles, phiScanAngles, thetaSteerAngle, phiSteerAngle)
%arrayFactor - Calculate array factor of 1D or 2D array
%
%This matlab function calculates the array factor of a 1D or 2D array based
%on the position of the elements/sensors and the weight associated with
%each sensor. If no angle is given as input, the scanning angle is theta
%from -90 to 90, and phi from 0 to 360 degrees with 1 degree resolution
%
%[W, u, v] = arrayFactor(xPos, yPos, w, f, c, thetaScanningAngles, phiScanningAngles, thetaSteeringAngle, phiSteeringAngle)
%
%IN
%xPos            - 1xP vector of x-positions
%yPos            - 1xP vector of y-positions
%w               - 1xP vector of element weights
%f               - Wave frequency
%c               - Speed of sound
%thetaScanAngles - 1xM vector of theta scanning angles in degrees (optional)
%phiScanAngles   - 1XN vector of phi scanning angles in degrees (optional)
%thetaSteerAngle - Theta steering angle in degrees (optional)
%phiSteerAngle   - Phi steering angle in degrees (optional)
%
%OUT
%W               - calculated array factor
%u               - NxM matrix of u coordinates in UV space [sin(theta)*cos(phi)]  
%v               - NxM matrix of v coordinates in UV space [sin(theta)*sin(phi)] 
%
%
%Created by J?rgen Grythe, Squarehead Technology AS
%Last updated 2016-10-04


if ~isvector(xPos)
    error('X-positions of array elements must be a 1xP vector where P is number of elements')
end

if ~isvector(yPos)
    error('Y-positions of array elements must be a 1xP vector where P is number of elements')
end

if ~isvector(w)
    error('Weighting of array elements must be a 1xP vector where P is number of elements')
end

if ~isscalar(f)
    error('The input frequency must be a single value')
end


%theta is the elevation and is the normal incidence angle from -90 to 90
if ~exist('thetaScanAngles', 'var')
    thetaScanAngles = -pi/2:pi/180:pi/2;
else
    thetaScanAngles = thetaScanAngles*pi/180;
end

%phi is the azimuth, and is the angle in the XY-plane from 0 to 360
if ~exist('phiScanAngles', 'var')
    phiScanAngles = 0:pi/180:2*pi;
else
    phiScanAngles = phiScanAngles*pi/180;
end

%theta, phi steering angles
if ~exist('thetaSteerAngle', 'var')
    thetaSteerAngle = 0;
else
    thetaSteerAngle = thetaSteerAngle*pi/180;
end

if ~exist('phiSteerAngle', 'var')
    phiSteerAngle = 0;
else
    phiSteerAngle = phiSteerAngle*pi/180;
end




%Wavenumber
k = 2*pi*f/c;

%Number of elements/sensors in the array
P = length(xPos);

%Calculating wave vector in spherical coordinates
if isvector(thetaScanAngles)
    
    %Size of vectors containing theta and phi angles
    M = length(thetaScanAngles);
    N = length(phiScanAngles);
    
    %Calculate UV coordinates
    u = sin(thetaScanAngles)'*cos(phiScanAngles);
    v = sin(thetaScanAngles)'*sin(phiScanAngles);
        
    % Apply steering
    us = u - sin(thetaSteerAngle)*cos(phiSteerAngle);
    vs = v - sin(thetaSteerAngle)*sin(phiSteerAngle);
    
else
    
    %Size of matrix containing theta and phi angles
    [M, N] = size(thetaScanAngles);
    
    %Calculate UV coordinates
    u = sin(thetaScanAngles).*cos(phiScanAngles);
    v = sin(thetaScanAngles).*sin(phiScanAngles);
        
    % Apply steering
    us = u - sin(thetaSteerAngle).*cos(phiSteerAngle);
    vs = v - sin(thetaSteerAngle).*sin(phiSteerAngle);
end


%Calculate array factor
uu = bsxfun(@times, us, reshape(xPos, 1, 1, P));
vv = bsxfun(@times, vs, reshape(yPos, 1, 1, P));
ww = repmat(reshape(w, 1, 1, P), M, N);

W = sum(ww.*exp(1j*k*(uu+vv)), 3);

%Normalising
W = abs(W)./max(max(abs(W)));

%
%                 N
%W(theta, phi) = sum [ w_n * exp{jk(u*x_n + v*y_n)} ]
%                n=1
%
%u = 
%|sin(theta_0)*cos(phi_0) sin(theta_0)*cos(phi_1) .. sin(theta_0)*cos(phi_N)|
%|sin(theta_1)*cos(phi_0) sin(theta_1)*cos(phi_1) .. sin(theta_1)*cos(phi_N)|
%|    .                           .                         .               |
%|sin(theta_M)*cos(phi_0) sin(theta_M)*cos(phi_1) .. sin(theta_M)*cos(phi_N)|

%v = 
%|sin(theta_0)*sin(phi_0) sin(theta_0)*sin(phi_1) .. sin(theta_0)*sin(phi_N)|
%|sin(theta_1)*sin(phi_0) sin(theta_1)*sin(phi_1) .. sin(theta_1)*sin(phi_N)|
%|    .                           .                         .               |
%|sin(theta_M)*sin(phi_0) sin(theta_M)*sin(phi_1) .. sin(theta_M)*sin(phi_N)|

%uu = 
%   --------
%  /       /|
% / xPos  / |
%---------  | M (length theta)
%|       |  |
%|   u   |  /
%|       | / P (# elements)
%---------/
%   N (length phi)

%ww = 
%   --------
%  / w_P   /|
% /       / |
%---------  | M
%|w1   w1|  |
%|   w1  |  /
%|w1   w1| / P (# elements)
%---------/
%   N