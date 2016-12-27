function w = weightingVectorMinimumVariance(xPos, yPos, zPos, inputSignal, f, c, thetaScanningAngle, phiScanningAngle)
%weightingVectorMinimumVariance - minimum variance optimal weights
%
%Calculates the optimal minimum variance weights for a specific array with
%a specific input signal and specific scanning angle
%
%w = weightingVectorMinimumVariance(xPos, yPos, inputSignal, f, c, thetaScanningAngle, phiScanningAngle)
%
%IN
%xPos                - 1xP vector of x-positions [m]
%yPos                - 1xP vector of y-positions [m]
%inputSignal         - PxL vector of inputsignals consisting of L samples
%f                   - Wave frequency [Hz]
%c                   - Speed of sound [m/s]
%thetaScanningAngle  - Single theta scanning angle [degrees]
%phiScanningAngle    - Single phi scanning angle [degrees]
%
%OUT
%w                   - 1xP vector of complex optimal weights


%Set up variables
nSensors = size(inputSignal,1);
nSamples = size(inputSignal,2);

%Calculate steering vector for all scanning angles
e = squeeze(steeringVector(xPos, yPos, zPos, f, c, thetaScanningAngle, phiScanningAngle));

%Calculate correlation matrix with diagonal loading
R = inputSignal*inputSignal';
R = R + trace(R)/(nSensors^2)*eye(nSensors, nSensors);
R = R/nSamples;

%Calculate weighting vector
w = (R\e)/(e'*(R\e));
w = w';