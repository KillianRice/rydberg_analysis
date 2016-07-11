function [ indivDataset ] = CropData( analyVar,indivDataset )

NumStates = analyVar.numBasenamesAtom;
NormalizationDimension = 1; %sfi arrival bin/time dimension
%% Different Rydberg States
[CropData,CropData_error, TotalRydPop, TotalRydPop_error] = deal(cell(1,NumStates));

for mbIndex = 1:NumStates  
    
    roiStart = analyVar.roiStart(mbIndex);
    type = analyVar.Atomic_Or_Molecular(mbIndex);
    switch type
        case 0
            FeatureBinRange = analyVar.FeatureBinRange_Atom;
        case 1
            FeatureBinRange = analyVar.FeatureBinRange_Molecule;
    end

    NumFeatures = length(FeatureBinRange);
    [Feature_AbsNormAvgSpectra, Feature_AbsNormAvgSpectra_error] = deal(cell(1,NumFeatures));
    
%     figure()
    for featureIndex = 1:NumFeatures 
        FeatureBinRange{featureIndex} = FeatureBinRange{featureIndex} - (roiStart-1);
        AbsNormAvgSpectra                               = indivDataset{mbIndex}.AbsNormAvgSpectra(FeatureBinRange{featureIndex},:,:);
        AbsNormAvgSpectra_error                         = indivDataset{mbIndex}.AbsNormAvgSpectra_error(FeatureBinRange{featureIndex},:,:);
        Feature_AbsNormAvgSpectra{featureIndex}         = nansum(AbsNormAvgSpectra,NormalizationDimension);
        Feature_AbsNormAvgSpectra{featureIndex}         = permute(Feature_AbsNormAvgSpectra{featureIndex}, [2 3 1]);
        Feature_AbsNormAvgSpectra_error{featureIndex}   = nansum(AbsNormAvgSpectra_error.^2,NormalizationDimension).^0.5;
        Feature_AbsNormAvgSpectra_error{featureIndex}   = permute(Feature_AbsNormAvgSpectra_error{featureIndex}, [2 3 1]);
%         
%         subplot(3,4,featureIndex)
%         hold on
%         Colors = jet(indivDataset{1}.numDelayTimes{1});
%         for DelayIndex = 1:indivDataset{1}.numDelayTimes{1}
%             plot(FeatureBinRange{featureIndex}+(roiStart-1), AbsNormAvgSpectra(:,DelayIndex,1),'-o','Color',Colors(DelayIndex,:) )
%         end
%         grid on
%         hold off
    end
    
    CropData{mbIndex} = Feature_AbsNormAvgSpectra;
    CropData_error{mbIndex} = Feature_AbsNormAvgSpectra_error;
    
    %% Sum of All Bins

        TotalRydPop{mbIndex}         = nansum(indivDataset{mbIndex}.AbsNormAvgSpectra,NormalizationDimension);
        TotalRydPop{mbIndex}         = permute(TotalRydPop{mbIndex}, [2 3 1]);
        TotalRydPop_error{mbIndex}   = nansum(indivDataset{mbIndex}.AbsNormAvgSpectra_error.^2,NormalizationDimension).^0.5;
        TotalRydPop_error{mbIndex}   = permute(TotalRydPop_error{mbIndex}, [2 3 1]);

    %% save to structure
        indivDataset{mbIndex}.Feature_AbsNormAvgSpectra         = CropData{mbIndex};
        indivDataset{mbIndex}.Feature_AbsNormAvgSpectra_error   = CropData_error{mbIndex};
        indivDataset{mbIndex}.NormTotalPopAvgSpectra            = TotalRydPop{mbIndex}; %Population normalized by the total population at t = 0
        indivDataset{mbIndex}.NormTotalPopAvgSpectra_error      = TotalRydPop_error{mbIndex}; 

end
end