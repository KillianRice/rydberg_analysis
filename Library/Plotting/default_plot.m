function [plotHan axHan] = default_plot(analyVar,iter,figNum,label,titleCell,legData,xData,yData)
% Function to create default plots of instantaneous variables. Mostly used
% to cleanup code and eliminate redundancy of code.
%
% INPUTS:
%   analyVar - structure of all pertinent variables for the imagefit
%              routines
%   iter     - 2 element vector [i j] where 
%                   i - value of current iteration (used for finding data in vectors)
%                   j - limit of iterations (used for plotting legend and title)
%   figNum   - figure where the data will be plotted
%   xData    - independent variable (along x)   
%   yData    - dependent variable (along y)
%   label    - label along y-axis
%   legData  - Vector to extract legend information from
%   title    - Cell containing title
%
% OUTPUTS:
%   plotHan  - handle to the axes plotted in case modification is required
%   Will create plot on figure figNum

%% Call figure
figure(figNum);

%% Check size of title
% If title is 1 element make this the main title
% if title is equal to the number of data vectors then use all
% else ignore title
if length(titleCell) == 1 
    mainTitle = titleCell{1};
    titleCell = cell(1,size(yData,1));
elseif length(titleCell) == size(yData,1)+1
    mainTitle = titleCell{1};
    titleCell = titleCell(2:end);
else
    mainTitle = '';
    titleCell = cell(1,size(yData,1));
end

%% Initialize variables
[plotHan axHan] = deal(zeros(1,size(yData,1)));

%% Set subplot based on number of rows of yData
for i = 1:size(yData,1)
    % Developed to compare two parameters in single plot (i.e. 2hk lattice number)
    axHan(i) = subplot(size(yData,1),1,i); hold on; grid on;

    %% Plot data
    plotHan(i) = plot(xData(i,:),yData(i,:),analyVar.MARKERS{iter(1)},'Color',analyVar.COLORS(iter(1),:),...
        'MarkerSize',analyVar.markerSize);

    %% Axes labels
    xlabel(analyVar.xDataLabel,'FontSize',analyVar.axisfontsize);
    ylabel(label{i},'FontSize',analyVar.axisfontsize);

    %% Axes limits
    % Trim mean trims away the TrimPercent and returns the average of the
    % remaining data. This helps to focus on the relevant data instead of
    % throwing off the window due to a poor fit.
    ylim(trimmean(yData(i,:),analyVar.ylimMeanTrimPercent*1e2)...
        .*[(1 - analyVar.yPlotLimBounds),(1 + analyVar.yPlotLimBounds)]);
    
    %% Subtitle
    title(titleCell{i},'FontSize',analyVar.titleFontSize)

    %% On last scan file insert legend enumerating all scans shown
    if iter(1) == iter(2) && i == size(yData,1)
        legend(num2str(legData(1:iter(1))),'Location','Best');
        set(gcf,'Name',[label{i} ': Time = ' num2str(analyVar.timevectorAtom(iter(1)))])
        if ~isempty(mainTitle)
            mtit([mainTitle ' using ' strrep(analyVar.fitModel,analyVar.InitCase,[analyVar.InitCase ' '])],...
                'FontSize',analyVar.titleFontSize,'zoff',0,'xoff',-.01)
        end
    end
end
end