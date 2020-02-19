function out = density(analyVar, indivDataset, avgDataset)

    omega_z = 2*pi*523.818;
    omega_r = 2*pi*128.5;
    lambda = omega_z/omega_r;
    omega_bar = (omega_z*omega_r^2)^(1/3);

    figure;
    hold on;
    for basename = 1:analyVar.numBasenamesAtom
        
        number = indivDataset{basename}.winTotNum;
        tempX = indivDataset{basename}.atomTempX;
        tempY = indivDataset{basename}.atomTempY;
        
        temp = (tempX.^2 .* tempY).^(1/3);
        
        sig = cloud_sigma(omega_bar,temp,analyVar);
        
        indivDataset{basename}.density = 1e-6 * number./temp.^(3/2) *...
            1/(2*sqrt(2)*pi^(3/2)/(analyVar.mass*omega_bar^2/analyVar.kBoltz)^(3/2));
        
        plot(indivDataset{basename}.imagevcoAtom,indivDataset{basename}.density,...
            'LineStyle','-',...
            'Marker', 'o',...
            'MarkerSize', analyVar.markerSize,...
            'MarkerFaceColor', analyVar.COLORS(basename,:),...
            'MarkerEdgeColor', 'none',...
            'Color', analyVar.COLORS(basename,:));
        if analyVar.isotope == 87        
            indivDataset{basename}.t_over_tf = t_over_tF(temp,number,lambda,omega_r,analyVar);
        end
        
    end
    
    xlabel(analyVar.xDataLabel);
    ylabel('Cloud Density (cm^{-3})');
    legend(num2str(analyVar.timevectorAtom))
    
    hold off;
    
    [x,y,yerr] = get_averages(analyVar, indivDataset, avgDataset, 'imagevcoAtom', 'density');

    
    figure;
    hold on;
    scanIDs = analyVar.uniqScanList;

    for id = 1:length(scanIDs)
        avgDataset{id}.density = y{id};
        avgDataset{id}.density_unc = yerr{id};
        avgDataset{id}.density_x = x{id};
        errorbar(x{id}, y{id}, yerr{id},...
            'LineStyle','-',...
            'Marker', 'o',...
            'MarkerSize', analyVar.markerSize,...
            'MarkerFaceColor', analyVar.COLORS(id,:),...
            'MarkerEdgeColor', 'none',...
            'Color', analyVar.COLORS(id,:));
    end
    
    xlabel(analyVar.xDataLabel);
    ylabel('Average Cloud Density (cm^{-3})');
    legend(num2str(scanIDs))
    hold off;
    
    if analyVar.isotope == 87
        figure;
        hold on;
        for i = 1:analyVar.numBasenamesAtom
            plot(indivDataset{i}.imagevcoAtom, indivDataset{i}.t_over_tf,...
                'LineStyle','-',...
                'Marker', 'o',...
                'MarkerSize', analyVar.markerSize,...
                'MarkerFaceColor', analyVar.COLORS(i,:),...
                'MarkerEdgeColor', 'none',...
                'Color', analyVar.COLORS(i,:));
        end

        xlabel(analyVar.xDataLabel);
        ylabel('T/T_F, assuming a polarized sample');
        legend(num2str(analyVar.timevectorAtom))
        hold off;

        figure;
        hold on;
        for i = 1:analyVar.numBasenamesAtom
            plot(indivDataset{i}.imagevcoAtom, indivDataset{i}.t_over_tf*10^(1/3),...
                'LineStyle','-',...
                'Marker', 'o',...
                'MarkerSize', analyVar.markerSize,...
                'MarkerFaceColor', analyVar.COLORS(i,:),...
                'MarkerEdgeColor', 'none',...
                'Color', analyVar.COLORS(i,:));
        end

        xlabel(analyVar.xDataLabel);
        ylabel('T/T_F, assuming an unpolarized sample');
        legend(num2str(analyVar.timevectorAtom))
        hold off;
    end
    
    out.analyVar = analyVar;
    out.indivDataset = indivDataset;
    out.avgDataset = avgDataset;
end

function sigma = cloud_sigma(omega, T, analyVar)

    sigma = sqrt(analyVar.kBoltz * T / (analyVar.mass * omega^2));
    
end

function t_over_tF = t_over_tF(temp, num, lambda, omega_r, analyVar)
    
    t_over_tF = temp ./ ( analyVar.hbar / analyVar.kBoltz * omega_r * (6 * lambda * num).^(1/3));
    
end