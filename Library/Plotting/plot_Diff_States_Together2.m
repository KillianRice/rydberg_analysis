function [ output_args ] = plot_Diff_States_Together2(analyVar, indivDataset, xVariable, legendVariable)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

NumDensities = indivDataset{1}.numDensityGroups{1};
NumBatches = indivDataset{1}.CounterAtom;
NumStates = analyVar.numBasenamesAtom;

[tickNums, tickNames] = deal(cell(1,3));
tickNums{1} = [118 130 144 160  179  199  224  251  284  321 365];
tickNums{2} = [112 124 137 152  169  189  211  237  267  302 343 391];
tickNums{3} = [109 121 133 148  164  183  204  229  258  291 329 374];

tickNames{1} = {'44S','43S', '42S', '41S', '40S', '39S', '38S', '37S', '36S', '35S', '34S'};
tickNames{2} = {'44P', '43P', '42P', '41P', '40P', '39P', '38P', '37P', '36P', '35P', '34P' '33P'};
tickNames{3} = {'44D', '43D', '42D', '41D', '40D', '39D', '38D', '37D', '36D', '35D', '34D', '33D'};

%% Choose sample data
% fixedField = analyVar.PeakBin;
fixedDelayTime = 1;
fixedDensity = 1;
fixedFrequency = 1;
DelayDim = 2;

%% Load Data

% for mbIndex = 1:NumStates
%     [AbsNormAvgSpectra, NormTotalPopNonPeak_AvgSpectra, NormRydPopAvgSpectra, NormRydPopNonPeak_AvgSpectra ] = deal([]);
%     ArrayDim = ndims(indivDataset{mbIndex}.AbsNormAvgSpectra);
%     
%     AbsNormAvgSpectra          = cat(ArrayDim+1,AbsNormAvgSpectra,indivDataset{mbIndex}.AbsNormAvgSpectra);
% %     NormTotalPopNonPeak_AvgSpectra  = cat(4,NormTotalPopNonPeak_AvgSpectra,indivDataset{bIndex}.NormTotalPopNonPeak_AvgSpectra);
%     NormRydPopAvgSpectra            = cat(ArrayDim+1,NormRydPopAvgSpectra,indivDataset{mbIndex}.RelNormAvgSpectra);
% %     NormRydPopNonPeak_AvgSpectra    = cat(4,NormRydPopNonPeak_AvgSpectra,indivDataset{bIndex}.NormRydPopNonPeak_AvgSpectra);

for DelayIndex = 1
%     figHan = figure('Units', 'pixels', ...
%     'Position', [100 100 500 375]);
    figHan = figure;
    set(figHan, 'Units', 'Normalized');
    set(figHan, 'OuterPosition', [0 0 1 1]);
    
    [AbsNormAvgSpectra, RelNormAvgSpectra] = deal([]);
    for mbIndex = 1:NumStates

        AbsNormAvgSpectra          = cat(DelayDim,AbsNormAvgSpectra,indivDataset{mbIndex}.AbsNormAvgSpectra(:,DelayIndex,:));
    %     NormTotalPopNonPeak_AvgSpectra  = cat(4,NormTotalPopNonPeak_AvgSpectra,indivDataset{bIndex}.NormTotalPopNonPeak_AvgSpectra);
        RelNormAvgSpectra            = cat(DelayDim,RelNormAvgSpectra,indivDataset{mbIndex}.RelNormAvgSpectra(:,DelayIndex,:));
    %     NormRydPopNonPeak_AvgSpectra    = cat(4,NormRydPopNonPeak_AvgSpectra,indivDataset{bIndex}.NormRydPopNonPeak_AvgSpectra);
    end


%% Select Axis
dataCell = cell(1,4);
dataCell{1} =  AbsNormAvgSpectra;
dataCell{2} =  RelNormAvgSpectra;
dataCell{3} =  AbsNormAvgSpectra;
dataCell{4} =  RelNormAvgSpectra;

switch xVariable

    case 1
        [xData, ~, ~] = AxisTicksEngineeringForm(abs(analyVar.ElectricField));
%         [xData, ~, ~] = AxisTicksEngineeringForm(analyVar.roiStart:analyVar.roiEnd);
        xData = reshape(xData, [length(xData),1]);
        xData = abs(xData);
        x_string = 'Ionization Field (V/cm)';
    case 2
        [xData, ~, ~] = AxisTicksEngineeringForm(indivDataset{1}.timedelayOrderMatrix{1});
        xData = reshape(xData, [length(xData),1]);
        x_string = 'Field Delay (s)';
        
    case 3
        [xData, ~, ~] = AxisTicksEngineeringForm(indivDataset{1}.densityvector);
        xData = reshape(xData, [length(xData),1]);
        x_string = 'Peak Density (10^12 cm^-3)';
    case 4
        [xData, ~, ~] = AxisTicksEngineeringForm(indivDataset{1}.synthFreq);
        xData = reshape(xData, [length(xData),1]);
        x_string = 'Synth Freq. (MHz)';
end


axHan = cell(1,4);
    set(figHan, 'Color', [1,1,1]);

    
for subplotIndex = 1:4    
    axHan{subplotIndex} = subplot(2,2,subplotIndex);
        hold on
        for legIndex = 1:size(AbsNormAvgSpectra,legendVariable)
            switch  legendVariable+(xVariable-1)*4
                
                % counts vs Electric Field
                case 1
                    error('Change xVariable or legendVariable.')
                case 2
                    yData = dataCell{subplotIndex}(:,legIndex,fixedDensity,fixedFrequency);
                    yData = permute(yData, [1,2,3,4]);
                    AvgSpectra2Color = flipud(RedToBlue(size(AbsNormAvgSpectra,legendVariable)));
                case 3
                    yData = dataCell{subplotIndex}(:,fixedDelayTime,legIndex,fixedFrequency);
                    yData = permute(yData, [1,3,2,4]);
                    AvgSpectra2Color = flipud(RedToBlue(size(AbsNormAvgSpectra,legendVariable)));
                case 4
                    yData = dataCell{subplotIndex}(:,fixedDelayTime,fixedDensity,legIndex);
                    yData = permute(yData, [1,4,2,3]);
                    AvgSpectra2Color = flipud(RedToBlue(size(AbsNormAvgSpectra,legendVariable)));
                
                % counts vs Field Delay
                case 5
                    yData = dataCell{subplotIndex}(legIndex,:,fixedDensity,fixedFrequency);
                    yData = permute(yData, [2,1,3,4]);
                    AvgSpectra2Color = RedToBlue(size(AbsNormAvgSpectra,legendVariable));
                case 6
                    error('Change xVariable or legendVariable.')
                case 7
                    yData = dataCell{subplotIndex}(fixedField,:,legIndex,fixedFrequency);
                    yData = permute(yData, [2,3,1,4]);
                    AvgSpectra2Color = RedToBlue(size(AbsNormAvgSpectra,legendVariable));                    
                case 8
                    yData = dataCell{subplotIndex}(fixedField,:,fixedDensity,legIndex);
                    yData = permute(yData, [2,4,1,3]);
                    AvgSpectra2Color = RedToBlue(size(AbsNormAvgSpectra,legendVariable));                 
                
                % counts vs Peak Density    
                case 9
                    yData = dataCell{subplotIndex}(legIndex,fixedDelayTime,:,fixedFrequency);
                    yData = permute(yData, [3,1,2,4]);
                    AvgSpectra2Color = RedToBlue(size(AbsNormAvgSpectra,legendVariable));                    
                case 10
                    yData = dataCell{subplotIndex}(fixedField,legIndex,:,fixedFrequency);
                    yData = permute(yData, [3,2,1,4]);
                    AvgSpectra2Color = RedToBlue(size(AbsNormAvgSpectra,legendVariable));
                case 11
                    error('Change xVariable or legendVariable.')
                case 12
                    yData = dataCell{subplotIndex}(fixedField,fixedDelayTime,:,legIndex);
                    yData = permute(yData, [3,4,1,2]);
                    AvgSpectra2Color = RedToBlue(size(AbsNormAvgSpectra,legendVariable));
                
                % counts vs Synth Frequency     
                case 13
                    yData = dataCell{subplotIndex}(legIndex,fixedDelayTime,fixedDensity,:);
                    yData = permute(yData, [4,1,2,3]);
                    AvgSpectra2Color = RedToBlue(size(AbsNormAvgSpectra,legendVariable));                    
                case 14                    
                    yData = dataCell{subplotIndex}(fixedField,legIndex,fixedDensity,:);
                    yData = permute(yData, [4,2,1,3]);
                    AvgSpectra2Color = RedToBlue(size(AbsNormAvgSpectra,legendVariable));                    
                case 15
                    yData = dataCell{subplotIndex}(fixedField,fixedDelayTime,legIndex,:);
                    yData = permute(yData, [4,3,1,2]);
                    AvgSpectra2Color = RedToBlue(size(AbsNormAvgSpectra,legendVariable));                    
                case 16                    
                    error('Change xVariable or legendVariable.')
            end

        DataPlotHan = plot(...
            xData,...
            yData,...
            analyVar.MARKERS{legIndex},...
            'MarkerSize',analyVar.markerSize/4,...
            'color',AvgSpectra2Color(legIndex,:)...
            );
        
        end
        
        xlabel(x_string)

        grid on
        
        if subplotIndex == 3 || subplotIndex == 4
            set(axHan{subplotIndex},'YScale','log')
        end                

        if subplotIndex == 1 || subplotIndex == 3
            ylabel('Frac. Pop Over All States') 
        else
            ylabel('Frac. Pop Over Rydberg States') 
        end
            
        set(axHan{subplotIndex},'Color',[1,1,1]);
        set(axHan{subplotIndex},'FontSize',10);
        set(axHan{subplotIndex},'Units','normal');
        set(axHan{subplotIndex},'TickDir','out');
        set(axHan{subplotIndex},'TickLength',[.01 0.025]);
        set(axHan{subplotIndex},'xlim',[min(xData) max(xData)])

        
        hold off
        

end





% %                 [legendstr, ~, ~] = AxisTicksEngineeringForm(delatyData);
% %                 legendstr = textscan(num2str(legendstr),'%s');
% %                 legendstr = reshape(legendstr{1}, [length(legendstr{1}),1]);
% %                 legHandle = legend(legendstr);
% %                 set(get(legHandle,'title'),'string','Field Delay (us)')

        switch legendVariable
            case 1
                [legendstr, ~, ~] = AxisTicksEngineeringForm(abs(analyVar.ElectricField)');
                legendstr = round(legendstr);
                legendstr = textscan(num2str(legendstr),'%s');
                legendstr = reshape(legendstr{1}, [length(legendstr{1}),1]);
                legHandle = legend(legendstr);
                set(get(legHandle,'title'),'string','Electric Field (V/cm)')
            case 2
%                 [legendstr, ~, ~] = AxisTicksEngineeringForm(indivDataset{1}.timedelayOrderMatrix{1});
%                 legendstr = textscan(num2str(legendstr),'%s');
%                 legendstr = reshape(legendstr{1}, [length(legendstr{1}),1]);
                legHandle = legend('Atomic','Ground','1st Excited', '2nd Excited');
                set(get(legHandle,'title'),'string','State')
                set(legHandle,'Units','Normalized');
                set(legHandle,'Position',[.375 .67 .05 .2]);
            case 3
                [legendstr, ~, ~] = AxisTicksEngineeringForm(indivDataset{1}.densityvector');
                legendstr = textscan(num2str(legendstr),'%s');
                legendstr = reshape(legendstr{1}, [length(legendstr{1}),1]);
                legHandle = legend(legendstr);
                set(get(legHandle,'title'),'string','Peak Density (10^12 cm^-3)')                
            case 4
                [legendstr, ~, ~] = AxisTicksEngineeringForm(indivDataset{1}.synthFreq');
                legendstr = textscan(num2str(legendstr),'%s');
                legendstr = reshape(legendstr{1}, [length(legendstr{1}),1]);
                legHandle = legend(legendstr);
                set(get(legHandle,'title'),'string','Synth Freq. (MHz)') 
        end 
        
StateAxis
        
end
end

