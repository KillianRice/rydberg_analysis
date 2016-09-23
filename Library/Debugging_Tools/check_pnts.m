function check_pnts(viewCloudCut)
% Provides preliminary false color images in order to identify bad shots
% with the camera. Can also be used to identify centering positions with
% viewCloudCut.

%% Load variables and file data
analyVar     = AnalysisVariables;

if analyVar.UseImages == 0
    warning('Use images is set to false, go to analysis variables and change it in order to see the images');
end
indivDataset = get_indiv_batch_data(analyVar);

if nargin == 0 % If run without arguments
    viewCloudCut = 0; % Default value
end

%% Troubleshooting section to help identify cloud center
for basenameNum = 1:analyVar.numBasenamesAtom
    % Initialize nested loop variables
    hCloud = zeros(1,indivDataset{basenameNum}.CounterAtom);
    hCloud2 = zeros(1,indivDataset{basenameNum}.CounterAtom);
    
    for k = 1:indivDataset{basenameNum}.CounterAtom
        % Load background to clearly identify cloud center
        s = [analyVar.dataDir char(indivDataset{basenameNum}.fileAtom(k)) analyVar.dataAtom]; sFID = fopen(s,'rb','ieee-be');
        t = [analyVar.dataDir char(indivDataset{basenameNum}.fileBack(k)) analyVar.dataBack]; tFID = fopen(t,'rb','ieee-be');
        
        fullRawImageAtom = fread(sFID,analyVar.matrixSize,'*int16'); fclose(sFID);
        fullRawImageBack = fread(tFID,analyVar.matrixSize,'*int16'); fclose(tFID);
        
        % Easiest way to eliminate abberations that dominate atom image
        prelimRawAtoms = log(abs(double(fullRawImageBack))) - log(abs(double(fullRawImageAtom)));
        
        % Initialize ROI to the correct size and fill with ROI image values
        [roiCutImage,roi_Index] = deal(zeros(2*analyVar.roiWinRadAtom(basenameNum) + 1));
        
        roi_Index(:)   = indivDataset{basenameNum}.image_Index(indivDataset{basenameNum}.image_Index ~= 0);
        roiCutImage(:) = prelimRawAtoms(indivDataset{basenameNum}.image_Index ~= 0);
        
        trshtRoiCutCloud = roiCutImage;       trshtRoiCutBack = roiCutImage;
        trshtRoiCutCloud(roi_Index ~= 2) = 0; trshtRoiCutBack(roi_Index ~= 1) = 0;
        
        % X and Y pixel vector
        Xpix = (-analyVar.roiWinRadAtom(basenameNum):analyVar.roiWinRadAtom(basenameNum)) + analyVar.cloudColCntrAtom(1);
        Ypix = (-analyVar.roiWinRadAtom(basenameNum):analyVar.roiWinRadAtom(basenameNum)) + analyVar.cloudRowCntrAtom(1);
        
        % If viewCloudCut then show separate figures of cloud and ROI, else show cloud+ROI
        if viewCloudCut;
            % Cloud subplot
            if k == 1; figure(100 + basenameNum); clf; end
            set(0,'CurrentFigure',100 + basenameNum)
            hCloud(k) = subplot(indivDataset{basenameNum}.SubPlotRows,indivDataset{basenameNum}.SubPlotCols,k);
            pcolor(Ypix,Xpix,trshtRoiCutCloud);
			shading flat;
			axis equal tight;
			
            %%% Plot axis details
            title(strcat(num2str(indivDataset{basenameNum}.imagevcoAtom(k))));
            hold on; grid off; axis off
            if k == indivDataset{basenameNum}.CounterAtom;
                cLimAtom = diag(feval(@(x) [min(x);max(x)],cell2mat(get(hCloud,'CLim')))); set(hCloud,'CLim',cLimAtom)
                set(gcf,'Name',['Checking Points: Time = ' num2str(analyVar.timevectorAtom(basenameNum))]);
                mtit(['Checking Points: Time = ' num2str(analyVar.timevectorAtom(basenameNum))],'FontSize',16,'zoff',.05,'xoff',-.01)
            end
            
            % ROI subplot
            if k == 1; figure(200 + basenameNum); clf; end
            set(0,'CurrentFigure',200 + basenameNum)
            hCloud2(k) = subplot(indivDataset{basenameNum}.SubPlotRows,indivDataset{basenameNum}.SubPlotCols,k);
            pcolor(Ypix,Xpix,trshtRoiCutBack);
			shading flat;
			axis equal tight;
			
            %%% Plot axis details
            title(strcat(num2str(indivDataset{basenameNum}.imagevcoAtom(k))));
            hold on; grid off; axis off
            if k == indivDataset{basenameNum}.CounterAtom;
                set(hCloud2,'CLim',cLimAtom)
                set(gcf,'Name',['Checking Points: Time = ' num2str(analyVar.timevectorAtom(basenameNum))]);
                mtit(['Checking Points: Time = ' num2str(analyVar.timevectorAtom(basenameNum))],'FontSize',16,'zoff',.05,'xoff',-.01)
            end
        else
            % ROI + Cloud subplot
            if k == 1; figure(100 + basenameNum); clf; end
            set(0,'CurrentFigure',100 + basenameNum)
            hCloud(k) = subplot(indivDataset{basenameNum}.SubPlotRows,indivDataset{basenameNum}.SubPlotCols,k);
            pcolor(Ypix,Xpix,roiCutImage);
			shading flat;
			axis equal tight;
			
            %%% Plot axis details
            title(strcat(num2str(indivDataset{basenameNum}.imagevcoAtom(k))));
            hold on; grid off; axis off
            if k == indivDataset{basenameNum}.CounterAtom;
                cLimAtom = diag(feval(@(x) [min(x);max(x)],cell2mat(get(hCloud,'CLim')))); set(hCloud,'CLim',cLimAtom)
                set(gcf,'Name',['Checking Points: Time = ' num2str(analyVar.timevectorAtom(basenameNum))]);
                mtit(['Checking Points: Time = ' num2str(analyVar.timevectorAtom(basenameNum))],'FontSize',16,'zoff',.05,'xoff',-.01)
            end
        end
    end
end
end