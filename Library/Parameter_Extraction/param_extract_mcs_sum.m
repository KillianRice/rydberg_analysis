function indivDataset = param_extract_mcs_sum(analyVar,indivDataset)
% The MCS data has already been read in. the goal of this function is to sort
% the data out and exclude some of the data according to the desired region
% of interest.

if analyVar.LoadData ~= 1
    
    Num_mb = analyVar.numBasenamesAtom; %number of data sets (number of entries in the master batch file)
    SFI_Spectrum     = cell(1,Num_mb);

    for mbIndex = 1:Num_mb
        Num_b = indivDataset{mbIndex}.CounterMCS; %number of entries in a data set (number of entries within each batch file)
        ArrivalTimeroi = analyVar.roiStart(mbIndex):analyVar.roiEnd(mbIndex);% set the time domain of the mcs data to look at
        numTimeBins = analyVar.RampTime(mbIndex)/analyVar.arrivalTimeBinWidth(mbIndex); %number of time bins corresponding to when the field ramps are being used. ~30us/100ns
        numDeadTimeBins = analyVar.ExposureLoopTime(mbIndex)/analyVar.arrivalTimeBinWidth(mbIndex); %number of time bins corresponding to when the field ramps are not being used. ~200us/100ns
        
        [numDensityGroups, mcsNumBins]    =   deal(cell(Num_b,1));
        for bIndex = 1:Num_b
            
            %% Load Data
            SFI_Spectrum{bIndex}         = indivDataset{mbIndex}.mcsSpectra{bIndex}; %assign ALL the mcs data from one batch file to spectra{}
                % the expect strucure is as follows:
                % left column is time stamps
                % all other columns are data; within the data, the left column
                % is highest density, right column is lowest.
                % if multiple delay times were used then the structure repeats
                % itself vertically: the top most submatrix corresponds to data
                % due to one value of delay time, the next submatrix down
                % corresponds to data at the next value of delay time used,
                % etc.
            
            %% Sort data
                % the data comes in as a tangled mess, so the first thing that
                % has to happen is sorting according to density and delay time.
                % We also exclude data given by the SFI ROI parameters in the
                % master batch file.
            
            numDensityGroups{bIndex}= size(SFI_Spectrum{bIndex}, 2)-1;%number of density groups; number of columns in data -1. -1 due to the first column being time stamps.
            numDelayTimes           = length(indivDataset{mbIndex}.timedelayOrderMatrix{bIndex}); % number of delay times used
            numRows                 = (numDelayTimes*analyVar.RampTime(mbIndex)+(numDelayTimes-1)*analyVar.ExposureLoopTime(mbIndex))/...
                analyVar.arrivalTimeBinWidth(mbIndex); % calculate the expected number of rows in the raw data
            
            if int32(numRows) ~= int32(size(SFI_Spectrum {bIndex},1))              
                error('FC: The number of rows in MCS data does not match the expected number calculated from the parameters set in the master batch file.')
            end
            
            SFI_Spectrum{bIndex}         = cat(1,SFI_Spectrum{bIndex}, nan(int32(numDeadTimeBins), numDensityGroups{bIndex}+1)); 
                % data comes with numRows equal to
                % (# of delays) x (# of bins during field ramps) + (# of delays - 1) x (# of bins during the rest of the loop time)
                % which is a problamatic structure because we want to reshape. 
                % So pad the array such that the number of rows in spectra{bIndex} is 
                % (# of delays) x (# of bins during field ramps + # of bins during the rest of the loop time)
            
            SFI_Spectrum{bIndex}   = reshape(SFI_Spectrum{bIndex}(:,2:end), [int32(numTimeBins+numDeadTimeBins), numDelayTimes, numDensityGroups{bIndex}]);
                % reshape to have dimensions of 
                % (# of time bins) x (# number of delay times) x (# number of columns)
            SFI_Spectrum{bIndex}   = SFI_Spectrum{bIndex}(1:int32(numTimeBins),:,:);
                % only keep data that starts at the begining of field
                % ionization and ends at the end of field ionization; exclude
                % data from the rest of the loop (which should just be
                % background counts).

            %% Pick out data with in the region of interest
            if numDensityGroups{bIndex} == 1
                SFI_Spectrum{bIndex} = SFI_Spectrum{bIndex}(ArrivalTimeroi,:);
            else
                SFI_Spectrum{bIndex} = SFI_Spectrum{bIndex}(ArrivalTimeroi,:,:); 
            end
            
            %% Sort the data according to the ramp time delay
            [indivDataset{mbIndex}.timedelayOrderMatrix{bIndex}, SortedTimeDelayVector] ...
                                                                = sort(indivDataset{mbIndex}.timedelayOrderMatrix{bIndex}); 
                % delay times values used in real time may have been 
                % random, so sort them out.
            SFI_Spectrum{bIndex}                                = SFI_Spectrum{bIndex}(:,SortedTimeDelayVector,:);    
                % apply sorting of delay times to the data.
            mcsNumBins{bIndex}                                  = size(SFI_Spectrum{bIndex},1); 
                % number of time bins in an mcs trace given that we have 
                % already picked out some time bins with choice of roi.
            indivDataset{mbIndex}.numDensityGroups{bIndex}      = numDensityGroups{bIndex};
            indivDataset{mbIndex}.mcsNumBins{bIndex}            = mcsNumBins{bIndex};
            indivDataset{mbIndex}.delay_spectra{bIndex}         = SFI_Spectrum{bIndex}; %sorted spectra
            indivDataset{mbIndex}.numDelayTimes{bIndex}         = length(indivDataset{mbIndex}.timedelayOrderMatrix{bIndex});
                % assign to indivDataset structure which will be passed to
                % the rest of the analysis program.
        end
        
        indivDataset{mbIndex} = rmfield(indivDataset{mbIndex},'mcsSpectra');
            %remove raw data from indivDataset, just keep the data within the roi
    end

    %% Save cut data
    % will overwrite any file that shares this name, this way can just add
    % more batches and rerun code with analyVar.LoadData flag set to 0 to
    % make a new version of the .mat file with the data that is uncommented out in the master batch text file.
    
% % %     resavename = [analyVar.dataDir mat2str(analyVar.timevectorAtom(1)) '.mat'];
% % %     save(resavename, 'indivDataset');
% % %     fclose all;

end

end