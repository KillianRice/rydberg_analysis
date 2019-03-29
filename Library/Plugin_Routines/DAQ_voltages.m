function funcOut = DAQ_voltages(analyVar, indivDataset, avgDataset)

    numchannels = 8;
    
    time_axis = 1; % if 1 plots against time axis, else plots against imagevcoatom

    use_channels = [1 1 1 1 0 0 0 0]; % which channels to plot
    
    channel_names = {'UV PD Mon (V)',...        % AI 0
                    'Red Spec Power Mon (V)',...% AI 1
                    'DigiLock_DIO',...          % AI 2
                    'Lin_Spec',...              % AI 3
                    '',...                      % AI 4
                    '',...                      % AI 5
                    '',...                      % AI 6
                    '',...                      % AI 7
                    };
    
    daq_line_format = '%{yyyy.MM.dd-HH:mm:ss}D%f%f%f%f%f%f%f%f%f';
    
    legend_logic = zeros(size(analyVar.basenamevectorAtom));
                
    for i = 1:analyVar.numBasenamesAtom
        
        daq_file = [analyVar.dataDir char(analyVar.basenamevectorAtom{i}) '_daq_voltages.dat'];
        
        if exist(daq_file, 'file') == 2
            df = fopen(daq_file);
            indivDataset{i}.daq_voltages = textscan(df, daq_line_format, 'headerLines',1);
            legend_logic(i) = 1;
        else
            disp(strcat(analyVar.basenamevectorAtom{i}, ' daq file not found.'));
            indivDataset{i}.daq_voltages = {};
        end
        
    end
    
    for i = 1:numchannels
        if use_channels(i) == 1
            figure
            hold on;
            for j = 1:analyVar.numBasenamesAtom
                if ~isempty(indivDataset{j}.daq_voltages)
                    if time_axis == 1
                        myplot(indivDataset{j}.daq_voltages{1},...
                            indivDataset{j}.daq_voltages{i+2},analyVar,j);
                    else
                        myplot(indivDataset{j}.imagevcoAtom,indivDataset{j}{i+2},analyVar,j);
                    end
                end
            end
            if time_axis == 1
                xlabel('Timestamp');
            else
                xlabel(analyVar.xDataLabel, 'Interpreter', 'none');
            end
            if ~strcmp(channel_names{i},'')
                ylabel(channel_names{i}, 'Interpreter', 'none')
            else
                ylabel(strcat('DAQ Voltage Channel', num2str(i), ' (V)'), 'Interpreter', 'none');
            end
            legend(num2str(analyVar.timevectorAtom(legend_logic>0)), 'Interpreter', 'none');
        end
    end



    funcOut.analyVar = analyVar;
    funcOut.indivDataset = indivDataset;
    funcOut.avgDataset = avgDataset;

end

    function h = myplot(x,y,analyVar,i)
    h = plot(x,y,...
                'LineStyle','-',...
                'Marker', 'o',...
                'MarkerSize', analyVar.markerSize,...
                'MarkerFaceColor', analyVar.COLORS(i,:),...
                'MarkerEdgeColor', 'none',...
                'Color', analyVar.COLORS(i,:));
end