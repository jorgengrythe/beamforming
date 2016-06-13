function [W, kx, ky] = arrayFactor(xPos, yPos, w, f, c, thetaScanningAngles, phiScanningAngles, thetaSteeringAngle, phiSteeringAngle)
%arrayFactor - Calculate array factor of 1D or 2D array
%
%This matlab function calculates the array factor of a 1D or 2D array based
%on the position of the elements/sensors and the weight associated with
%each sensor. If no angle is given as input, the scanning angle is theta
%from -90 to 90, and phi from 0 to 360 degrees with 1 degree resolution
%
%[W, thetaScanningAngles, phiScanningAngles, kx, ky] = arrayFactor(xPos, yPos, w, f, c, thetaScanningAngles, phiScanningAngles, thetaSteeringAngle, phiSteeringAngle)
%
%IN
%xPos                - 1xP vector of x-positions
%yPos                - 1xP vector of y-positions
%w                   - 1xP vector of element weights
%f                   - Wave frequency
%c                   - Speed of sound
%thetaScanningAngles - 1xM vector of theta scanning angles in degrees (optional)
%phiScanningAngles   - 1XN vector of phi scanning angles in degrees (optional)
%thetaSteeringAngle  - Theta steering angle in degrees (optional)
%phiSteeringAngle    - Phi steering angle in degrees (optional)
%
%OUT
%W                   - calculated array factor
%kx                  - theta scanning angles in polar coordinates
%ky                  - phi scanning angles in polar coordinates
%
%
%Created by J?rgen Grythe, Squarehead Technology AS
%Last updated 2016-06-13


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
if ~exist('thetaScanningAngles', 'var')
    thetaScanningAngles = -pi/2:pi/180:pi/2;
else
    thetaScanningAngles = thetaScanningAngles*pi/180;
end

%phi is the azimuth, and is the angle in the XY-plane from 0 to 360
if ~exist('phiScanningAngles', 'var')
    phiScanningAngles = 0:pi/180:2*pi;
else
    phiScanningAngles = phiScanningAngles*pi/180;
end

%Scanning angles in theta, phi
if ~exist('thetaSteeringAngle', 'var')
    thetaSteeringAngle = 0;
else
    thetaSteeringAngle = thetaSteeringAngle*pi/180;
end

if ~exist('phiSteeringAngle', 'var')
    phiSteeringAngle = 0;
else
    phiSteeringAngle = phiSteeringAngle*pi/180;
end




%Wavenumber
k = 2*pi*f/c;

%Number of elements/sensors in the array
P = length(xPos);


if isvector(thetaScanningAngles)
    %Size of vector containing theta angles
    M = length(thetaScanningAngles);
    
    %Size of vector containing phi angles
    N = length(phiScanningAngles);
    
    %Changing wave vector to spherical coordinates (with steering)
    kx = sin(thetaScanningAngles)'*cos(phiScanningAngles) ...
        - sin(thetaSteeringAngle)*cos(phiSteeringAngle);
    ky = sin(thetaScanningAngles)'*sin(phiScanningAngles) ...
        - sin(thetaSteeringAngle)*sin(phiSteeringAngle);
    
else
    %Size of matrix containing theta angles
    [M, N] = size(thetaScanningAngles);
    
    %Changing wave vector to spherical coordinates
    kx = sin(thetaScanningAngles).*cos(phiScanningAngles) ...
        - sin(thetaSteeringAngle)*cos(phiSteeringAngle);
    ky = sin(thetaScanningAngles).*sin(phiScanningAngles) ...
        - sin(thetaSteeringAngle)*sin(phiSteeringAngle);
end


%Calculate array factor
kxx = bsxfun(@times, kx, reshape(xPos, 1, 1, P));
kyy = bsxfun(@times, ky, reshape(yPos, 1, 1, P));
ww = repmat(reshape(w, 1, 1, P), M, N);

W = sum(ww.*exp(1j*k*(kxx+kyy)),3);

%Normalising
W = abs(W)./max(max(abs(W)));

%
%                 N
%W(theta, phi) = sum [ w_n * exp{jk(k_x*x_n + k_y*y_n)} ]
%                n=1
%
%k_x = 
%|sin(theta_0)*cos(phi_0) sin(theta_0)*cos(phi_1) .. sin(theta_0)*cos(phi_N)|
%|sin(theta_1)*cos(phi_0) sin(theta_1)*cos(phi_1) .. sin(theta_1)*cos(phi_N)|
%|    .                           .                         .               |
%|sin(theta_M)*cos(phi_0) sin(theta_M)*cos(phi_1) .. sin(theta_M)*cos(phi_N)|

%k_y = 
%|sin(theta_0)*sin(phi_0) sin(theta_0)*sin(phi_1) .. sin(theta_0)*sin(phi_N)|
%|sin(theta_1)*sin(phi_0) sin(theta_1)*sin(phi_1) .. sin(theta_1)*sin(phi_N)|
%|    .                           .                         .               |
%|sin(theta_M)*sin(phi_0) sin(theta_M)*sin(phi_1) .. sin(theta_M)*sin(phi_N)|

%k_xx = 
%   --------
%  /       /|
% / x_pos / |
%---------  | M (length theta)
%|       |  |
%|  k_x  |  /
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