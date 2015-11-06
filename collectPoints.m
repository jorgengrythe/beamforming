function collectPoints

xPos = [];
yPos = [];
f = 1e3;
c = 340;
fs = 44.1e3;
thetaArrivalAngles = 0;
phiArrivalAngles = 0;
thetaScanningAngles = -90:0.1:90;
phiScanningAngles = 0;


% Create figure and axes
fig = figure;

axArray = subplot(211);
axArray.XLim = [-1 1];
axArray.YLim = [-1 1];
axArray.ButtonDownFcn = {@drawPoint};
hold(axArray, 'on');
box(axArray, 'on')
axArray.XTick = [-1 -0.75 -0.5 -0.25 0 0.25 0.5 0.75 1];
axArray.YTick = [-1 -0.75 -0.5 -0.25 0 0.25 0.5 0.75 1];
grid(axArray, 'on')
grid(axArray,'minor')
title(axArray,'Microphone positions', 'fontweight', 'normal');

axResponse = subplot(212);
box(axResponse, 'on')
title(axResponse,'Beampattern', 'fontweight', 'normal');
xlabel(axResponse, '\theta');
ylabel(axResponse, 'dB');
axResponse.XLim = [thetaScanningAngles(1) thetaScanningAngles(end)];
axResponse.YLim = [-40 1];
hold(axResponse, 'on');
grid(axResponse, 'on')
grid(axResponse,'minor')
axResponse.NextPlot = 'replacechildren';

    function drawPoint(obj,eventData)
        
        %If the right button is pressed not on a point, do nothing
        if strcmp(obj.Parent.SelectionType,'alt')
            disp(xPos)
            cla(axArray)
            cla(axResponse)
            xPos = [];
            yPos = [];
        else
            plot(axArray,eventData.IntersectionPoint(1),...
                eventData.IntersectionPoint(2),'Marker','.','Color',[0 0.4470 0.7410],...
                'MarkerSize',15);
                      
            xPos = [xPos eventData.IntersectionPoint(1)];
            yPos = [yPos eventData.IntersectionPoint(2)];
            w = ones(1, numel(xPos))/numel(xPos);
            
            inputSignal = createSignal(xPos, yPos, f, c, fs, thetaArrivalAngles, phiArrivalAngles);
            S = steeredResponseDelayAndSum(xPos, yPos, w, inputSignal, f, c,...
                thetaScanningAngles, phiScanningAngles);
            
            spectrumLog = 10*log10(abs(S)/max(abs(S)));

            plot(axResponse, thetaScanningAngles, spectrumLog)


        end
        
        
    end


end


