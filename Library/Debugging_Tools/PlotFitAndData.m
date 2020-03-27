function PlotFitAndData

analyVar     = AnalysisVariables;
indivDataset = get_indiv_batch_data(analyVar);

%% Loop through each batch file listed in basenamevectorAtom
for basenameNum = 1:analyVar.numBasenamesAtom
    % Initialize basename specific variables
    [evolAxH,fit2DAxH,fit1DAxH,resAxH] = deal(zeros(indivDataset{basenameNum}.CounterAtom,1));
    fitDistImage   = zeros(analyVar.funcPlotWin(basenameNum)); % 2D fitted distribution initialization
        
        % Processes all the data files in this batch
        for k = 1:indivDataset{basenameNum}.CounterAtom;
            
%% Read OD_Image_Single from file
%%%%%%%-----------------------------------%%%%%%%%%%
            OD_Image_Single = dlmread([analyVar.analyOutDir char(indivDataset{basenameNum}.fileAtom(k)) analyVar.ODimageFilename]);
            
%% Retrieve windowed image cell
%%%%%%%-----------------------------------%%%%%%%%%%   
            OD_Fit_ImageCell = cellfun(@(x) reshape(OD_Image_Single(x),[1 1]*analyVar.funcFitWin(basenameNum)),...
                cellfun(analyVar.fitWinLogicInd,indivDataset{basenameNum}.roiWin_Index,'UniformOutput',0),'UniformOutput',0);
            
%% Read fit parameters from file on disk
%%%%%%%-----------------------------------%%%%%%%%%%       
            % Read fit parameters from file
            % NOTE: the last fit number in the fit parameter file is a flag
            % showing whether weighting was enabled during the fitting routine.
            PCell = mat2cell(dlmread([analyVar.analyOutDir char(indivDataset{basenameNum}.fileBack(k)) ...
                analyVar.sampleType analyVar.fitModel analyVar.paramFitFilename ...
                analyVar.paramFitFileExt]),ones(1,sum(analyVar.LatticeAxesFit)),length(analyVar.InitCondList) + 1);
            
            % Save real fit P values to struct for convenience
            fitParams = cellfun(@(P) (cell2struct(num2cell(P(1:length(analyVar.InitCondList))),analyVar.InitCondList,2)),PCell,'UniformOutput',0);
            
            % Express fit parameters as reparameterized values to retrieve the estimated distribution
            PCell = cellfun(@(x) coeff_reparam(analyVar,x,'redefine'),PCell,'UniformOutput',0);

%% Weighting 
%%%%%%%-----------------------------------%%%%%%%%%%
            % Return a weighting cell if it was used in fitting
            errCell = cellfun(@(x,y) get_OD_weight(x(end),y),PCell,OD_Fit_ImageCell,'UniformOutput',0);

%% Calculate the estimated distribution from the specified model
%%%%%%%-----------------------------------%%%%%%%%%%
            % Generate spatial coordinates (independent variables)
            [Xgrid,Ygrid] = meshgrid(1:analyVar.funcFitWin(basenameNum));
            
            % Call fit model and return distribution
            fitDistCell = cellfun(@(x,y)(reshape(feval(str2func(analyVar.fitModel),x,[Xgrid(:) Ygrid(:) y(:)]),...
                [1 1].*analyVar.funcFitWin(basenameNum))),PCell,errCell,'UniformOutput',0);
            
%% Collect individual fit windows into single image
%%%%%%%-----------------------------------%%%%%%%%%%     
            for i = 1:sum(analyVar.LatticeAxesFit)
                fitDistImage(analyVar.fitWinLogicInd(indivDataset{basenameNum}.roiWin_Index{i})) = fitDistCell{i};
            end
        
            %% Plot Evolution
            figure(1100 + basenameNum);
            evolAxH(k) = subplot(indivDataset{basenameNum}.SubPlotRows,indivDataset{basenameNum}.SubPlotCols,k);
            pcolor((OD_Image_Single)); shading flat;
            %%% Plot axis details
            title(strcat(num2str(indivDataset{basenameNum}.imagevcoAtom(k)),' s')); hold on; grid off;
            if k == indivDataset{basenameNum}.CounterAtom;
                set(gcf,'Name',['Evolution - ' num2str(analyVar.timevectorAtom(basenameNum))]);
                mtit('Evolution','FontSize',16,'zoff',.05,'xoff',-.01)
            end

            %% Plot 2D Fit
            figure(3000 + basenameNum);
            fit2DAxH(k) = subplot(indivDataset{basenameNum}.SubPlotRows,indivDataset{basenameNum}.SubPlotCols,k);
            pcolor((fitDistImage)); shading flat;
            %%% Plot axis details
            title(strcat(num2str(indivDataset{basenameNum}.imagevcoAtom(k)),' s')); hold on; grid off;
            if k == indivDataset{basenameNum}.CounterAtom;
                set(gcf,'Name',['2D Fit  - ' num2str(analyVar.timevectorAtom(basenameNum))]);
                mtit('2D Fit','FontSize',16,'zoff',.05,'xoff',-.01)
            end

            %% Plot residuals
            figure(1000 + basenameNum);
            resAxH(k) = subplot(indivDataset{basenameNum}.SubPlotRows,indivDataset{basenameNum}.SubPlotCols,k);
            pcolor((OD_Image_Single - fitDistImage)); shading flat;
            %%% Plot axis details
            title(strcat(num2str(indivDataset{basenameNum}.imagevcoAtom(k)),' s')); hold on; grid off;
            if k == indivDataset{basenameNum}.CounterAtom;
                set(gcf,'Name',['Residuals - ' num2str(analyVar.timevectorAtom(basenameNum))]);
                mtit('Residuals','FontSize',16,'zoff',.05,'xoff',-.01)
            end

            %% Plot 1D fit against data
            figure(2000 + basenameNum);
            CloudCntr  = round((analyVar.roiWinRadAtom(basenameNum) - (fitWin - 1)/2)...
                + [fitParams{1}.xCntr fitParams{1}.yCntr]);
            OD_1D_Xdata = OD_Image_Single(:,CloudCntr(1));
            OD_1D_Ydata = OD_Image_Single(CloudCntr(2),:);
            OD_1D_Xfit  = fitDistImage(:,CloudCntr(1));
            OD_1D_Yfit  = fitDistImage(CloudCntr(2),:);
            fit1DAxH(k) = subplot(indivDataset{basenameNum}.SubPlotRows,indivDataset{basenameNum}.SubPlotCols,k);
            hold on; grid off;
            plot(OD_1D_Xdata,'c.'); plot(OD_1D_Ydata,'g.');
            plot(OD_1D_Xfit,'k'); plot(OD_1D_Yfit,'r')
            %%% Plot axis details
            title(sprintf('%gs [%g,%g]',indivDataset{basenameNum}.imagevcoAtom(k)*1e-3,CloudCntr(1),CloudCntr(2)));
            xlim([1 2*analyVar.roiWinRadAtom(basenameNum)+1]);
            ylim([-0.1 max(max([OD_1D_Xdata; OD_1D_Ydata'; OD_1D_Xfit; OD_1D_Yfit'])) + 0.1]);
            if k == indivDataset{basenameNum}.CounterAtom;
                set(gcf,'Name',['Fit - ' num2str(analyVar.timevectorAtom(basenameNum))]);
                mtit('Cross-Section of Fit','FontSize',16,'zoff',.05,'xoff',-.01)
            end
        end
    
    % Find the scales with the greatest range for all plots
    bestColorLim = diag(minmax(cell2mat(get(evolAxH,'CLim'))'));
    best1DLim    = [-0.1 max(max(cell2mat(get(fit1DAxH,'YLim'))))];
    
    set(evolAxH,'CLim', bestColorLim)  % apply color lim to evolution
    set(fit2DAxH,'CLim', bestColorLim) % apply color lim to fit2D
    set(resAxH,'CLim', bestColorLim)   % apply color lim to residuals
    set(fit1DAxH,'YLim',best1DLim)     % apply y range to fit1D
end