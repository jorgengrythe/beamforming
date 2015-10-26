function out=mmpolar(varargin)
%MMPOLAR Polar Plot with Settable Properties.
% MMPOLAR(Theta,Rho) creates a polar coordinate plot using the angle Theta
% in RADIANS and radius in Rho. Rho can contain negative values.
% MMPOLAR(Theta,Rho,S) creates the plot using the line spec given by S. See
% the function PLOT for information about S.
% MMPOLAR(Theta1,Rho1,S1,Theta2,Rho2,S2,...) plots all the defined curves.
%
% MMPOLAR(Theta1,Rho1,S1,...,'PName',PValue,...) plots all defined curves,
% and sets plot property names to the corresponding property values.
% MMPOLAR(Theta1,Rho1,S1,...,P) plots all the defined curves, and uses the
% structure P having fieldnames equal to plot property names to set
% corresponding property values contained in the associated fields.
%
% H=MMPOLAR(Theta,Rho,...) returns handles to lines or lineseries objects.
% For example, set(H,'LineWidth',2) sets all linewidths to 2 points.
% Note: 'LineWidth' is NOT a property that can be set with MMPOLAR. It must
% be set as shown above by using the SET function on the line handles H.
%
% MMPOLAR('PName',PValue,...) sets the property names to the corresponding
% property values. See below for property name/value pairs. Just as with
% the function SET 'PName' is case insensitive and need only be unique.
% MMPOLAR with no input argument returns a structure with fieldnames equal
% to property names each containing the associated property values.
% MMPOLAR(P) sets property values using the structure P as described above.
% MMPOLAR('PName') returns the property value associated with 'PName'.
% MMPOLAR({'PName1','PName2',...}) returns multiple property values in a
% cell array.
% MMPOLAR(Hax,...) uses the axes having handle Hax.
%
% Examples: MMPOLAR(Theta,Rho,S,'Style','compass') creates a polar plot with
% theta=0 pointing North and theta increasing in the clockwise direction.
%
% MMPOLAR(Theta,Rho,S) creates a cartesian polar plot where theta=0 is along
% the x-axis and theta increases in the counterclockwise direction.
%
% MMPOLAR works with HOLD, XLABEL, YLABEL, TITLE, ZOOM, SUBPLOT
% but does not work with AXIS, GRID (Use MMPOLAR properties to set these)
%
% See also POLAR, PLOT, HOLD
%
% PROPERTY          VALUE {Default}  DESCRIPTION
% Style             {cartesian} | compass  shortcut to two common polar
%                     styles. Cartesian: theta=0 points east and increases
%                     going north. Compass: theta=0 points north and
%                     increases going east. See TDirection and TZeroDirection.
% Axis              {on} | off  shortcut for grids, ticks, border,
%                     backgroundcolor, visibility
% Border            {on} | off  shortcut for axis border, tick mark visibility.
% Grid              {on} | off  shortcut for visibility of rho and theta grids
% RLimit            [Rmin Rmax] rho axis limits, may be negative values
% TLimit            [Tmin Tmax] theta axis limits in RADIANS
% RTickUnits        {''} string added to last rho tick label to denote units
% TTickScale        {degrees} | radians  theta axis tick label scaling
% TDirection        cw | {ccw} direction of increasing theta
% TZeroDirection    North | {East} | South | West  theta=0 axis direction
%
% BackgroundColor   {w}  colorspec for axis background color
% BorderColor       {k} colorspec for axis border and tick mark colors
% FontName          string  font name for tick labels
% FontSize          scalar  font size for tick labels
% FontWeight        {normal} | bold  font weight for tick labels
% TickLength        {.02} normalized length of rho and theta axis tick marks
%
% RGridColor        {k} colorspec for rho axis grid color
% RGridLineStyle    - | -- | {:} | -.  rho axis grid line style
% RGridLineWidth    {0.5}  rho axis grid line width in points
% RGridVisible      {on} | off  rho axis grid visibility
% RTickAngle        [scalar]  angular position of rho axis tick labels in
%                             TTickScale units
% RTickOffset       {.04} Normalized radial offset for rho tick labels
% RTickLabel        string cell array containing rho axis tick labels
% RTickLabelVisible {on} | off  visibility of rho axis tick labels
% RTickLabelHalign  {center} | left | right  horizontal
%                             alignment of rho axis tick labels
% RTickLabelValign  {middle} | top | cap | baseline | bottom  vertical
%                             alignment of rho axis tick labels
% RTickValue        [vector]  vector containing rho axis tick positions
% RTickVisible      {on} | off  rho axis tick visibility
%
% TGridColor        colorspec for theta axis grid color
% TGridLineStyle    - | -- | {:} | -.  theta axis grid line style
% TGridLineWidth    {0.5}  theta axis grid line width in points
% TGridVisible      {on} | off  theta axis grid visibility
% TTickDelta        theta axis tick spacing in TTickScale units
%                   {15 degrees or pi/12 radians}
% TTickDirection    {in} | out  direction of theta tick marks
% TTickOffset       {.08} normalized radial offset of theta tick labels
% TTickLabel        string cell array containing theta axis tick labels
% TTickLabelVisible {on} | off  visiblity of theta axis tick labels
% TTickSign         {+-} | + sign of theta tick labels
% TTickValue        [vector]  vector of theta ticks in TTickScale units
% TTickVisible      {on} | off  theta axis tick visibility

% D.C. Hanselman, University of Maine, Orono, ME 04469
% MasteringMatlab@yahoo.com
% Mastering MATLAB 7
% 2005-04-25, 2006-01-18, 2006-04-06, 2006-05-17, 2006-05-18
% 2006-10-03, 2007-03-04, 2008-03-18

%--------------------------------------------------------------------------
% Parse Inputs                                                 Parse Inputs
%--------------------------------------------------------------------------
% Find MMPOLAR axes if it exists
nargi=nargin;
% find MMPOLAR axes if it is supplied or if it is the current axes
if nargi>0 && isscalar(varargin{1}) && ishandle(varargin{1})
   HAxes=varargin{1}; % see if first argument is an MMPOLAR axes
   if strcmp(get(HAxes,'Tag'),'MMPOLAR_Axes')
      HFig=ancestor(HAxes,'figure');
      HoldIsON=strcmp(get(HAxes,'nextplot'),'add')...
            && strcmp(get(HFig,'nextplot'),'add');
      P=getappdata(HAxes,'MMPOLAR_Properties');
      Pfn=fieldnames(P);
      varargin(1)=[]; % strip initial axes handle off varargin
      nargi=nargi-1;  % varargin now contains rest of input arguments
   else
      local_error('First Argument is Not a Valid MMPOLAR Axes Handle.')
   end
else % see if MMPOLAR axes is current axes
   HFig=get(0,'CurrentFigure');
   if isempty(HFig)
      HAxes=[];
      Pfn=fieldnames(local_getDefaults);
      HoldIsON=false;
   else
      HAxes=get(HFig,'CurrentAxes');
      if isempty(HAxes)
         Pfn=fieldnames(local_getDefaults);
         HoldIsON=false;
      else
         if strcmp(get(HAxes,'Tag'),'MMPOLAR_Axes')
            HoldIsON=strcmp(get(HAxes,'nextplot'),'add')...
                  && strcmp(get(HFig,'nextplot'),'add');
            P=getappdata(HAxes,'MMPOLAR_Properties');
            Pfn=fieldnames(P);
         else % no MMPOLAR axes exists
            HAxes=[];
            Pfn=fieldnames(local_getDefaults);
            HoldIsON=false;
            set(HAxes,'NextPlot','replace') % hold off
         end
      end
   end
end
%--------------------------------------------------------------------------
% Consider input arguments                         Consider input arguments
%--------------------------------------------------------------------------
if nargi==0   % MMPOLAR() MMPOLAR() MMPOLAR() MMPOLAR() MMPOLAR() MMPOLAR()
   if ~isempty(HAxes)
      out=P; % return property structure if it exists
      return
   else
      local_error('No MMPOLAR Axes exists or is not Current Axes.')
   end
end
if nargi==1   % Consider SET and GET Requests Consider SET and GET Requests
   if ~isempty(HAxes)
      arg=varargin{1};
      if ischar(arg)   % MMPOLAR('Pname') MMPOLAR('Pname') MMPOLAR('Pname')
         [fn,errmsg]=local_isfield(Pfn,arg);
         error(errmsg)
         out=P.(fn);
         return
      elseif iscellstr(arg)              % MMPOLAR({'PName1','PName2',...})
         nc=length(arg);
         out=cell(1,nc);
         for k=1:nc
            [fn,errmsg]=local_isfield(Pfn,arg{k});
            error(errmsg)
            out{k}=P.(fn);
         end
         return
      elseif isstruct(arg)    % MMPOLAR(S) MMPOLAR(S) MMPOLAR(S) MMPOLAR(S)
         Sfn=fieldnames(arg);
         for k=1:length(Sfn)
            [fn,errmsg]=local_isfield(Pfn,Sfn{k});
            error(errmsg)
            S.(fn)=arg.(Sfn{k});
         end
         local_updatePlot(HAxes,S);
         return
      else
         local_error('Unknown Input Argument.')
      end
   else
      local_error('No MMPOLAR exists or is not Current Axes.')
   end
end
%           MMPOLAR('PName1',PValue1,'PName2',PValue2,'PName3',PValue3,...)
if rem(nargi,2)==0 && ischar(varargin{1}) && ~isempty(HAxes)
   for k=1:2:nargi-1
      PName=varargin{k};
      if ischar(PName)
         [fn,errmsg]=local_isfield(Pfn,PName);
         error(errmsg)
         S.(fn)=varargin{k+1};
      else
         local_error('String Input Property Name Argument Expected.')
      end
   end
   local_updatePlot(HAxes,S)
   return
elseif ischar(varargin{1})      % Unknown Input Unknown Input Unknown Input
   local_error('Unknown Input Arguments or NO MMPOLAR Axes Exists.')
   
elseif isnumeric(varargin{1})%MMPOLAR(Theta,Rho,...) MMPOLAR(Theta,Rho,...)
   % find out if there are appended 'PName',PValue pairs or a structure P
   last=[];
   k=3; % 'Pname' or P can't appear before 3rd argument
   while k<=nargi 
      vark=varargin{k};
      k=k+1;
      if ischar(vark)
         fn=local_isfield(Pfn,vark);
         if ~isempty(fn)
            if isempty(last)
               last=k-1;
            end
            S.(fn)=varargin{k};
            k=k+1; % skip known PValue
         end
      elseif isstruct(vark) % found appended structure
         if isempty(last)
            last=k-1;
         end
         Sfn=fieldnames(vark);
         for ki=1:length(Sfn)
            [fn,errmsg]=local_isfield(Pfn,Sfn{ki});
            error(errmsg)
            S.(fn)=vark.(Sfn{ki});
         end
      end
   end
   if ~isempty(last)
      varargin(last:end)=[]; % strip properties and values from input
   end
else
   local_error('Unknown Input Arguments.')
end
%--------------------------------------------------------------------------
% Now have valid data for plotting         Now have valid data for plotting
%--------------------------------------------------------------------------
if HoldIsON % a current held plot exists
   
   D=getappdata(HAxes,'MMPOLAR_Data');                    % get stored data
   P=getappdata(HAxes,'MMPOLAR_Properties');
   
   tmpaxes=axes('Position',get(HAxes,'Position'));
   try % the plot function should work with new data
      Hlines=plot(tmpaxes,varargin{:});
   catch
      delete(tmpaxes)
      local_error('Input Arguments Not Understood.')
   end
   D.TData=[D.TData; get(Hlines,{'XData'})];   % add to held data
   D.RData=[D.RData; get(Hlines,{'YData'})];
   D.LineColor=[D.LineColor; get(Hlines,{'Color'})];
   D.LineStyle=[D.LineStyle; get(Hlines,{'LineStyle'})];
   D.Marker=[D.Marker; get(Hlines,{'Marker'})];
   D.NumLines=length(D.TData);
   
   delete(Hlines)                % got the data, lines are no longer needed
   delete(D.HLines)              % delete original lines as well
   
   set(tmpaxes,'NextPlot','add') % hold on
   for k=1:D.NumLines        % plot ALL data to find new RTicks and RLimits
      plot(tmpaxes,D.TData{k},D.RData{k})
   end
   P.RLimit=get(tmpaxes,'YLim');                          % Rho axis limits
   P.RTickValue=get(tmpaxes,'YTick');              % Default Rho axis ticks
   delete(tmpaxes)                        % Temporary axes no longer needed
   [P,D]=local_getRTickValue(HAxes,P,D);              % get rho tick values
   
   D.RDataN=cell(D.NumLines,1);
   for k=1:D.NumLines % normalize rho data for plotting
      D.TData(k)={mod(D.TData{k},2*pi)}; % map theta into [0 2*pi]
      D.RDataN(k)={(D.RData{k}-D.RMin)/D.RLimitDiff};
   end
   
   P.TLimit=[0 2*pi];                                    % plot full circle
   [P,D]=local_getTTickValue(P,D);                  % get theta tick values
   [P,D]=local_placeAxesPatch(HAxes,P,D,1);% draw axes patch, border, ticks
   [P,D]=local_placeRGrid(HAxes,P,D,1);                     % Draw Rho Grid
   [P,D]=local_placeTGrid(HAxes,P,D,1);                   % Draw Theta Grid
   [P,D]=local_placeTTickLabel(HAxes,P,D,1);        % Add Theta Tick Labels
   [P,D]=local_placeRTickLabel(HAxes,P,D,1);         % Add Rho Tick Lablels
      
else % Hold is OFF
   
   try % the plot function should work now
      HAxes=newplot; % create axes
      D.HLines=plot(HAxes,varargin{:});
   catch
      delete(gcf)
      local_error('Input Arguments Not Understood.')
   end
   HFig=ancestor(HAxes,'figure');
   D.NumLines=length(D.HLines);                  % get all data for storage
   D.TData=get(D.HLines,{'XData'});
   D.RData=get(D.HLines,{'YData'});
   D.LineColor=get(D.HLines,{'Color'});
   D.LineStyle=get(D.HLines,{'LineStyle'});
   D.Marker=get(D.HLines,{'Marker'});
   
   P=local_getDefaults;          % get default properties, update as needed
   
   P.RLimit=get(HAxes,'YLim');                            % Rho axis limits
   P.RTickValue=get(HAxes,'YTick');                % Default Rho axis ticks
   [P,D]=local_getRTickValue(HAxes,P,D);              % get rho tick values
   
   D.RDataN=cell(D.NumLines,1);
   for k=1:D.NumLines                              % Condition plotted data
      % wrap angles into first revolution
      D.TData{k}=mod(D.TData{k},2*pi);
      % normalize rho data for plotting
      D.RDataN(k)={(D.RData{k}-D.RMin)/D.RLimitDiff};
   end
   P.TLimit=[0 2*pi];                                    % plot full circle
   [P,D]=local_getTTickValue(P,D);                  % get theta tick values
   delete(D.HLines)         % clear cartesian lines, then create polar axes
   [P,D]=local_placeAxesPatch(HAxes,P,D);  % draw axes patch, border, ticks
   [P,D]=local_placeRGrid(HAxes,P,D);                       % Draw Rho Grid
   [P,D]=local_placeTGrid(HAxes,P,D);                     % Draw Theta Grid
   [P,D]=local_placeTTickLabel(HAxes,P,D);          % Add Theta Tick Labels
   [P,D]=local_placeRTickLabel(HAxes,P,D);           % Add Rho Tick Lablels

end

xylims=[-1 1]*1.08;
% Finalize Axes View                                     Finalize Axes View
set(HAxes,'DataAspectRatio',[1 1 1],....
          'XLimMode','manual','YLimMode','manual',...
          'XLim',xylims,'YLim',xylims,...
          'Visible','Off','Tag','MMPOLAR_Axes')
Hlabels=get(HAxes,{'Xlabel','YLabel', 'Title'});
set([Hlabels{:}],'Visible','on') % make labels visible

% Plot the Data                                               Plot the Data
D.HLines=zeros(D.NumLines,1);      % storage for lineseries handles
set([HFig,HAxes],'NextPlot','add') % hold on
for k=1:D.NumLines                 % plot the normalized data
   tdata=D.TData{k};
   rdata=D.RDataN{k};
   xdata=rdata.*cos(tdata);
   ydata=rdata.*sin(tdata);
   D.HLines(k)=plot(HAxes,xdata,ydata,...
                  'Color',D.LineColor{k},...
                  'LineStyle',D.LineStyle{k},...
                  'Marker',D.Marker{k});
end
if HoldIsON
   set([HFig,HAxes],'NextPlot','add') % hold on
else
   set([HFig,HAxes],'NextPlot','replace') % hold off
end

% Store Data                                                     Store Data
setappdata(HAxes,'MMPOLAR_Properties',P)
setappdata(HAxes,'MMPOLAR_Data',D)

if nargout % output handles if requested
   out=D.HLines;
end

% Update Plot with 'PName' PValue pairs if they exist
if exist('S','var')==1
   local_updatePlot(HAxes,S)
end
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% Local Functions                                           Local Functions
%--------------------------------------------------------------------------
function local_updatePlot(HAxes,S)              % local_updatePlot(HAxes,S)
% update MMPOLAR plot properties
% S contains known properties

P=getappdata(HAxes,'MMPOLAR_Properties');
D=getappdata(HAxes,'MMPOLAR_Data');
Sfn=fieldnames(S);

for kk=1:length(Sfn)
   switch Sfn{kk}
   case 'Axis'                                                       % Axis
      [istrue,onoff]=local_isonoff(S.Axis);
      if istrue
         set(D.HAPatch,'Visible',onoff)
         set(D.HRGrid,'Visible',onoff)
         set(D.HTGrid,'Visible',onoff)
         set(D.HRTick,'Visible',onoff)
         set(D.HTTick,'Visible',onoff)
         set(D.HRTickLabel,'Visible',onoff)
         set(D.HTTickLabel,'Visible',onoff)
         P.RGridVisible=onoff;
         P.TGridVisible=onoff;
         P.RTickLabelVisible=onoff;
         P.TTickLabelVisible=onoff;         
      else
         local_error('Unknown ''Axis'' Property Value.')
      end
   case 'BackgroundColor'                                 % BackgroundColor
      [istrue,cs]=local_iscolorspec(S.BackgroundColor);
      if istrue
         set(D.HAPatch,'FaceColor',cs)
         P.BackgroundColor=cs;
      else
         local_error('Unknown ''BackgroundColor'' Property Value.')
      end
   case 'Border'                                                   % Border
      [istrue,onoff]=local_isonoff(S.Border);
      if istrue && strcmp(onoff,'on')
         set(D.HAPatch,'EdgeColor',P.BorderColor)
         set(D.HTTick,'Visible','on')
         set(D.HRTick,'Visible','on')
         P.RTickVisible='on';
         P.TTickVisibel='on';
      elseif istrue && strcmp(onoff,'off')
         set(D.HAPatch,'EdgeColor','none')
         set(D.HTTick,'Visible','off')
         set(D.HRTick,'Visible','off')
         P.RTickVisible='off';
         P.TTickVisibel='off';
      else
         local_error('Unknown ''Border'' Property Value.')
      end
   case 'BorderColor'                                         % BorderColor
      [istrue,cs]=local_iscolorspec(S.BorderColor);
      if istrue
         P.BorderColor=cs;
         set(D.HAPatch,'EdgeColor',cs)
         set(D.HRTick,'Color',cs)
         set(D.HTTick,'Color',cs)
      else
         local_error('Unknown ''BorderColor'' Property Value.')
      end
   case 'FontName'                                               % FontName
      if ischar(S.FontName) && any(strcmpi(listfonts,S.FontName))
         set([D.HRTickLabel; D.HTTickLabel],'FontName',S.FontName)
         P.FontName=S.FontName;
      else
         local_error('Unknown ''FontName'' Property Value.')
      end
   case 'FontSize'                                               % FontSize
      if isnumeric(S.FontSize) && isscalar(S.FontSize)
         set([D.HRTickLabel; D.HTTickLabel],'FontSize',S.FontSize)
         P.FontSize=S.FontSize;
      else
         local_error('Unknown ''FontSize'' Property Value.')
      end
   case 'FontWeight'                                           % FontWeight
      if ischar(S.FontWeight) && ...
            (strncmpi(S.FontWeight,'normal',3)...
            ||strncmpi(S.FontWeight,'bold',3))
         set([D.HRTickLabel; D.HTTickLabel],'FontWeight',S.FontWeight)
         P.FontWeight=S.FontWeight;
      else
         local_error('Unknown ''FontWeight'' Property Value.')
      end      
   case 'Grid'                                                       % Grid
      [istrue,onoff]=local_isonoff(S.Grid);
      if istrue
         set(D.HRGrid,'Visible',onoff)
         set(D.HTGrid,'Visible',onoff)
         P.Grid=onoff;
         P.RGridVisible=onoff;
         P.TGridVisible=onoff;
      else
         local_error('Unknown ''Grid'' Property Value.')
      end
   case 'RGridColor'                                           % RGridColor
      [istrue,cs]=local_iscolorspec(S.RGridColor);
      if istrue
         set(D.HRGrid,'Color',cs)
         set(D.HRTickLabel,'Color',cs)
         P.RGridColor=cs;
      else
         local_error('Unknown ''RGridColor'' Property Value.')
      end
   case 'RGridLineStyle'                                   % RGridLineStyle
      if local_islinespec(S.RGridLineStyle)
         set(D.HRGrid,'LineStyle',S.RGridLineStyle)
         P.RGridLineStyle=S.RGridLineStyle;
      else
         local_error('Unknown ''RGridLineStyle'' Property Value.')
      end               
   case 'RGridLineWidth'                                   % RGridLineWidth
      if isnumeric(S.RGridLineWidth) && isscalar(S.RGridLineWidth)
         set(D.HRGrid,'LineWidth',S.RGridLineWidth)
         P.RGridLineWidth=S.RGridLineWidth;
      else
         local_error('Unknown ''RGridLineWidth'' Property Value.')
      end
   case 'RGridVisible'                                       % RGridVisible
      [istrue,onoff]=local_isonoff(S.RGridVisible);
      if istrue
         set(D.HRGrid,'Visible',onoff)
         P.RGridVisible=onoff;
      else
         local_error('Unknown ''RGridVisible'' Property Value.')
      end      
   case 'RLimit'                                                   % RLimit
      if isnumeric(S.RLimit) && numel(S.RLimit)==2
         S.RLimit=[min(S.RLimit) max(S.RLimit)];
         S.RLimit(isinf(S.RLimit))=P.RLimit(isinf(S.RLimit));
         [P,D]=local_getRTickValue(HAxes,P,D,S);
         [P,D]=local_placeRGrid(HAxes,P,D,S);
         [P,D]=local_placeRTickLabel(HAxes,P,D,S);
         % rescale rho data to new limits
         for k=1:length(D.RData)
            D.RDataN(k)={(D.RData{k}-D.RMin)/D.RLimitDiff};
            D.RDataN{k}(D.RDataN{k}>1)=NaN; % hide data outside limits
            D.RDataN{k}(D.RDataN{k}<0)=NaN;
            theta=D.TData{k};
            xdata=D.RDataN{k}.*cos(theta);
            ydata=D.RDataN{k}.*sin(theta);
            set(D.HLines(k),'XData',xdata,'YData',ydata)
         end
      else
         local_error('Unknown ''RLimit'' Property Value.')
      end               
   case 'RTickAngle'                                           % RTickAngle
      if isnumeric(S.RTickAngle) && isscalar(S.RTickAngle)
         rad=S.RTickAngle;
         if strcmp(P.TTickScale,'degrees')
            rad=S.RTickAngle*pi/180;
         end
         if P.TLimit(1)>P.TLimit(2) && (rad<P.TLimit(2) || rad>P.TLimit(1))
            P.RTickAngle=S.RTickAngle;
            D.RTickAngle=rad;
         elseif rad>P.TLimit(1) && rad<P.TLimit(2)
            P.RTickAngle=S.RTickAngle;
            D.RTickAngle=rad;            
         else
            local_error('RTickAngle not within Theta Axis Limits.')
         end
         for k=1:D.RTickLabelN % ignore innermost tick
            xdata=(P.RTickOffset+D.RTickRadius(k))*cos(D.RTickAngle);
            ydata=(P.RTickOffset+D.RTickRadius(k))*sin(D.RTickAngle);
            set(D.HRTickLabel(k),'Position',[xdata ydata])
         end
         phi=asin(P.TickLength./(2*D.RTickRadius));
         tdata=[D.RTickAngle-phi; D.RTickAngle+zeros(size(D.RTickRadius))
                D.RTickAngle+phi; NaN(size(D.RTickRadius))];
         rdata=[D.RTickRadius; D.RTickRadius
                D.RTickRadius; NaN(size(D.RTickRadius))];
         xdata=rdata(:).*cos(tdata(:));
         ydata=rdata(:).*sin(tdata(:));
         set(D.HRTick,'XData',xdata,'YData',ydata) % move rho ticks
      else
         local_error('Unknown ''RTickAngle'' Property Value.')
      end
   case 'RTickLabel'                                           % RTickLabel
      if iscellstr(S.RTickLabel)
         NumS=length(S.RTickLabel);
         for k=1:D.RTickLabelN
            str=S.RTickLabel{rem(k-1,NumS)+1};
            set(D.HRTickLabel(k),'String',str)
         end         
         P.RTickLabel=S.RTickLabel;
      else
         local_error('Unknown ''RTickLabel'' Property Value.')
      end
   case 'RTickLabelHalign'                               % RTickLabelHalign
      fnames={'left' 'center' 'right'};
      out=local_isfield(fnames,S.RTickLabelHalign);
      if ~isempty(out)
         P.RTickLabelHalign=out;
         set(D.HRTickLabel,'HorizontalAlignment',out)
      else
         local_error('Unknown ''RTickLabelHalign'' Property Value.')
      end         
   case 'RTickLabelValign'                               % RTickLabelValign
      fnames={'top' 'cap' 'middle' 'baseline' 'bottom'};
      out=local_isfield(fnames,S.RTickLabelValign);
      if ~isempty(out)
         P.RTickLabelValign=out;
         set(D.HRTickLabel,'VerticalAlignment',out)
      else
         local_error('Unknown ''RTickLabelValign'' Property Value.')
      end
   case 'RTickLabelVisible'                             % RTickLabelVisible
      [istrue,onoff]=local_isonoff(S.RTickLabelVisible);
      if istrue
         set(D.HRTickLabel,'Visible',onoff)
         P.RTickLabelVisible=onoff;
      else
         local_error('Unknown ''RTickLabelVisible'' Property Value.')
      end
   case 'RTickOffset'                                         % RTickOffset
      if isnumeric(S.RTickOffset) && isscalar(S.RTickOffset)
         P.RTickOffset=S.RTickOffset;
         for k=1:D.RTickLabelN
            xdata=(P.RTickOffset+D.RTickRadius(k))*cos(D.RTickAngle);
            ydata=(P.RTickOffset+D.RTickRadius(k))*sin(D.RTickAngle);
            set(D.HRTickLabel(k),'Position',[xdata ydata])
         end
      else
          local_error('Unknown ''RTickOffset'' Property Value.')
      end
   case 'RTickUnits'                                           % RTickUnits
      if ischar(S.RTickUnits)
         tmp=char(get(D.HRTickLabel(end),'String'));
         if ~isempty(P.RTickUnits)
            idx=strfind(tmp,P.RTickUnits);
            tmp=[tmp(1:idx(end)-1) S.RTickUnits];
         else
            tmp=[tmp S.RTickUnits]; %#ok
         end
         set(D.HRTickLabel(end),'String',tmp)
         P.RTickUnits=S.RTickUnits;
      else
         local_error('Unknown ''RTickUnits'' Property Value.')
      end
   case 'RTickValue'                                           % RTickValue
      if isnumeric(S.RTickValue) && numel(S.RTickValue)>0
         S.RTickValue=S.RTickValue(S.RTickValue>=P.RLimit(1)...
            & S.RTickValue<=P.RLimit(2));
         if length(S.RTickValue)>1
            P.RTickValue=S.RTickValue;
            D.RTickLabelN=length(P.RTickValue);
            D.RTickRadius=(P.RTickValue-D.RMin)/D.RLimitDiff;
            [P,D]=local_placeRGrid(HAxes,P,D,S);
            [P,D]=local_placeRTickLabel(HAxes,P,D,S);
         end
      else
         local_error('Unknown ''RTickValue'' Property Value.')
      end
   case 'RTickVisible'                                       % RTickVisible
      [istrue,onoff]=local_isonoff(S.RTickVisible);
      if istrue
         set(D.HRTick,'Visible',onoff)
         P.RTickVisible=onoff;
      else
         local_error('Unknown ''RTickVisible'' Property Value.')
      end
   case 'Style'                                                     % Style
      if strncmpi(S.Style,'cartesian',3)   % Cartesian style
         set(HAxes,'View',[0 90])
         P.TDirection='ccw';
         P.TZeroDirection='east';
         P.Style='cartesian';
      elseif strncmpi(S.Style,'compass',3) % Compass style
         set(HAxes,'View',[90 -90])
         P.TDirection='cw';
         P.TZeroDirection='north';
         P.Style='compass';
      else
         local_error('Unknown ''Style'' Property Value.')
      end
   case 'TDirection'                                           % TDirection
      if ischar(S.TDirection) && strcmpi(S.TDirection,'cw')
         P.TDirection='cw';
         if strcmp(P.TZeroDirection,'north')
            set(HAxes,'View',[90 -90])
         elseif strcmp(P.TZeroDirection,'east')
            set(HAxes,'View',[0 -90])
         elseif strcmp(P.TZeroDirection,'south')
            set(HAxes,'View',[270 -90])
         elseif strcmp(P.TZeroDirection,'west')
            set(HAxes,'View',[180 -90])
         end
      elseif ischar(S.TDirection) && strcmpi(S.TDirection,'ccw')
         P.TDirection='ccw';
         if strcmp(P.TZeroDirection,'north')
            set(HAxes,'View',[270 90])
         elseif strcmp(P.TZeroDirection,'east')
            set(HAxes,'View',[0 90])
         elseif strcmp(P.TZeroDirection,'south')
            set(HAxes,'View',[90 90])
         elseif strcmp(P.TZeroDirection,'west')
            set(HAxes,'View',[180 90])
         end
      else
         local_error('Unknown ''TDirection'' Property Value.')
      end
      P.Style='unknown';
   case 'TGridColor'                                           % TGridColor
      [istrue,cs]=local_iscolorspec(S.TGridColor);
      if istrue
         set(D.HTGrid,'Color',cs)
         set(D.HTTickLabel,'Color',cs)
         P.TGridColor=cs;
      else
         local_error('Unknown ''TGridColor'' Property Value.')
      end
   case 'TGridLineStyle'                                   % TGridLineStyle
      if local_islinespec(S.TGridLineStyle)
         set(D.HTGrid,'LineStyle',S.TGridLineStyle)
         P.TGridLineStyle=S.TGridLineStyle;
      else
         local_error('Unknown ''TGridLineStyle'' Property Value.')
      end
   case 'TGridLineWidth'                                   % TGridLineWidth
      if isnumeric(S.TGridLineWidth) && isscalar(S.TGridLineWidth)
         set(D.HTGrid,'LineWidth',S.TGridLineWidth)
         P.TGridLineWidth=S.TGridLineWidth;
      else
         local_error('Unknown ''TGridLineWidth'' Property Value.')
      end
   case 'TGridVisible'                                       % TGridVisible
      [istrue,onoff]=local_isonoff(S.TGridVisible);
      if istrue
         set(D.HTGrid,'Visible',onoff)
         P.TGridVisible=onoff;
      else
         local_error('Unknown ''TGridVisible'' Property Value.')
      end      
   case 'TickLength'                                           % TickLength
      if isnumeric(S.TickLength) && isscalar(S.TickLength)
         P.TickLength=max(min(abs(S.TickLength),0.1),.001);
         tdir=2*strcmp(P.TTickDirection,'in')-1;
         tdata=[D.TTickValue;D.TTickValue;NaN(1,D.TTickLabelN)];
         rdata=[ones(1,D.TTickLabelN)
                (1-tdir*P.TickLength)+zeros(1,D.TTickLabelN)
                NaN(1,D.TTickLabelN)];
         xdata=rdata(:).*cos(tdata(:));
         ydata=rdata(:).*sin(tdata(:));
         set(D.HTTick,'XData',xdata,'YData',ydata) % theta ticks
         phi=asin(P.TickLength./(2*D.RTickRadius));
         tdata=[D.RTickAngle-phi; D.RTickAngle+zeros(size(D.RTickRadius))
                D.RTickAngle+phi; NaN(size(D.RTickRadius))];
         rdata=[D.RTickRadius; D.RTickRadius
                D.RTickRadius; NaN(size(D.RTickRadius))];
         xdata=rdata(:).*cos(tdata(:));
         ydata=rdata(:).*sin(tdata(:));
         set(D.HRTick,'XData',xdata,'YData',ydata) % rho ticks
      else
         local_error('Unknown ''TickLength'' Property Value.')
      end
   case 'TLimit'                                                   % TLimit
      if isnumeric(S.TLimit) && numel(S.TLimit)==2
         if abs(diff(S.TLimit))>1.9*pi   % make full circle if close
            P.TLimit=[0 2*pi];
         else
            P.TLimit=mod(S.TLimit,2*pi); % move limits to range 0 to 2pi
         end
         [P,D]=local_getTTickValue(P,D,S);
         [P,D]=local_placeAxesPatch(HAxes,P,D,S);
         [P,D]=local_placeRGrid(HAxes,P,D,S);
         [P,D]=local_placeTGrid(HAxes,P,D,S);
         [P,D]=local_placeTTickLabel(HAxes,P,D,S);
         [P,D]=local_placeRTickLabel(HAxes,P,D,S);
         for k=1:length(D.TData) % hide data outside TLimits
            tdata=D.TData{k};
            if P.TLimit(1)>P.TLimit(2)
               tdata(tdata<P.TLimit(1) & tdata>P.TLimit(2))=NaN;
            else            
               tdata(tdata<P.TLimit(1) | tdata>P.TLimit(2))=NaN;
            end
            xdata=D.RDataN{k}.*cos(tdata);
            ydata=D.RDataN{k}.*sin(tdata);
            set(D.HLines(k),'XData',xdata,'YData',ydata)
         end
      else
         local_error('Unknown ''TLimit'' Property Value.')
      end
   case 'TTickDelta'                                           % TTickDelta
      if isnumeric(S.TTickDelta) && isscalar(S.TTickDelta)
         if strcmp(P.TTickScale,'degrees')
            P.TTickDelta=min(max(abs(S.TTickDelta),5),90);
         else
            P.TTickDelta=min(max(abs(S.TTickDelta),pi/36),pi/2);
         end
         [P,D]=local_getTTickValue(P,D,S);
         [P,D]=local_placeTGrid(HAxes,P,D,S);
         [P,D]=local_placeTTickLabel(HAxes,P,D,S);
      else
         local_error('Unknown ''TTickDelta'' Property Value.')
      end
   case 'TTickDirection'                                   % TTickDirection
      if ischar(S.TTickDirection) &&...
        (strcmpi(S.TTickDirection,'out') || strcmpi(S.TTickDirection,'in'))
         P.TTickDirection=S.TTickDirection;
         tdir=2*strcmp(P.TTickDirection,'in')-1;
         tdata=[D.TTickValue;D.TTickValue;NaN(1,D.TTickLabelN)];
         rdata=[ones(1,D.TTickLabelN)
                (1-tdir*P.TickLength)+zeros(1,D.TTickLabelN)
                NaN(1,D.TTickLabelN)];
         xdata=rdata(:).*cos(tdata(:));
         ydata=rdata(:).*sin(tdata(:));
         set(D.HTTick,'XData',xdata,'YData',ydata) % theta ticks
      else
         local_error('Unknown ''TTickDirection'' Property Value.')
      end
   case 'TTickLabel'                                           % TTickLabel
      if iscellstr(S.TTickLabel)
         NumS=length(S.TTickLabel);
         for k=1:D.TTickLabelN
            str=S.TTickLabel{rem(k-1,NumS)+1};
            set(D.HTTickLabel(k),'String',str)
         end         
         P.TTickLabel=S.TTickLabel;
      else
         local_error('Unknown ''TTickLabel'' Property Value.')
      end
   case 'TTickLabelVisible'                             % TTickLabelVisible
      [istrue,onoff]=local_isonoff(S.TTickLabelVisible);
      if istrue
         set(D.HTTickLabel,'Visible',onoff)
         P.TTickLabelVisible=onoff;
      else
         local_error('Unknown ''TTickLabelVisible'' Property Value.')
      end
   case 'TTickOffset'                                         % TTickOffset
      if isnumeric(S.TTickOffset) && isscalar(S.TTickOffset)
         P.TTickOffset=S.TTickOffset;
         for k=1:D.TTickLabelN
            xdata=(1+P.TTickOffset)*cos(D.TTickValue(k));
            ydata=(1+P.TTickOffset)*sin(D.TTickValue(k));
            set(D.HTTickLabel(k),'Position',[xdata ydata])
         end
      else
         local_error('Unknown ''TTickOffset'' Property Value.')
      end
   case 'TTickScale'                                           % TTickScale
      if ischar(S.TTickScale) && strncmpi(S.TTickScale,'degrees',3)...
                              && strcmp(P.TTickScale,'radians')
         P.TTickScale='degrees';
         P.TTickDelta=P.TTickDelta*180/pi;
         P.RTickAngle=P.RTickAngle*180/pi;
         [P,D]=local_getTTickValue(P,D,S);
         [P,D]=local_placeTTickLabel(HAxes,P,D,S);
      elseif ischar(S.TTickScale) && strncmpi(S.TTickScale,'radians',3)...
                                  && strcmp(P.TTickScale,'degrees')
         P.TTickScale='radians';
         P.TTickDelta=P.TTickDelta*pi/180;
         P.RTickAngle=P.RTickAngle*pi/180;
         [P,D]=local_getTTickValue(P,D,S);
         [P,D]=local_placeTTickLabel(HAxes,P,D,S);
      elseif ~ischar(S.TTickScale)
         local_error('Unknown ''TTickScale'' Property Value.')
      end
   case 'TTickSign'                                             % TTickSign
      if ischar(S.TTickSign)
         if strcmp(S.TTickSign,'+')
            P.TTickSign='+';
         else
            P.TTickSign='+-';
         end
         [P,D]=local_getTTickValue(P,D,S);
         [P,D]=local_placeTTickLabel(HAxes,P,D,S);
      else
         local_error('Unknown ''TTickSign'' Property Value.')
      end
   case 'TTickValue'                                           % TTickValue
      if isnumeric(S.TTickValue) && numel(S.TTickValue)>0
         TTick=S.TTickValue(:)';
         if strcmp(P.TTickScale,'degrees')
            TTick=TTick*pi/180;
         end
         if P.TLimit(1)>P.TLimit(2)
            idx=TTick<=P.TLimit(2) | TTick>=P.TLimit(1); % keepers
         else
            idx=TTick>=P.TLimit(1) & TTick<=P.TLimit(2); % keepers
         end
         S.TTickValue=S.TTickValue(idx);
         if length(S.TTickValue)>1
            P.TTickValue=S.TTickValue(:)';
            D.TTickValue=TTick(idx);
            D.TTickLabelN=length(P.TTickValue);
            [P,D]=local_placeTGrid(HAxes,P,D,S);
            [P,D]=local_placeTTickLabel(HAxes,P,D,S);
         end
      else
         local_error('Unknown ''TTickValue'' Property Value.')
      end
   case 'TTickVisible'                                       % TTickVisible
      [istrue,onoff]=local_isonoff(S.TTickVisible);
      if istrue
         set(D.HTTick,'Visible',onoff)
         P.TTickVisible=onoff;
      else
         local_error('Unknown ''RTickVisible'' Property Value.')
      end
   case 'TZeroDirection'                                   % TZeroDirection
      if ischar(S.TZeroDirection) && strncmpi(S.TZeroDirection,'north',1)
         P.TZeroDirection='north';
         if strcmp(P.TDirection,'ccw')
            set(HAxes,'View',[270 90])
         elseif strcmp(P.TDirection,'cw')
            set(HAxes,'View',[90 -90])
         end
      elseif ischar(S.TZeroDirection) && strncmpi(S.TZeroDirection,'east',1)
         P.TZeroDirection='east';
         if strcmp(P.TDirection,'ccw')
            set(HAxes,'View',[0 90])
         elseif strcmp(P.TDirection,'cw')
            set(HAxes,'View',[0 -90])
         end
      elseif ischar(S.TZeroDirection) && strncmpi(S.TZeroDirection,'south',1)
         P.TZeroDirection='south';
         if strcmp(P.TDirection,'ccw')
            set(HAxes,'View',[90 90])
         elseif strcmp(P.TDirection,'cw')
            set(HAxes,'View',[270 -90])
         end
      elseif ischar(S.TZeroDirection) && strncmpi(S.TZeroDirection,'west',1)
         P.TZeroDirection='west';
         if strcmp(P.TDirection,'ccw')
            set(HAxes,'View',[180 90])
         elseif strcmp(P.TDirection,'cw')
            set(HAxes,'View',[180 -90])
         end
      else
         local_error('Unknown ''TZeroDirection'' Property Value.')
      end
      P.Style='unknown';
   end
end
setappdata(HAxes,'MMPOLAR_Properties',P)
setappdata(HAxes,'MMPOLAR_Data',D)
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
function [out,errmsg]=local_isfield(fnames,str)             % local_isfield
% compare str to fnames, if found, return complete fieldname
% otherwise return error and empty string.
% fnames is cell array, str is a string
% outputs are strings

% look for exact match first
idx=find(strcmpi(fnames,str));

if isempty(idx) % no exact match, so look for more general match
   idx=find(strncmpi(str,fnames,max(length(str),2)));
end
if numel(idx)==1 % unique match found
   out=fnames{idx};
   errmsg='';
else             % trouble
   out='';
   errmsg=sprintf('Unknown or Not Unique Property: %s',str);
end
%--------------------------------------------------------------------------
function [istrue,cs]=local_iscolorspec(arg)             % local_iscolorspec
% see if arg is a valid color specification including 'none'
rgb={[1 0 0],[0 1 0],[0 0 1],[0 1 1],[1 0 1],[1 1 0],[0 0 0],[1 1 1],'none'};
cc='rgbcmykwn';
istrue=false;
cs=[];
if ~isempty(arg) && ischar(arg)
   idx=find(arg(1)==cc);
   if ~isempty(idx)
      istrue=true;
      cs=rgb{idx};
   end 
elseif ~isempty(arg) && isnumeric(arg)
   istrue=all(size(arg)==[1 3])...
      && all(arg>=0) && all(arg<=1);
   cs=arg;
else
   istrue=false;
end
%--------------------------------------------------------------------------
function istrue=local_islinespec(arg)                    % local_islinespec
% see if arg is a valid line style specification
str={'-','-.','--',':'};
if isempty(arg)
   istrue=false;
elseif ischar(arg) && length(arg)<3
   istrue=any(strncmp(str,arg,length(arg)));
else
   istrue=false;
end
%--------------------------------------------------------------------------
function [istrue,s]=local_isonoff(arg)                      % local_isonoff
% see if arg is either on or off
istrue=false;
s='';
if ~isempty(arg) && ischar(arg) && strcmpi(arg,'on')
   istrue=true;
   s='on';
elseif ~isempty(arg) && ischar(arg) && strcmpi(arg,'off')
   istrue=true;
   s='off';
end
%--------------------------------------------------------------------------
function local_error(arg)  
% Add message identifier to error message and post error
if ~isempty(arg) && ischar(arg)
   error('MMPOLAR:error',arg)
end
%--------------------------------------------------------------------------
function [P,D]=local_placeAxesPatch(HAxes,P,D,S)  %#ok local_placeAxesPatch
% Draw Axes Border and Patch
tinc=pi/250;
if P.TLimit(1)>P.TLimit(2)
   theta=[P.TLimit(1):tinc:(P.TLimit(2)+2*pi-eps) P.TLimit(2)+2*pi];
else
   theta=[P.TLimit(1):tinc:P.TLimit(2)-eps P.TLimit(2)];
end   
costheta=cos(theta);
sintheta=sin(theta);
if abs(diff(P.TLimit))<2*(1-eps)*pi; % less than 4 quadrant box
   xdata=[0 costheta 0];
   ydata=[0 sintheta 0];
else % four quadrant box
   xdata=costheta;
   ydata=sintheta;
end
% let the axes grow for less than 4 quadrant box
set(HAxes,'Xlim',[min(xdata) max(xdata)],'Ylim',[min(ydata) max(ydata)])
if nargin==3 % new plot
   D.HAPatch=patch('XData',xdata,'YData',ydata,...
      'Parent',HAxes,...
      'LineStyle','-',...
      'Linewidth',2*P.RGridLineWidth,...
      'EdgeColor',P.BorderColor,...
      'FaceColor',P.BackgroundColor,...
      'HandleVisibility','off',...
      'HitTest','off');
else % old plot, update data
   set(D.HAPatch,'XData',xdata,'YData',ydata)
end
%--------------------------------------------------------------------------
function [P,D]=local_placeRGrid(HAxes,P,D,S)          %#ok local_placeRGrid
tinc=pi/250;
if P.TLimit(1)>P.TLimit(2)
   theta=[P.TLimit(1):tinc:(P.TLimit(2)+2*pi-eps) P.TLimit(2)+2*pi];
else
   theta=[P.TLimit(1):tinc:P.TLimit(2)-eps P.TLimit(2)];
end   
costheta=cos(theta);
sintheta=sin(theta);
xdata=[];
ydata=[];
% no outer grid if outer tick is at outer RLimit
D.RGridN=length(P.RTickValue(P.RTickValue<P.RLimit(2)));
for k=1:D.RGridN
   xdata=[xdata D.RTickRadius(k)*costheta NaN];  %#ok
   ydata=[ydata D.RTickRadius(k)*sintheta NaN];  %#ok
end
if nargin<4 % new grid
   D.HRGrid=line(xdata,ydata,...
      'Parent',HAxes,...
      'LineStyle',P.RGridLineStyle,...
      'LineWidth',P.RGridLineWidth,...
      'Color',P.RGridColor,...
      'HandleVisibility','off',...
      'HitTest','off');
else
   set(D.HRGrid,'Xdata',xdata,'YData',ydata)
end
% Draw Rho Axis Tick Marks
phi=asin(P.TickLength./(2*D.RTickRadius));
tdata=[D.RTickAngle-phi; D.RTickAngle+zeros(size(D.RTickRadius))
       D.RTickAngle+phi; NaN(size(D.RTickRadius))];
rdata=[D.RTickRadius; D.RTickRadius
       D.RTickRadius; NaN(size(D.RTickRadius))];
xdata=rdata(:).*cos(tdata(:));
ydata=rdata(:).*sin(tdata(:));
if nargin==3 % new plot
   D.HRTick=line(xdata,ydata,...
      'Parent',HAxes,...
      'LineStyle','-',...
      'LineWidth',2*P.RGridLineWidth,...
      'Color',P.BorderColor,...
      'HandleVisibility','off',...
      'HitTest','off');
else % old plot, update data
   set(D.HRTick,'XData',xdata,'YData',ydata)
end
%--------------------------------------------------------------------------
function [P,D]=local_placeRTickLabel(HAxes,P,D,S)%#ok local_placeRTickLabel
% Draw Rho Tick Labels
D.RScale=floor(log10(max(abs(P.RTickValue))));
if abs(D.RScale)<2
   D.RScale=0;
end
P.RTickLabel=cell(D.RTickLabelN,1);
if nargin==4 % delete old labels and create new ones
   delete(D.HRTickLabel)
end
D.HRTickLabel=zeros(D.RTickLabelN,1);
for k=1:D.RTickLabelN
   xdata=(P.RTickOffset+D.RTickRadius(k))*cos(D.RTickAngle);
   ydata=(P.RTickOffset+D.RTickRadius(k))*sin(D.RTickAngle);
   P.RTickLabel{k}=num2str(P.RTickValue(k)*10^(-D.RScale));
   if (k==D.RTickLabelN) && (D.RScale~=0)
      P.RTickLabel{k}=[P.RTickLabel{k} sprintf('\\times10^{%d}',D.RScale)];
   end
   D.HRTickLabel(k)=text(xdata,ydata,P.RTickLabel{k},...
      'Parent',HAxes,...
      'Color',P.TGridColor,...
      'FontName',P.FontName,...
      'FontSize',P.FontSize,...
      'FontWeight',P.FontWeight',...
      'HorizontalAlignment',P.RTickLabelHalign,...
      'VerticalAlignment',P.RTickLabelValign,...
      'Clipping','off',...
      'HandleVisibility','off',...
      'HitTest','off');
end
%--------------------------------------------------------------------------
function [P,D]=local_getRTickValue(HAxes,P,D,S)       % local_getRTickValue
% get RTicks
if nargin==4 % updating current ticks given new rho axis limits
   tmpaxes=axes('Position',get(HAxes,'Position'));
   line([0 1],S.RLimit,'Parent',tmpaxes);
   P.RTickValue=get(tmpaxes,'YTick');
   P.RLimit=S.RLimit;
   delete(tmpaxes) % got ticks, don't need axes anymore
end
%P.RTickValue(end)=P.RLimit(2); % place last tick at outer rho limit
NumRTick=length(P.RTickValue); % reduce ticks if too many
if NumRTick>6
   if rem(NumRTick,2)~=0  % odd number keep alternate ones
      P.RTickValue=P.RTickValue(1:2:end);
   else % even number, add one tick, then keep alternate ones
      if P.RTickValue(1)==0	% keep lowest tick if zero, add one at outside
         P.RTickValue=[P.RTickValue(1:2:end-1) ...
                        2*P.RTickValue(end)-P.RTickValue(end-1)];
         P.RTickValue(P.RTickValue>P.RLimit(2))=[]; % no label past limit
      else                    % add one tick at inside
         P.RTickValue=[2*P.RTickValue(1)-P.RTickValue(2)...
                        P.RTickValue(2:2:end)];
      end
      P.RLimit(1)=P.RTickValue(1); % make first tick lower axis limit
   end
end
if NumRTick<3
   m=sum(P.RTickValue)/2;
   P.RTickValue(3)=P.RTickValue(2);
   P.RTickValue(2)=m;
end
D.RLimitDiff=diff(P.RLimit);
D.RMin=P.RLimit(1);
if abs(P.RTickValue(1)-P.RLimit(1)) < abs(D.RLimitDiff)/100
   P.RTickValue(1)=[]; % throw out inner tick if at inner axis limit
end
D.RTickRadius=(P.RTickValue-D.RMin)/D.RLimitDiff;
D.RTickLabelN=length(P.RTickValue);
%--------------------------------------------------------------------------
function [P,D]=local_placeTGrid(HAxes,P,D,S)          %#ok local_placeTGrid
xdata=[];
ydata=[];
costheta=cos(D.TTickValue);
sintheta=sin(D.TTickValue);
% no grid on first or last ticks are axis limits if less than 4 quadrants
ki=1;
ke=length(D.TTickValue);
if abs(diff(P.TLimit))<2*(1-eps)*pi; % less than 4 quadrant box
   ki=1+(D.TTickValue(1)==P.TLimit(1));
   ke=length(D.TTickValue)-(D.TTickValue(end)==P.TLimit(2));
end
D.TGridN=ke-ki+1;
for k=ki:ke
   xdata=[xdata 0 costheta(k) NaN];  %#ok
   ydata=[ydata 0 sintheta(k) NaN];  %#ok
end
if nargin<4 % new grid
   D.HTGrid=line(xdata,ydata,...
      'Parent',HAxes,...
      'LineStyle',P.TGridLineStyle,...
      'LineWidth',P.TGridLineWidth,...
      'Color',P.TGridColor,...
      'HandleVisibility','off',...
      'HitTest','off');
else
   set(D.HTGrid,'Xdata',xdata,'YData',ydata)
end
% Draw Theta Axis Tick Marks
tdir=2*strcmp(P.TTickDirection,'in')-1;
tdata=[D.TTickValue; D.TTickValue; NaN(1,D.TTickLabelN)];
rdata=[ones(1,D.TTickLabelN)
       (1-tdir*P.TickLength)+zeros(1,D.TTickLabelN)
       NaN(1,D.TTickLabelN)];
xdata=rdata(:).*cos(tdata(:));
ydata=rdata(:).*sin(tdata(:));
if nargin==3 % new plot
   D.HTTick=line(xdata,ydata,...
      'Parent',HAxes,...
      'LineStyle','-',...
      'LineWidth',2*P.RGridLineWidth,...
      'Color',P.BorderColor,...
      'Clipping','off',...
      'HandleVisibility','off',...
      'HitTest','off');
else % old plot, update data
   set(D.HTTick,'XData',xdata,'YData',ydata)
end
%--------------------------------------------------------------------------
function [P,D]=local_placeTTickLabel(HAxes,P,D,S)%#ok local_placeTTickLabel
% Draw Theta Ticks
if nargin==4 % delete old labels and create new ones
   delete(D.HTTickLabel)
end
P.TTickLabel=cell(D.TTickLabelN,1);
D.HTTickLabel=zeros(D.TTickLabelN,1);
for k=1:D.TTickLabelN % label ticks at theta axis limits
   xdata=(1+P.TTickOffset)*cos(D.TTickValue(k));
   ydata=(1+P.TTickOffset)*sin(D.TTickValue(k));
   if strcmp(P.TTickScale,'radians')
      [n,d]=rat(P.TTickValue(k)/pi); % ticks as fractions
      if n==0
         Tstr='0';
      elseif n==1 && d==1
         Tstr='\pi';
      elseif n==-1 && d==1
         Tstr='-\pi';
      elseif n==1
         Tstr=['\pi/' num2str(d)];
      elseif n==-1
         Tstr=['-\pi/' num2str(d)];
      elseif d==1
         Tstr=[num2str(n) '\pi'];
      else
         Tstr=[num2str(n) '\pi/' num2str(d)];
      end
      P.TTickLabel{k}=Tstr;
   else % degrees
      P.TTickLabel{k}=[num2str(P.TTickValue(k)) '\circ'];
      if P.TTickValue(k)==-180
         P.TTickLabel{k}=['\pm' P.TTickLabel{k}(2:end)];
      end
   end
   D.HTTickLabel(k)=text(xdata,ydata,P.TTickLabel{k},...
      'Parent',HAxes,...
      'Color',P.TGridColor,...
      'FontName',P.FontName,...
      'FontSize',P.FontSize,...
      'FontWeight',P.FontWeight',...
      'HorizontalAlignment','center',...
      'VerticalAlignment','middle',...
      'Clipping','off',...
      'HandleVisibility','off',...
      'HitTest','off');
end
%--------------------------------------------------------------------------
function [P,D]=local_getTTickValue(P,D,S)          %#ok local_getTTickValue
% Get Theta Ticks
if strcmp(P.TTickScale,'degrees') % ticks are in degrees
   TTick=0:P.TTickDelta:360; % possible ticks
   if P.TLimit(1)>P.TLimit(2)
      idx=TTick<=P.TLimit(2)*180/pi | TTick>=P.TLimit(1)*180/pi; % keepers
   else
      idx=TTick>=P.TLimit(1)*180/pi & TTick<=P.TLimit(2)*180/pi; % keepers
   end
   P.TTickValue=TTick(idx);
   P.TTickValue=unique(rem(P.TTickValue,360)); % get unique ticks
   D.TTickValue=P.TTickValue*pi/180; % store ticks in radians
   if strcmp(P.TTickSign,'+-')
      tmp=P.TTickValue>=180;
      P.TTickValue(tmp)=P.TTickValue(tmp)-360;
   end
else                          % ticks are in radians
   TTick=(0:P.TTickDelta*180/pi:360)*pi/180; % possible ticks
   if P.TLimit(1)>P.TLimit(2)
      idx=TTick<=P.TLimit(2) | TTick>=P.TLimit(1); % keepers
   else
      idx=TTick>=P.TLimit(1) & TTick<=P.TLimit(2); % keepers
   end
   P.TTickValue=TTick(idx);
   P.TTickValue=unique(rem(P.TTickValue,2*pi)); % get unique ticks
   D.TTickValue=P.TTickValue; % store ticks in radians for plotting
   if strcmp(P.TTickSign,'+-')
      tmp=P.TTickValue>=pi;
      P.TTickValue(tmp)=P.TTickValue(tmp)-2*pi;
   end
end
D.TTickLabelN=length(D.TTickValue);
kmid=max(1,floor(length(P.TTickValue)/2));
P.RTickAngle=(D.TTickValue(kmid)+D.TTickValue(kmid+1))/2;
D.RTickAngle=P.RTickAngle;
if strcmp(P.TTickScale,'degrees')
   P.RTickAngle=P.RTickAngle*180/pi;
end
%--------------------------------------------------------------------------
function out=local_getDefaults                          % local_getDefaults
out.Style='cartesian';
out.Axis='on';
out.Border='on';
out.Grid='on';
out.RLimit=[0 1];
out.TLimit=[0 2*pi];
out.RTickUnits='';
out.TTickScale='degrees';
out.TDirection='ccw';
out.TZeroDirection='east';

out.BackgroundColor=get(0,'defaultaxescolor');
out.BorderColor=[0 0 0];
out.FontName=get(0,'defaultaxesfontname');
out.FontSize=get(0,'defaultaxesfontsize');
out.FontWeight=get(0,'defaultaxesfontweight');
out.TickLength=0.02;

out.RGridColor=get(0,'defaultaxesycolor');
out.RGridLineStyle=get(0,'defaultaxesgridlinestyle');
out.RGridLineWidth=get(0,'defaultaxeslinewidth');
out.RGridVisible='on';
out.RTickAngle=0;
out.RTickOffset=0.04;
out.RTickLabel='0|0.5|1.0';
out.RTickLabelHalign='center';
out.RTickLabelValign='middle';
out.RTickLabelVisible='on';
out.RTickValue=[0 .5 1];
out.RTickVisible='on';

out.TGridColor=get(0,'defaultaxesxcolor');
out.TGridVisible='on';
out.TGridLineStyle=get(0,'defaultaxesgridlinestyle');
out.TGridLineWidth=get(0,'defaultaxeslinewidth');
out.TTickOffset=0.08;
out.TTickDelta=15;
out.TTickDirection='in';
out.TTickLabel='';
out.TTickLabelVisible='on';
out.TTickSign='+-';
out.TTickValue=0:15:359;
out.TTickVisible='on';
%--------------------------------------------------------------------------
% Description of Plot Data Stored           Description of Plot Data Stored
%--------------------------------------------------------------------------
%
% VARIABLE        TYPE        DESCRIPTION
% D.TData         Cell        Raw input theta data
% D.RData         Cell        Raw input rho data
% D.RDataN        Cell        Normalized rho data
% D.LineColor     Cell        Line colors of plotted data
% D.LineStyle     Cell        Line styles of plotted data
% D.Marker        Cell        Markers of plotted data
% D.RLimitDiff    Double      Rho axis limit difference
% D.RMin          Double      Rho axis minimum
% D.RScale        Double      Power of ten scaling rho axis ticks
% D.RTickAngle    Double      Angle of rho tick labels in radians
% D.RTickRadius   Double      Radial position of rho tick labels
% D.RGridN        Double      Number of rho axis grid lines
% D.RTickLabelN   Double      Number of rho axis tick labels
% D.TGridN        Double      Number of theta axis grid lines      
% D.TTickLabelN   Double      Number of theta axis tick labels
% D.TTickValue    Double      Theta tick values in RADIANS
%--------------------------------------------------------------------------
% Description of Stored Handles               Description of Stored Handles
%--------------------------------------------------------------------------
%
% HANDLE          TYPE        DESCRIPTION
% D.HAPatch       Patch       Axis background and border
% D.HTTick        Line        Theta tick marks
% D.HRTick        Line        Rho tick marks
% D.HRGrid        Line        Rho grid
% D.HTTickLabel   Text        Theta Tick Labels
% D.HRTIckLabel   Text        Rho Tick Labels
% D.HLines        Line        Plotted Data
%
%--------------------------------------------------------------------------