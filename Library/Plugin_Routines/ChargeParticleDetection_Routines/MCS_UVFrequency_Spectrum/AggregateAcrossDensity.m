function ParentStruct = AggregateAcrossDensity(DensityGroupsToAverage, ParentStruct)
   
    [Dummy_UVSpec] = deal(cell(1,length(DensityGroupsToAverage)));
    
    for DensityGroupIndex = 1:length(DensityGroupsToAverage)
        den = DensityGroupsToAverage{DensityGroupIndex};
        Dummy_UVSpec{DensityGroupIndex} = ParentStruct.yData(den);
        Dummy_UVSpec{DensityGroupIndex} = cell2mat(Dummy_UVSpec{DensityGroupIndex});   
        AveUVSpectrum2{DensityGroupIndex} = nanmean(Dummy_UVSpec{DensityGroupIndex},2);        
    end


end

