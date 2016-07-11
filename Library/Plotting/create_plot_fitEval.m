function [fit2DAxH, fit1DAxH, resAxH, fitBEC1DAxH] = create_plot_fitEval(analyVar,indivDataset)
% Function to retrieve the fit number distribution and plot 2D false color
% images of the fit, 2D residuals, and 1D cross-sections through the cloud
% center to compare data and fit directly.
%
% INPUTS:
%   analyVar     - structure of all pertinent variables for the imagefit
%                  routines
%   indivDataset - Cell of structures containing all scan/batch
%                  specific data
%
% OUTPUTS:
%   fit2DAxH, fit1DAxH, resAxH - Cell of vectors containing handles to the subplot axes. 
%                                Used for setting standard color limits on pcolor plots.
%

%% Initilalize local variables
% Base figure number for like plots (actual figure is figX + basenameNum)
figStruct.fig2DFit = analyVar.figNum.fig2DFit;
figStruct.figRes   = analyVar.figNum.figRes; 
figStruct.fig1DFit = analyVar.figNum.fig1DFit; 
figStruct.fig1DBEC = analyVar.figNum.fig1DBEC;
% Create figure windows so that they are grouped together for easier
% viewing when analyzing multiple scans
figBase = fieldnames(figStruct);
for figIter = 1:length(figBase)
    arrayfun(@(x) figure(figStruct.(figBase{figIter}) + x),1:analyVar.numBasenamesAtom)
end

%% Preallocate loop variables
[fit2DAxH, fit1DAxH, resAxH, fitBEC1DAxH] = deal(cell(1,analyVar.numBasenamesAtom));

%% Loop through each batch file listed in basenamevectorAtom
for basenameNum = 1:analyVar.numBasenamesAtom

    %% Preallocate loop variables
    [fit2DAxH{basenameNum}, fit1DAxH{basenameNum},...
       resAxH{basenameNum}, fitBEC1DAxH{basenameNum}]...
        = deal(zeros(1,indivDataset{basenameNum}.CounterAtom));

    % Processes all the image files in the current batch
    for k = 1:indivDataset{basenameNum}.CounterAtom;
        %% Preallocate loop variables
        % 2D fitted distribution
        % Image containing all fit windows
        [roiDistImage, fitBECDistImage, fitThrmDistImage]...
            = deal(zeros(analyVar.funcPlotWin(basenameNum)));
        
%% Smooth OD images to eliminate some noise fluctuations
%%%%%%%-----------------------------------%%%%%%%%%%
        OD_Smooth = analyVar.smoothFilt(indivDataset{basenameNum}.All_OD_Image{k},analyVar.smoothFiltMat);

%% Retrieve windowed image cell
%%%%%%%-----------------------------------%%%%%%%%%%   
        OD_Fit_ImageCell = cellfun(@(x) reshape(indivDataset{basenameNum}.All_OD_Image{k}(x),[1 1]*analyVar.funcFitWin(basenameNum)),...
            cellfun(analyVar.fitWinLogicInd,indivDataset{basenameNum}.roiWin_Index,'UniformOutput',0),'UniformOutput',0);

%% Retrieve fit coefficients          
%%%%%%%-----------------------------------%%%%%%%%%%   
        PCell = indivDataset{basenameNum}.All_PCell{k};

%% Weighting (to use fitModel function correctly)
%%%%%%%-----------------------------------%%%%%%%%%%
        % Return a weighting cell if it was used in fitting
        errCell = cellfun(@(x,y) get_OD_weight(x(end),y),PCell,OD_Fit_ImageCell,'UniformOutput',0);

%% Calculate the estimated distribution from the specified model
%%%%%%%-----------------------------------%%%%%%%%%%
        % Generate spatial coordinates (independent variables)
        [Xgrid,Ygrid] = meshgrid(1:analyVar.funcFitWin(basenameNum));

        % Call fit model and return distribution
        fitDistCell = cellfun(@(x,y)(reshape(feval(str2func(analyVar.fitModel),x(1:length(analyVar.InitCondList)),...
            [Xgrid(:) Ygrid(:) y(:)]), [1 1].*analyVar.funcFitWin(basenameNum))),PCell,errCell,'UniformOutput',0);

%% Collect individual fit windows into single image
%%%%%%%-----------------------------------%%%%%%%%%%
        % Since the fit window is only a subsection of the entire plotting
        % window (ROI) we must find the fit window within the ROI and
        % assign the values manually

        for i = 1:sum(analyVar.LatticeAxesFit)
            % Temporary variable assignment
            roiDistTmp = indivDataset{basenameNum}.roiWin_Index{i};
            
            % Index the pnts in the ROI window that define the fit window and assign the fit values
            roiDistTmp(analyVar.fitWinLogicInd(roiDistTmp)) = fitDistCell{i};
            
            % Sum all cloud images (fit windows) together
            roiDistImage = roiDistImage + roiDistTmp;
        end

%% Plot 2D Fit of entire cloud
%%%%%%%-----------------------------------%%%%%%%%%%   
        % Set current figure to draw to (don't use figure(), significantly slower)
        set(0,'CurrentFigure',figStruct.fig2DFit + basenameNum)
        fit2DAxH{basenameNum}(k) = subplot(indivDataset{basenameNum}.SubPlotRows,indivDataset{basenameNum}.SubPlotCols,k);
        pcolor((roiDistImage)); shading flat;
        %%% Plot axis details
        title(strcat(num2str(indivDataset{basenameNum}.imagevcoAtom(k)),[' ' analyVar.xDataUnit])); hold on; grid off;
        if k == indivDataset{basenameNum}.CounterAtom;
            set(gcf,'Name',['2D Cloud Fit: Time = ' num2str(analyVar.timevectorAtom(basenameNum))]);
            mtit(['2D Cloud Fit: Time = ' num2str(analyVar.timevectorAtom(basenameNum))],'FontSize',16,'zoff',.025,'xoff',-.01)
        end

%% Plot residuals
%%%%%%%-----------------------------------%%%%%%%%%%   
        set(0,'CurrentFigure',figStruct.figRes + basenameNum)
        resAxH{basenameNum}(k) = subplot(indivDataset{basenameNum}.SubPlotRows,indivDataset{basenameNum}.SubPlotCols,k);
        pcolor((indivDataset{basenameNum}.All_OD_Image{k} - roiDistImage)); shading flat;
        %%% Plot axis details
        title(strcat(num2str(indivDataset{basenameNum}.imagevcoAtom(k)),[' ' analyVar.xDataUnit])); hold on; grid off;
        if k == indivDataset{basenameNum}.CounterAtom;
            set(gcf,'Name',['Residuals: Time = ' num2str(analyVar.timevectorAtom(basenameNum))]);
            mtit(['Residuals: Time = ' num2str(analyVar.timevectorAtom(basenameNum))],'FontSize',16,'zoff',.025,'xoff',-.01)
        end

%% Plot 1D fit against data of entire cloud
%%%%%%%-----------------------------------%%%%%%%%%%   
        set(0,'CurrentFigure',figStruct.fig1DFit + basenameNum)
        % Find center through image
        CloudCntr  = round((analyVar.roiWinRadAtom(basenameNum) - (analyVar.funcFitWin(basenameNum) - 1)/2)...
            + [indivDataset{basenameNum}.All_fitParams{k}{1}.xCntr indivDataset{basenameNum}.All_fitParams{k}{1}.yCntr]);

        % Take cross sections at center of data and fit
        OD_1D_Xdata = OD_Smooth(:,CloudCntr(1));
        OD_1D_Ydata = OD_Smooth(CloudCntr(2),:);
        OD_1D_Xfit  = roiDistImage(:,CloudCntr(1));
        OD_1D_Yfit  = roiDistImage(CloudCntr(2),:);
        % Setup subplot axes
        fit1DAxH{basenameNum}(k) = subplot(indivDataset{basenameNum}.SubPlotRows,indivDataset{basenameNum}.SubPlotCols,k);
        hold on; grid off;
        plot(OD_1D_Xdata,'c.'); plot(OD_1D_Ydata,'g.');
        plot(OD_1D_Xfit,'k');   plot(OD_1D_Yfit,'r')
        % Plot axes details
        title(sprintf('%g%s [%g,%g]',indivDataset{basenameNum}.imagevcoAtom(k),analyVar.xDataUnit,CloudCntr(1),CloudCntr(2)));
        xlim(mean(CloudCntr) + [-1 1]*analyVar.roiWinRadAtom(basenameNum));
        ylim([-0.1 max(max([OD_1D_Xdata; OD_1D_Ydata'; OD_1D_Xfit; OD_1D_Yfit'])) + 0.1]);
        if k == indivDataset{basenameNum}.CounterAtom;
            legend('y','x')
            set(gcf,'Name',['1D Fit: Time = ' num2str(analyVar.timevectorAtom(basenameNum))]);
            mtit(['Cross-Section of Fit using ' strrep(analyVar.fitModel,analyVar.InitCase,[analyVar.InitCase ' ']),...
                ': Time = ' num2str(analyVar.timevectorAtom(basenameNum))],'FontSize',16,'zoff',.025,'xoff',-.01)
        end

%% Plot 1D fit against data of condensate (if Bimodal)
%%%%%%%-----------------------------------%%%%%%%%%%
        if strcmpi(analyVar.InitCase,'Bimodal') % Same steps as above
            for i = 1:sum(analyVar.LatticeAxesFit)
                % Find position of BEC and center parameters in PCell
                paramCondPos = cellfun(@(x) ~isempty(x),regexp(analyVar.InitCondList,'\>*_BEC'));
                paramCntrPos = cellfun(@(x) ~isempty(x),regexp(analyVar.InitCondList,'\>*Cntr'));

                % Create vectors of coefficients to separate condensate and thermal portions
                [BECparams, ThrmParams] = deal(zeros(1,length(analyVar.InitCondList)));
                % Note that for Thomas-Fermi distribution putting zeros in for the BEC part creates NaN's so
                % instead using eps
                BECparams(:) = eps; ThrmParams(:) = eps;
                % Replace coefficients for each part of the distribution
                BECparams(logical(paramCondPos + paramCntrPos)) = PCell{i}(logical(paramCondPos + paramCntrPos));
                ThrmParams(logical(~paramCondPos)) = PCell{i}(logical(~paramCondPos));

                % Find just the condensate part of bimodal distribution
                fitBECDist = reshape(feval(str2func(analyVar.fitModel),BECparams,...
                    [Xgrid(:) Ygrid(:) errCell{i}(:)]),[1 1].*analyVar.funcFitWin(basenameNum));
                % Find just the thermal part of the bimodal distribution
                fitThrmDist = reshape(feval(str2func(analyVar.fitModel),ThrmParams,...
                    [Xgrid(:) Ygrid(:) errCell{i}(:)]),[1 1].*analyVar.funcFitWin(basenameNum));

            % Aggregate into single image
                fitBECDistImage(analyVar.fitWinLogicInd(indivDataset{basenameNum}.roiWin_Index{i}))  = fitBECDist;
                fitThrmDistImage(analyVar.fitWinLogicInd(indivDataset{basenameNum}.roiWin_Index{i})) = fitThrmDist;
            end

            % Remove fitted contribution due to thermal part from data
            BEC_OD_Image = analyVar.smoothFilt(indivDataset{basenameNum}.All_OD_Image{k} - fitThrmDistImage,analyVar.smoothFiltMat);

            set(0,'CurrentFigure',figStruct.fig1DBEC + basenameNum) 
            % Take cross sections at center of data and fit
            BEC_1D_Xdata = BEC_OD_Image(:,CloudCntr(1));
            BEC_1D_Ydata = BEC_OD_Image(CloudCntr(2),:);
            BEC_1D_Xfit  = fitBECDistImage(:,CloudCntr(1));
            BEC_1D_Yfit  = fitBECDistImage(CloudCntr(2),:);
            % Setup subplot axes
            fitBEC1DAxH{basenameNum}(k) = subplot(indivDataset{basenameNum}.SubPlotRows,indivDataset{basenameNum}.SubPlotCols,k);
            hold on; grid on;
            plot(BEC_1D_Xdata,'c.','MarkerSize',analyVar.markerSize); plot(BEC_1D_Ydata + analyVar.condOffset,'g.','MarkerSize',analyVar.markerSize);
            plot(BEC_1D_Xfit,'k','MarkerSize',analyVar.markerSize);   plot(BEC_1D_Yfit + analyVar.condOffset,'r','MarkerSize',analyVar.markerSize)
            % Plot axes details
            title(sprintf('%g%s [%g,%g]',indivDataset{basenameNum}.imagevcoAtom(k),analyVar.xDataUnit,CloudCntr(1),CloudCntr(2)));
            xlim(mean(CloudCntr) + [-1 1]*analyVar.roiWinRadAtom(basenameNum));
            ylim([-0.1 max(max([BEC_1D_Xdata; (BEC_1D_Ydata + analyVar.condOffset)';...
                BEC_1D_Xfit; (BEC_1D_Yfit + analyVar.condOffset)'])) + 0.1]);
            if k == indivDataset{basenameNum}.CounterAtom;
                legend('x','y')
                set(gcf,'Name',['1D Condensate Fit: Time = ' num2str(analyVar.timevectorAtom(basenameNum))]);
                mtit(['Cross-Section of Condensate Fit: Time = ' num2str(analyVar.timevectorAtom(basenameNum))],...
                    'FontSize',16,'zoff',.025,'xoff',-.01)
            end
        else
            % Close figure window if not used
            if k == 1; close(figStruct.fig1DBEC + basenameNum); end
        end
    end
end