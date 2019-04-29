function funcOut = SFI_fit_and_exctract(analyVar,indivDataset,avgDataset)
    form = @(coeffs,x) coeffs(1) * exp(-(x-coeffs(2)).^2 ./ (2*coeffs(3)^2))+ coeffs(4) * exp(-(x-coeffs(5)).^2 ./ (2*coeffs(6)^2)) + coeffs(7);
    function x0 = initial_guess(x, y)

    x0 = zeros(7,1);
    x0(1) = max(y);
    x0(2) = sum(x.*y)/sum(y);
    x0(3) = sqrt(sum((x-x0(2)).^2.*y)/sum(y));
    x0(4) = max(y)/5;
    x0(5) = sum(x.*y)/sum(y)+1.5*10^(-6);
    x0(6) = sqrt(sum((x-x0(5)).^2.*y)/sum(y));
    x0(7) = min(y);

end
    for i= 1:analyVar.numBasenamesAtom % loop over batches
    %for i= 1:1 % loop over batches
        indivDataset{i}.SFI_fit_1 = zeros(indivDataset{i}.CounterMCS,1); % counts the number of MCS files and initialized a 0-vector
        indivDataset{i}.SFI_fit_2 = zeros(indivDataset{i}.CounterMCS,1); % counts the number of MCS files and initialized a 0-vector
        for j = 1:indivDataset{i}.CounterMCS % loop over all the MCS files
        %for j = 1:2 % loop over all the MCS files
            x = indivDataset{i}.mcsSpectra{j}(:,1);
            y = indivDataset{i}.mcsSpectra{j}(:,2);
            initguess = initial_guess(x,y);
            % fitting the mcs file(SFI)
            coeffs{j}=lsqcurvefit(form,initguess,x,y,[],[],struct('Display','off'));
            indivDataset{i}.SFI_fit_1(j,1) = coeffs{j}(1)*sqrt(2*pi)*coeffs{j}(3);
            indivDataset{i}.SFI_fit_2(j,1) = coeffs{j}(4)*sqrt(2*pi)*coeffs{j}(6);
            % plotting to check the fit
%             fitx = linspace(min(x),max(x),1000);
%             
%             figure 
%             hold on
%             plot(x,y,...
%                  'LineStyle','-',...
%                  'MarkerSize', analyVar.markerSize,...
%                  'MarkerFaceColor', analyVar.COLORS(i,:),...
%                  'Color', analyVar.COLORS(i,:));
%             plot(fitx,form(coeffs{i},fitx),...
%                  'LineStyle','-',...
%                  'MarkerSize', analyVar.markerSize,...
%                  'MarkerFaceColor', analyVar.COLORS(i,:),...
%                  'Color', analyVar.COLORS(i,:));
%             xlabel('Time(sec)')
%             ylabel('Bin counts')
%             plot(fitx,form(initguess,fitx),...
%                  'LineStyle','--',...
%                  'MarkerSize', analyVar.markerSize,...
%                  'MarkerFaceColor', analyVar.COLORS(i,:),...
%                  'Color', analyVar.COLORS(i,:));
%             hold off
        end
    end
    funcOut.analyVar = analyVar;
    funcOut.indivDataset= indivDataset;
    funcOut.avgDataset= avgDataset;
end
            