function [anglex, angley, pow] = sweepPow2(Xm, Ym, Zm, Wm, data, fs, filterFrequencies, distance, maxX, maxY, anglRes, block, deltaX, deltaY)
%[anglex,angley, pow] = sweepPow2(Xm, Ym, Zm, Wm, data, fs, filterFrequencies, distance, maxX, maxY, anglRes, block)
%
%INPUT
%Xm, Ym, Zm - Microphone coordinates
%Wm         - Microphone weighting
%data       - nMics x nSamples matrix of data
%fs         - Sampling frequency [Hz]
%filterFrequencies - Two element vector of lower and upper filter frequency [Hz]
%distance  - Distance to scanning plane [m]
%maxX      - Max X scanning extent [m]
%maxY      - Max Y scanning extent [m]
%anglRes   - Angle resolution [deg]
%block     - How many time samples to use for the calculation
%deltaX    - add a scanning offset other than (0, 0)
%deltaY    - add a scanning offset other than (0, 0)
%
%OUTPUT
%anglex    - X scanning angles in degrees
%angley    - Y scanning angles in degrees
%pow       - The calculated steered response power

if nargin < 14
    deltaY = 0;
end

if nargin < 13
    deltaX = 0;
end

if nargin < 12
    block = 1024;
else
    block = round(block);
end

if nargin < 11
    anglRes = 1;
end

if nargin < 10
    maxY = 1;
end

if nargin < 9
    maxX = 1;
end

if nargin < 8
   distance = 1; 
end

if nargin < 7
   distance = 1; 
end

if nargin < 6
   filterFrequencies = [1e3, 5e3]; 
end

if nargin < 5
    fs = 44.1e3;
end


c=340;
M = length(Xm);

%Create bandpass filter and filter the data
[bfir, a] = fir1(128, filterFrequencies./fs*2);
data = filter(bfir, a, data, [], 2);

% Maximum x,y scanning angles in degrees
maxAngleX = atand(maxX/distance);
maxAngleY = atand(maxY/distance);

% x,y scanning angles in degrees
anglex = -maxAngleX:anglRes:maxAngleX;
angley = -maxAngleY:anglRes:maxAngleY;

% Scanning point in grid
ux = distance*tand(anglex)+deltaX;
uy = distance*tand(angley)+deltaY;
uz = distance;

%Calculate the steered response
nAnglesX = length(anglex);
nAnglesY = length(angley);
pow = zeros(nAnglesX, nAnglesY);
wb = waitbar(0, 'Calculating..');
for nax = 1:nAnglesX
    waitbar(nax/nAnglesX, wb)
    for may = 1:nAnglesY

        % Distance from scanning point to microphones
        uxx = ux(nax);
        uyy = uy(may);
        ds = sqrt((Xm - uxx).^2 + (Ym - uyy).^2 + (Zm -uz).^2) - sqrt(uxx^2 + uyy^2 + uz^2);
        ds = ds+distance;
        
        %Delay and sum
        dt = round((ds./c).*fs); %time delay
        data2 = zeros(M, block);
        for mic = 1:M
            data2(mic, 1:block) = Wm(mic).*data(mic, 1+dt(mic):dt(mic)+block);
        end
        tmp = sum(data2, 1);
        pow(nax, may) = sum(tmp.^2)/block;
        
    end
end
close(wb)
end


