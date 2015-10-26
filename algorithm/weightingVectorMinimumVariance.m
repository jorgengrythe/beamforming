function w = weightingVectorMinimumVariance(x_pos, y_pos, inputSignal, f, c, thetaScanningAngle, phiScanningAngle)

%Set up variables
nSensors = size(inputSignal,1);
nSamples = size(inputSignal,2);

%Calculate steering vector for all scanning angles
e = squeeze(steeringVector(x_pos, y_pos, f, c, thetaScanningAngle, phiScanningAngle));

%Calculate correlation matrix with diagonal loading
R = inputSignal*inputSignal';
R = R + trace(R)/(nSensors^2)*eye(nSensors, nSensors);
R = R/nSamples;

%Calculate weighting vector
w = (R\e)/(e'*(R\e));
w = w';