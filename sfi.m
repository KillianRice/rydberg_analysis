function [ output_args ] = sfi( analyVar, indivDataset )

    close all
    timebin = 2;
    normalize = false;
    plotcentroid = true;
    
    for i=1:timebin:20
        
        cumSFI = zeros(size(indivDataset{1}.mcsSpectra{1}));
        cumSFI(:,1) = indivDataset{1}.mcsSpectra{1}(:,1);
        for j = 1:analyVar.numBasenamesAtom
            
            for k = 0:timebin-1
                
                cumSFI(:,2) = cumSFI(:,2) + indivDataset{j}.mcsSpectra{i+k}(:,2);
                
            end
            
        end
        
        if normalize
            cumSFI(:,2) = cumSFI(:,2) / sum(cumSFI(:,2));
        end
        
        figure
        hold on
        plot(cumSFI(:,1), cumSFI(:,2),'-o');
        title(strcat('Times ',num2str(i:i+timebin-1)));
        xlim([0,20e-6]);
        ylim([0,15]);
        
        if plotcentroid
        
            centroid = sum(cumSFI(:,1).*cumSFI(:,2))/sum(cumSFI(:,2));
            plot([centroid, centroid],[0,15],'-');
            dim = [0.6,0.6,0.2,0.2];
            str = strcat('Centroid: ', num2str(centroid, '%.2e'));
        
            an = annotation('textbox', dim, 'String', str,...
            'FitBoxToText', 'on', 'BackgroundColor', 'white');
        
        end
        
        
        hold off
        
    end
    


end

