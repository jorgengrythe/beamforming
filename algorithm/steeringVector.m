function [e, u, v, w] = steeringVector(xPos, yPos, zPos, f, c, thetaScanAngles, phiScanAngles)
%steeringVector - calculate steering vector of array
%
%Calculates the steering vector for different scanning angles
%Theta is the elevation and is the normal incidence angle
%Phi is the azimuth, and is the angle in the XY-plane
%
% [e, u, v, w] = steeringVector(xPos, yPos, zPos, f, c, thetaScanAngles, phiScanAngles)
%
%IN
%xPos            - 1xP vector of x-positions [m]
%yPos            - 1xP vector of y-positions [m]
%yPos            - 1xP vector of z-positions [m]
%f               - Wave frequency [Hz]
%c               - Speed of sound [m/s]
%thetaScanAngles - 1xM vector or MxN matrix of theta scanning angles [degrees]
%phiScanAngles   - 1xN vector or MxN matrix of of phi scanning angles [degrees]
%
%OUT
%e               - MxNxP matrix of steering vectors
%u               - MxN matrix of u coordinates in UV space [sin(theta)*cos(phi)]
%v               - MxN matrix of v coordinates in UV space [sin(theta)*sin(phi)]
%w               - MxN matrix of w coordinates in UV space [cos(theta)]
%
%Created by J?rgen Grythe
%Last updated 2017-02-27

if ~isvector(xPos)
    error('X-positions of array elements must be a 1xP vector where P is number of elements')
end

if ~isvector(yPos)
    error('Y-positions of array elements must be a 1xP vector where P is number of elements')
end

if ~isvector(yPos)
    error('Y-positions of array elements must be a 1xP vector where P is number of elements')
end


%Convert angles to radians
thetaScanAngles = thetaScanAngles*pi/180;
phiScanAngles = phiScanAngles*pi/180;
 
%Wavenumber
k = 2*pi*f/c;

%Number of elements/sensors in the array
P = numel(xPos);

%Calculating wave vector in spherical coordinates
if isvector(thetaScanAngles)
    N = numel(phiScanAngles);
    
    u = sin(thetaScanAngles)'*cos(phiScanAngles);
    v = sin(thetaScanAngles)'*sin(phiScanAngles);
    w = repmat(cos(thetaScanAngles)', 1, N);
else
    u = sin(thetaScanAngles).*cos(phiScanAngles);
    v = sin(thetaScanAngles).*sin(phiScanAngles);
    w = cos(thetaScanAngles);
end


%Calculate steering vector/matrix 
uu = bsxfun(@times, u, reshape(xPos, 1, 1, P));
vv = bsxfun(@times, v, reshape(yPos, 1, 1, P));
ww = bsxfun(@times, w, reshape(zPos, 1, 1, P));

e = exp(1j*k*(uu + vv + ww));

