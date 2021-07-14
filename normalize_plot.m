function funcOut = normalize_plot(analyVar, indivDataset, avgDataset)
    %%% normalize_plot.m - Soumya K. Kanungo 2021.02.03
    %%% Make a plot of the normalized sfiIntegral depending on if the line
    %%% is atomic line, dimer line, trimer line or tetramer line. The
    %%% function takes the average dataset based on the flags in the batch
    %%% file.
    %%% norm(atomic line) = numberAtom*UV_Power*Spec_Power/Detuning^2
    %%% norm(dimer line) =
    %%% numberAtom^2*UV_Power*Spec_Power/Detuning^2/Temp^(3/2)
    %%% norm(trimer line) =
    %%% numberAtom^3*UV_Power*Spec_Power/Detuning^2/Temp^(3)
    
    indVarField = 'imagevcoAtom'; % The Field of an IndivDataset that is to be plotted on the X axis
    depVarField = 'sfiIntegral'; % The field of an indivdataset that is to be plotted on the y axis
    species = 2; % choose what species is being normalized: atom, dimer or trimer.
    weighting = 'gaussian';
    if species == 1
        disp('normalizing for Rydberg atom ')
    end
    if species == 2
        disp('Normalizing for Rydberg dimer')   
    end
    if species == 3
        disp('Normalizing for Rydberg trimer')   
    end
    [xavg, yavg, yavgerr] = get_averages(analyVar, indivDataset, avgDataset,...
            indVarField, depVarField, weighting);
    [uv,~,red,~] = get_daq_averages(analyVar, indivDataset);
    [num, ~, tx, ~, ty, ~] = get_num_temp_averages(analyVar, indivDataset);
    
    scanIDs = analyVar.uniqScanList;
    %disp(uv)
    %disp(red)
    figure;
    hold on;
    xlim([-0.25,0.25]);
    for id = 1:length(scanIDs)
        [maxvalue,offset] = max(yavg{id});
        avgtemp = (tx(id)*tx(id)*ty(id))^(1/3);
        if species ==1
            errorbar(xavg{id}-xavg{id}(offset), yavg{id}/uv(id)/red(id)/num(id), yavgerr{id}/uv(id)/red(id)/num(id),...
                'LineStyle','-',...
                'Marker', 'o',...
                'MarkerSize', analyVar.markerSize,...
                'MarkerFaceColor', analyVar.COLORS(id,:),...
                'MarkerEdgeColor', 'none',...
                'Color', analyVar.COLORS(id,:));
            title('Num.,UV,red power normalized avg plots')
            xlabel('GHz_synth [MHz]')
            ylabel('Normalized Signal [arb.]')
            %legend(num2str(scanIDs(id)))
        end
        if species ==2
            qnum = scanIDs(id);
            disp('ScanIDs are taken as principal quantum numbers to normalize for FC overlap.'); 
            UVDAQoffset = 0.0144; % check the OneNote Calibration
            FCexponent = 3.7;
            y_processed = yavg{id}*avgtemp^(3/2)/(uv(id)+UVDAQoffset)/red(id)/num(id)^2/(qnum-3.371).^FCexponent;
            y_processed_err = yavgerr{id}*avgtemp^(3/2)/(uv(id)+UVDAQoffset)/red(id)/num(id)^2/(qnum-3.371)^FCexponent;
            errorbar(xavg{id}-xavg{id}(offset), y_processed,y_processed_err,...
                'LineStyle','-',...
                'Marker', 'o',...
                'MarkerSize', analyVar.markerSize,...
                'MarkerFaceColor', analyVar.COLORS(id,:),...
                'MarkerEdgeColor', 'none',...
                'Color', analyVar.COLORS(id,:));
            title('Num.,Temp.,UV,red power normalized avg plots')
            xlabel('GHz_synth [MHz]')
            ylabel('Normalized Signal [arb.]')
            string = ['FC exponent used = ', num2str(FCexponent)];
            annotation('textbox',[0.15,0.8,0.3,0.1],'String', string);
            %legend(num2str(scanIDs(id)))
        end
        if species ==3
            errorbar(xavg{id}-xavg{id}(offset), yavg{id}*avgtemp^(3)/uv(id)/red(id)/num(id)^3, yavgerr{id}*avgtemp^(3)/uv(id)/red(id)/num(id)^3,...
                'LineStyle','-',...
                'Marker', 'o',...
                'MarkerSize', analyVar.markerSize,...
                'MarkerFaceColor', analyVar.COLORS(id,:),...
                'MarkerEdgeColor', 'none',...
                'Color', analyVar.COLORS(id,:));
            title('Num.,Temp.,UV,red power normalized avg plots')
            xlabel('GHz_synth [MHz]')
            ylabel('Normalized Signal [arb.]')
            %legend(num2str(scanIDs(id)))
        end
    end
    hold off;
    legend(num2str(scanIDs))
    funcOut.analyVar = analyVar;
    funcOut.indivDataset = indivDataset;
    funcOut.avgDataset = avgDataset;
end    