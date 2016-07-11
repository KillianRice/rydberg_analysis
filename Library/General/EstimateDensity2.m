function [analyVar, indivDataset] = EstimateDensity2( analyVar, indivDataset )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

InitialODTHold      = analyVar.InitialODTHold;
InitPeakDensity     = analyVar.InitPeakDensity;
Time_Off            = analyVar.ExposureTimeOff;
Exposure_Time       = analyVar.Exposure_Time;
DecayRate_ODT       = analyVar.DecayRate_ODT;
DecayRate_UV_Slope  = analyVar.DecayRate_UV_Slope;
DecayRate_UV        = DecayRate_UV_Slope.*Exposure_Time;

switch analyVar.Density_Calc
    case 1

    [InitialSignalValue, densityvector] = deal(cell(1,analyVar.numBasenamesAtom));
    for mbIndex     =   1:analyVar.numBasenamesAtom
        InitialSignalValue{mbIndex}=indivDataset{mbIndex}.Sum_AvgSpectra(:,1);
%         indivDataset{mbIndex}.winTotNum

    densityvector{mbIndex}  = InitPeakDensity(mbIndex)*(InitialSignalValue{mbIndex}/InitialSignalValue{mbIndex}(1));
    indivDataset{mbIndex}.densityvector = densityvector{mbIndex};
    end

    case  2
        
    [Time_Cell, densityvector] = deal(cell(1,analyVar.numBasenamesAtom));
    for mbIndex = 1:analyVar.numBasenamesAtom
        ExposureLoopTime    = analyVar.ExposureLoopTime(mbIndex);
        RampTime            = analyVar.RampTime(mbIndex);
        LoopTime            = RampTime + ExposureLoopTime ;
        numDelayTimes       = length(indivDataset{1}.timedelayOrderMatrix{1});
        numLoopsSets        = analyVar.numLoopsSets(mbIndex) ;
        Time_On             = numLoopsSets.*numDelayTimes.*LoopTime;
    
        numDensityGroups    = indivDataset{mbIndex}.numDensityGroups{1};
        Time_Cell{mbIndex}  = InitialODTHold(mbIndex)+...
                              0.5*ExposureLoopTime+...
                              LoopTime*(numLoopsSets.*numDelayTimes-1)/2+...
                              [0:numDensityGroups-1]*(Time_On+Time_Off(mbIndex));
        
%         densityvector{mbIndex} =...
%             InitPeakDensity(mbIndex)*exp(...
%                 -(...
%                     DecayRate_ODT(mbIndex)+DecayRate_UV(mbIndex)*(numDensityGroups*Time_On/(InitialODTHold(mbIndex)+numDensityGroups*Time_On+(numDensityGroups-1)*Time_Off(mbIndex)))...
%                 )*Time_Cell{mbIndex}...
%             );

%% correct for odt hold time offset
%         densityvector{mbIndex}        = nan(size(Time_Cell{mbIndex}));
%         densityvector{mbIndex}(1)     = InitPeakDensity(mbIndex)*exp(-DecayRate_ODT(mbIndex)*Time_Cell{mbIndex}(1));
%         densityvector{mbIndex}(2:end) =...
%             densityvector{mbIndex}(1)*...
%             exp(...
%             -(Time_Cell{mbIndex}(2:end)-Time_Cell{mbIndex}(1))*...
%             (DecayRate_ODT(mbIndex)+DecayRate_UV(mbIndex)*(Time_On/(Time_On+Time_Off(mbIndex))))...
%             ); 
        
%% calculate excatly at each time step
        densityvector{mbIndex}        = nan(1,numDensityGroups);
        densityvector{mbIndex}(1)     = InitPeakDensity(mbIndex)*exp(-DecayRate_ODT(mbIndex)*InitialODTHold(mbIndex));
        densityvector{mbIndex}(1)     = densityvector{mbIndex}(1)*exp(-(DecayRate_ODT(mbIndex)+DecayRate_UV(mbIndex))*Time_On/2);
        densityIndex = 2;
        while densityIndex < length(Time_Cell{mbIndex})+1
            denA = densityvector{mbIndex}(densityIndex-1)*exp(-(DecayRate_ODT(mbIndex)+DecayRate_UV(mbIndex))*Time_On/2);
            denB = denA*exp(-DecayRate_ODT(mbIndex)*Time_Off(mbIndex));
            densityvector{mbIndex}(densityIndex) = denB*exp(-(DecayRate_ODT(mbIndex)+DecayRate_UV(mbIndex))*Time_On/2);
            densityIndex = densityIndex + 1;
        end
%% Calculate Average Density
        % ave density = peak density /(2^3/2) 
        % Collisional dynamics of ultra-cold atomic gases
        % Jean Dalibard
        densityvector{mbIndex} = densityvector{mbIndex}/(2^(3/2));

%% save to struct
        densityvector{mbIndex} = densityvector{mbIndex}';
        indivDataset{mbIndex}.densityvector = densityvector{mbIndex};
        
    end

end

end



