function [ output_args ] = plot_Diff_States_Together(analyVar, indivDataset, xVariable, legendVariable)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

NumDensities = indivDataset{1}.numDensityGroups{1};
NumBatches = indivDataset{1}.CounterAtom;
NumStates = analyVar.numBasenamesAtom;
%% Choose sample data
% fixedField = analyVar.PeakBin;
fixedDelayTime = 1;
DelayVec = 0:10e-6:150e-6;
fixedDensity = 1;
fixedFrequency = 1;
DelayDim = 2;

%% Load Data


for DelayIndex = 1
    figHan = figure();
    [AbsNormAvgSpectra, NormTotalPopNonPeak_AvgSpectra, RelNormAvgSpectra, NormRydPopNonPeak_AvgSpectra ] = deal([]);
    for mbIndex = 1:NumStates

%         ArrayDim = ndims(indivDataset{mbIndex}.NormTotalPopAvgSpectra(:,DelayIndex,:));

        AbsNormAvgSpectra          = cat(DelayDim,AbsNormAvgSpectra,indivDataset{mbIndex}.AbsNormAvgSpectra(:,DelayIndex,:));
    %     NormTotalPopNonPeak_AvgSpectra  = cat(4,NormTotalPopNonPeak_AvgSpectra,indivDataset{bIndex}.NormTotalPopNonPeak_AvgSpectra);
        RelNormAvgSpectra            = cat(DelayDim,RelNormAvgSpectra,indivDataset{mbIndex}.RelNormAvgSpectra(:,DelayIndex,:));
    %     NormRydPopNonPeak_AvgSpectra    = cat(4,NormRydPopNonPeak_AvgSpectra,indivDataset{bIndex}.NormRydPopNonPeak_AvgSpectra);
    end

% % TotalRydPop     = nansum(NormTotalPopAvgSpectra,1);
% % TotalRydPop     = permute(TotalRydPop, [2 3 4 1]);
% % 
% % TotalLoss       = 1-TotalRydPop;

%% Select Axis
dataCell = cell(1,4);
dataCell{1} =  AbsNormAvgSpectra;
dataCell{2} =  RelNormAvgSpectra;
dataCell{3} =  AbsNormAvgSpectra;
dataCell{4} =  RelNormAvgSpectra;

switch xVariable

    case 1
        [xData, ~, ~] = AxisTicksEngineeringForm(abs(analyVar.ElectricField));
        xData = reshape(xData, [length(xData),1]);
        xData = abs(xData);
        x_string = 'Ionization Field (V/cm)';
    case 2
        [xData, ~, ~] = AxisTicksEngineeringForm(indivDataset{mbIndex}.timedelayOrderMatrix{1});
        xData = reshape(xData, [length(xData),1]);
        x_string = 'Field Delay (s)';
    case 3
        [xData, ~, ~] = AxisTicksEngineeringForm(indivDataset{mbIndex}.densityvector);
        xData = reshape(xData, [length(xData),1]);
        x_string = 'Peak Density (10^12 cm^-3)';
    case 4
        [xData, ~, ~] = AxisTicksEngineeringForm(indivDataset{mbIndex}.synthFreq);
        xData = reshape(xData, [length(xData),1]);
        x_string = 'Synth Freq. (MHz)';
end


axHan = cell(1,4);
    set(figHan, 'Color', [1,1,1]);
    set(figHan, 'Position', [100, 100, 750, 750]);
    
for subplotIndex = 1:4    
    subplot(2,2,subplotIndex)
        hold on
        for legIndex = 1:size(AbsNormAvgSpectra,legendVariable)
            switch  legendVariable+(xVariable-1)*4
                
                % counts vs Electric Field
                case 1
                    error('Change xVariable or legendVariable.')
                case 2
                    yData = dataCell{subplotIndex}(:,legIndex,fixedDensity,fixedFrequency);
                    yData = permute(yData, [1,2,3,4]);
                    AvgSpectra2Color = flipud(jet(size(AbsNormAvgSpectra,legendVariable)));
                case 3
                    yData = dataCell{subplotIndex}(:,fixedDelayTime,legIndex,fixedFrequency);
                    yData = permute(yData, [1,3,2,4]);
                    AvgSpectra2Color = flipud(jet(size(AbsNormAvgSpectra,legendVariable)));
                case 4
                    yData = dataCell{subplotIndex}(:,fixedDelayTime,fixedDensity,legIndex);
                    yData = permute(yData, [1,4,2,3]);
                    AvgSpectra2Color = flipud(jet(size(AbsNormAvgSpectra,legendVariable)));
                
                % counts vs Field Delay
                case 5
                    yData = dataCell{subplotIndex}(legIndex,:,fixedDensity,fixedFrequency);
                    yData = permute(yData, [2,1,3,4]);
                    AvgSpectra2Color = jet(size(AbsNormAvgSpectra,legendVariable));
                case 6
                    error('Change xVariable or legendVariable.')
                case 7
                    yData = dataCell{subplotIndex}(fixedField,:,legIndex,fixedFrequency);
                    yData = permute(yData, [2,3,1,4]);
                    AvgSpectra2Color = jet(size(AbsNormAvgSpectra,legendVariable));                    
                case 8
                    yData = dataCell{subplotIndex}(fixedField,:,fixedDensity,legIndex);
                    yData = permute(yData, [2,4,1,3]);
                    AvgSpectra2Color = jet(size(AbsNormAvgSpectra,legendVariable));                 
                
                % counts vs Peak Density    
                case 9
                    yData = dataCell{subplotIndex}(legIndex,fixedDelayTime,:,fixedFrequency);
                    yData = permute(yData, [3,1,2,4]);
                    AvgSpectra2Color = jet(size(AbsNormAvgSpectra,legendVariable));                    
                case 10
                    yData = dataCell{subplotIndex}(fixedField,legIndex,:,fixedFrequency);
                    yData = permute(yData, [3,2,1,4]);
                    AvgSpectra2Color = jet(size(AbsNormAvgSpectra,legendVariable));
                case 11
                    error('Change xVariable or legendVariable.')
                case 12
                    yData = dataCell{subplotIndex}(fixedField,fixedDelayTime,:,legIndex);
                    yData = permute(yData, [3,4,1,2]);
                    AvgSpectra2Color = jet(size(AbsNormAvgSpectra,legendVariable));
                
                % counts vs Synth Frequency     
                case 13
                    yData = dataCell{subplotIndex}(legIndex,fixedDelayTime,fixedDensity,:);
                    yData = permute(yData, [4,1,2,3]);
                    AvgSpectra2Color = jet(size(AbsNormAvgSpectra,legendVariable));                    
                case 14                    
                    yData = dataCell{subplotIndex}(fixedField,legIndex,fixedDensity,:);
                    yData = permute(yData, [4,2,1,3]);
                    AvgSpectra2Color = jet(size(AbsNormAvgSpectra,legendVariable));                    
                case 15
                    yData = dataCell{subplotIndex}(fixedField,fixedDelayTime,legIndex,:);
                    yData = permute(yData, [4,3,1,2]);
                    AvgSpectra2Color = jet(size(AbsNormAvgSpectra,legendVariable));                    
                case 16                    
                    error('Change xVariable or legendVariable.')
            end

        plot(...
            xData,...
            yData,...
            analyVar.MARKERS{legIndex},...
            'MarkerSize',analyVar.markerSize/4,...
            'color',AvgSpectra2Color(legIndex,:)...
            )
        
%         plot(xData,yData,...
%             'color',AvgSpectra2Color(legIndex,:)...
%             )
        end
        

        
            axHan{subplotIndex} = gca; % current axes
                set(axHan{subplotIndex},'Color',[1,1,1]);
                set(axHan{subplotIndex},'FontSize',10);
                set(axHan{subplotIndex},'Units','normal');
                set(axHan{subplotIndex},'TickDir','out');
                set(axHan{subplotIndex},'TickLength',[.01 0.025]);
                set(axHan{subplotIndex},'xlim',[min(xData) max(xData)])
                if subplotIndex == 3 || subplotIndex == 4
                    set(axHan{subplotIndex},'YScale','log')
                end                
            xlabel(axHan{subplotIndex},x_string)
            if subplotIndex == 1 || subplotIndex == 3
                ylabel('Frac. Pop Over All States') 
            else
                ylabel('Frac. Pop Over Rydberg States') 
            end
        
        grid on
        
        if legendVariable+(xVariable-1)*4 == 5 && subplotIndex == 1
            plot(xData,TotalRydPop(:,fixedDensity,fixedFrequency),'Color','red')
            plot(xData,TotalLoss(:,fixedDensity,fixedFrequency),'Color','blue')
        end
        
        hold off
        

end

        switch legendVariable
            case 1
                [legendstr, ~, ~] = AxisTicksEngineeringForm(abs(analyVar.ElectricField)');
                legendstr = round(legendstr);
                legendstr = textscan(num2str(legendstr),'%s');
                legendstr = reshape(legendstr{1}, [length(legendstr{1}),1]);
                legHandle = legend(legendstr);
                set(get(legHandle,'title'),'string','Electric Field (V/cm)')
            case 2
%                 [legendstr, ~, ~] = AxisTicksEngineeringForm(indivDataset{mbIndex}.timedelayOrderMatrix{1});
%                 legendstr = textscan(num2str(legendstr),'%s');
%                 legendstr = reshape(legendstr{1}, [length(legendstr{1}),1]);
                legHandle = legend({'Atomic','Ground','1st Excited'});
                set(get(legHandle,'title'),'string','State')
            case 3
                [legendstr, ~, ~] = AxisTicksEngineeringForm(indivDataset{mbIndex}.densityvector');
                legendstr = textscan(num2str(legendstr),'%s');
                legendstr = reshape(legendstr{1}, [length(legendstr{1}),1]);
                legHandle = legend(legendstr);
                set(get(legHandle,'title'),'string','Peak Density (10^12 cm^-3)')                
            case 4
                [legendstr, ~, ~] = AxisTicksEngineeringForm(indivDataset{mbIndex}.synthFreq');
                legendstr = textscan(num2str(legendstr),'%s');
                legendstr = reshape(legendstr{1}, [length(legendstr{1}),1]);
                legHandle = legend(legendstr);
                set(get(legHandle,'title'),'string','Synth Freq. (MHz)') 
        end 
end
end

