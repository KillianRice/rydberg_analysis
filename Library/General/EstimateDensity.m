function [analyVar, indivDataset] = EstimateDensity( analyVar, indivDataset )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

InitialODTHold      = analyVar.InitialODTHold;
InitPeakDensity     = analyVar.InitPeakDensity;
Time_Off            = analyVar.ExposureTimeOff;
Exposure_Time       = analyVar.Exposure_Time;
DecayRate_ODT       = analyVar.DecayRate_ODT;
DecayRate_UV_Slope  = analyVar.DecayRate_UV_Slope;
DecayRate_UV        = DecayRate_UV_Slope.*Exposure_Time;

figure()
hold on
 
switch analyVar.Density_Calc
    case 1

    [InitialSignalValue, densityvector] = deal(cell(1,analyVar.numBasenamesAtom));
    for mbIndex     =   1:analyVar.numBasenamesAtom
        InitialSignalValue{mbIndex}=indivDataset{mbIndex}.Sum_AvgSpectra(:,1);
%         indivDataset{mbIndex}.winTotNum

    densityvector{mbIndex}  = InitPeakDensity(mbIndex)*(InitialSignalValue{mbIndex}/InitialSignalValue{mbIndex}(1));
    indivDataset{mbIndex}.densityvector = densityvector{mbIndex};
    den = densityvector{mbIndex};
    errorbar(den,indivDataset{mbIndex}.Sum_DecayRate(:,1),indivDataset{mbIndex}.Sum_DecayRate(:,2),'-o','Color',analyVar.COLORS(mbIndex,:))
    end

%     errorbar(den,indivDataset{1}.Sum_DecayRate(:,1),indivDataset{1}.Sum_DecayRate(:,2),'o','Color','blue')
    
    case  2

        
    [Time_Cell, densityvector] = deal(cell(1,analyVar.numBasenamesAtom));
    for mbIndex = 1:analyVar.numBasenamesAtom
        LoopTime            = analyVar.RampTime(mbIndex) + analyVar.ExposureLoopTime(mbIndex) ;
        numDelayTimes       = length(indivDataset{1}.timedelayOrderMatrix{1});
        numLoopsSets        = analyVar.numLoopsSets(mbIndex) ;
        Time_On             = numLoopsSets.*numDelayTimes.*LoopTime;
    
        numDensityGroups    = indivDataset{mbIndex}.numDensityGroups{1};
        Time_Cell{mbIndex} = InitialODTHold(mbIndex)+0.5*Time_On+[0:numDensityGroups-1]*(Time_On+Time_Off(mbIndex));
        
        densityvector{mbIndex} =...
            InitPeakDensity(mbIndex)*exp(...
                -(...
                    DecayRate_ODT(mbIndex)+DecayRate_UV(mbIndex)*(Time_On/(Time_On+Time_Off(mbIndex)))...
                )*Time_Cell{mbIndex}...
            );
        
        densityvector{mbIndex} = densityvector{mbIndex}';
        indivDataset{mbIndex}.densityvector = densityvector{mbIndex};
        
        den = densityvector{mbIndex};
        errorbar(den,indivDataset{mbIndex}.Sum_DecayRate(:,1),indivDataset{mbIndex}.Sum_DecayRate(:,2),'-o','Color',analyVar.COLORS(mbIndex,:))
        
    end

end

    legend('atomic 1831','atomic 1909 random','ground 2122 random','ground 2204','first 2329','second 2326','second 0014 random')
grid on
hold off

end



