function [ Ave_SFI, Ave_SFI_error, stats_counter] = AverageAcrossFrequency_SFI(analyVar, featurePos, Ave_SFI, Ave_SFI_error, stats_counter)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

plotBoolean = 0; % 1 to plot

xData = analyVar.ElectricField;

[Ave_SFI2, Ave_SFI2_error, Ave_SFI3, Ave_SFI3_error] = deal(cell(1,length(featurePos)));

for featureIndex = 1:length(featurePos)
    Ave_SFI2{featureIndex} = Ave_SFI(featurePos{featureIndex}(1):featurePos{featureIndex}(end)); 
    Ave_SFI2_error{featureIndex} = Ave_SFI_error(featurePos{featureIndex}(1):featurePos{featureIndex}(end)); 
        % pick out the frequencies with features of interest
    [Ave_SFI3{featureIndex}, Ave_SFI3_error{featureIndex}] = deal([]); %once filled, will have dimensions of SFI ROI x Num of density groups x number of frequencies within feature featureIndex
        % initialize empty arrays to be filled with data
        NumPoints = featurePos{featureIndex}(end)-featurePos{featureIndex}(1)+1;
    for freqIndex = 1:NumPoints;
        Ave_SFI3{featureIndex} = cat(3, Ave_SFI3{featureIndex}, cell2mat(Ave_SFI2{featureIndex}{freqIndex}));
        Ave_SFI3_error{featureIndex} = cat(3, Ave_SFI3_error{featureIndex}, cell2mat(Ave_SFI2_error{featureIndex}{freqIndex}));
    end
        % filled out arrays with data
    Ave_SFI3{featureIndex} = nanmean(Ave_SFI3{featureIndex},3);   
        % find the mean of the data at different frequencies
    Ave_SFI3_error{featureIndex} = nanmean(Ave_SFI3_error{featureIndex},3);        
%     Ave_SFI3_error{featureIndex} = (size(Ave_SFI3_error{featureIndex}, 3)^-1)*(nansum(Ave_SFI3_error{featureIndex}.^2,3).^0.5);
        % propagate uncertainty
    Ave_SFI3{featureIndex}          = mat2cell(Ave_SFI3{featureIndex},size(Ave_SFI3{featureIndex},1),ones(1,size(Ave_SFI3{featureIndex},2)));
    Ave_SFI3_error{featureIndex}    = mat2cell(Ave_SFI3_error{featureIndex},size(Ave_SFI3_error{featureIndex},1),ones(1,size(Ave_SFI3_error{featureIndex},2)));
end 

stats_counter = stats_counter*NumPoints;
Ave_SFI = Ave_SFI3';
Ave_SFI_error = Ave_SFI3_error';

if plotBoolean == 1
    for featureIndex = 1:length(featurePos)
        for densityIndex = 1:size(Ave_SFI3{featureIndex},2)
            mycolors = FrancyColors(NumPoints);            
            figure
            hold on
            for freqIndex = 1:NumPoints;        
                plot(xData, Ave_SFI2{featureIndex}{freqIndex}{densityIndex},'Color',mycolors(freqIndex,:))
            end
            plot(xData, Ave_SFI3{featureIndex}(:,densityIndex),'Color',[0 0 0])
            hold off
            set(gca,...
                'YLim', [0, .05])
        end
    end
    
    mycolors2 = FrancyColors(size(Ave_SFI3{featureIndex},2));
    for featureIndex = 1:length(featurePos)
        figure
        hold on
        for densityIndex = 1:size(Ave_SFI3{featureIndex},2)
            plot(xData, Ave_SFI3{featureIndex}(:,densityIndex),'Color', mycolors2(densityIndex,:))
        end
        hold off
        set(gca,...
            'YLim', [0, .05])        
    end    
    
end


% for densityIndex = 1:length(unique_Density)
% 
%     figure
%     hold on
%     plotHan = cell(1,length(freqvector));
%     ColorArray = FrancyColors(length(freqvector));
%     
%     [Ave_SFI2, Ave_SFI_error2] = deal(cell(1, length(Ave_SFI{1})));
%     [Ave_SFI2{:}] = cellfun(@(x) x{:}, Ave_SFI,'UniformOutput', 0);
%     [Ave_SFI_error2{:}] = cellfun(@(x) x{:}, Ave_SFI_error,'UniformOutput', 0);
% %     Ave_SFI = Ave_SFI2;
% %     Ave_SFI_error = Ave_SFI_error2;
% %     clear Ave_SFI2
% %     clear Ave_SFI_error2
% 
% 
% %% Normalize to Unity Area
%     NormalizeFlag = 1;
%     if NormalizeFlag 
%         for freqIndex = 1:length(freqvector)
%             freq = freqvector(freqIndex);
%             [Ave_SFI2{densityIndex}{freq}, Ave_SFI_error2{densityIndex}{freq}] = NormalizeArray3(analyVar.ElectricField, Ave_SFI2{densityIndex}{freq}, Ave_SFI_error2{densityIndex}{freq});
%         end
%     end
%    
%     yDataAve{densityIndex} = cell2mat(Ave_SFI2{densityIndex}(freqvector)');
%     yDataAve{densityIndex} = nanmean(yDataAve{densityIndex},2);
%     
%     for freqIndex = 1:length(freqvector)
%         freq = freqvector(freqIndex);
% %         plotHan{freqIndex} = plot(xData, Ave_SFI2{densityIndex}{freq});
%         plotHan{freqIndex} = errorbar(xData, Ave_SFI2{densityIndex}{freq},...
%             Ave_SFI_error2{densityIndex}{freq});
%         removeErrorBarEnds(plotHan{freqIndex});
%         set(plotHan{freqIndex}, ...
%             'LineStyle'       , '-' , ...
%             'LineWidth'       , 0.5,...
%             'Color'           , ColorArray(freqIndex,:),...
%             'marker'          , 'o',...
%             'markerfacecolor' , ColorArray(freqIndex,:)...
%             );         
%     end
%     plot(xData, yDataAve{densityIndex},...
%             'LineStyle'       , '-' , ...
%             'LineWidth'       , 0.5,...
%             'Color'           , [0 0 0],...
%             'marker'          , 'o',...
%             'markerfacecolor' , [0 0 0]);
%     hold off
% end

end

