function [files] = save_data_to_txt_ver3(analyVar, indivDataset, avgDataset)
% 2019/02/07 - work-in-progress towards a more versatile function for
%              writing output data. 
    
    % Subdirectory to write to
    output_dir = './out/';
    
    % Options
    use_dac = 1;
    use_labview = 1;
    use_images = analyVar.UseImages;
    
    indVarField = {'imagevcoAtom'};
    depVarField = {'sfiIntegral', 'wavemeterAtom', 'wavemeterBack'};
    
    %{
    indivBatch_header = {
        'fileAtom',...                      % 01  name of the image file
        'imagevcoAtom',...                  % 02  corresponding value of the independent parameter
        'principleQuantumAtom',...          % 03  principle quantum number n
        'angularQuantumAtom',...            % 04  principle quantum number \el
        'ODTHold',...                       % 05  odt hold time
        'RampDelay',...                     % 06  rydberg hold time for lifetime measurements
        'VCA_1_Voltage',...                 % 07  3 beam ODT vca 1 static voltage; control relatice power between 3 beams
        'VCA_2_Voltage',...                 % 08  3 beam ODT VCA 2 static voltage; control absolute power of all 3 beams
        'initialTrapDepthAtom',...          % 09  initial trap depth in volts before evaporation
        'TrapPower',...                     % 10  final trap depth in volts after evaporation
        'synthFreq',...                     % 11  synth frequency driving 640nm cat's eye aom
        'numberAtom',...                    % 12  number of atoms measured by labview
        'tempXAtom',...                     % 13  TOF x temperature measured by labview
        'tempYAtom',...                     % 14  TOF y temperature measured by labview
        'fugacityguessAtom',...             % 15  left constant
        'sigParamAtom',...                  % 16  left constant
        'sigBECParamAtom',...               % 17  left constant
        'WeightedBECPeakAtom',...           % 18  left constant
        'BECamplitudeParameterAtom',...     % 19  left constant
        'wavemeterAtom',...                 % 20  wavemeter reading
        'timestampAtom',...                 % 21  timestamp of image (YYYY.MM.DD - HH:MM:SS)
        };
    %}
    
    dac_header = {
        'Timestamp',...
        'GHz_Synth',...
        'UV_Power',...
        'Spec_Power',...
        'DigiLock_PID1_locked',...
        'AI3',...
        'AI4',...
        'AI5',...
        'AI6',...
        'AI7'
        };
    
    labview_header = {
        'numberAtom',...
        'tempXAtom',...
        'tempYAtom'
        };
    
    image_header = {
        'winTotnum',...
        'atomTempX',...
        'atomTempY'
        };
    
    % Loop over individual scans
    for scan_idx = 1:analyVar.numBasenamesAtom
        
        % Grab independent variable
        out = table(indivDataset{scan_idx}.(indVarField{1}), 'VariableNames', indVarField);
        
        % Loop through output from indivDataset
        for j = 1:length(depVarField)
            out = [out, table(indivDataset{scan_idx}.(depVarField{j}), 'VariableNames', depVarField(j))];
            %out = [out, table(indivDataset{scan_idx}.(depVarField{j}))];
        end
        
        if use_dac
            % Get dac_voltages
            for j = 1:length(dac_header)
                out = [out, table(indivDataset{scan_idx}.daq_voltages{j}, 'VariableNames', dac_header(j))];
            end
        end
        
        if use_labview
            for j = 1:length(labview_header)
                out = [out, table(indivDataset{scan_idx}.(labview_header{j}), 'VariableNames', labview_header(j))];
            end
        end
        
        if use_images
            for j = 1:length(image_header)
                out = [out, table(indivDataset{scan_idx}.(image_header{j}), 'VariableNames', image_header(j))];
            end
        end
        
        % Output file diretory
        output_file_name = strcat(analyVar.basenamevectorAtom{scan_idx},'_out.csv');
        writetable(out, strcat(output_dir,output_file_name));
        
    end
end

