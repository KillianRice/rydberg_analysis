% Generate some test data.  Assume that the X-axis represents months.
x = 1:12;
y = 10*rand(1,length(x));
% Plot the data.
h = plot(x,y,'+');
% Reduce the size of the axis so that all the labels fit in the figure.
pos = get(gca,'Position');
set(gca,'Position',[pos(1), .2, pos(3) .65])
% Add a title.
title('This is a title')
% Set the X-Tick locations so that every other month is labeled.
Xt = 1:2:11;
Xl = [1 12];
set(gca,'XTick',Xt,'XLim',Xl);
% Add the months as tick labels.
months = ['Jan';
          'Feb';
          'Mar';
          'Apr';
          'May';
          'Jun';
          'Jul';
          'Aug';
          'Sep';
          'Oct';
          'Nov';
          'Dec'];
ax = axis;    % Current axis limits
axis(axis);    % Set the axis limit modes (e.g. XLimMode) to manual
Yl = ax(3:4);  % Y-axis limits
% Place the text labels
t = text(Xt,Yl(1)*ones(1,length(Xt)),months(1:2:12,:));
set(t,'HorizontalAlignment','right','VerticalAlignment','top', ...
      'Rotation',45);
% Remove the default labels
set(gca,'XTickLabel','')
% Get the Extent of each text object.  This
% loop is unavoidable.
for i = 1:length(t)
  ext(i,:) = get(t(i),'Extent');
end
% Determine the lowest point.  The X-label will be
% placed so that the top is aligned with this point.
LowYPoint = min(ext(:,2));
% Place the axis label at this point
XMidPoint = Xl(1)+abs(diff(Xl))/2;
tl = text(XMidPoint,LowYPoint,'X-Axis Label', ...
          'VerticalAlignment','top', ...
          'HorizontalAlignment','center');