function exp_out=TOF_Temperature(analyVar,indivDataset,avgDataset)
%Fit to radius equation from Mi's PhD thesis
%sigma^2(t)=sigmaInitial^2+(kB T/M)t^2

% Function to plot the spectrum of atomic number.
%
% INPUTS:
%   analyVar     - structure of all pertinent variables for the imagefit
%                  routines
%   indivDataset - Cell of structures containing all scan/batch
%                  specific data
%   winTotNum    - Total number of atoms
%   winBECNum    - Total number of atoms in condensate (if present)
%   winThrmNum   - Total number of thermal atoms (if bimodal condensate)
%
% OUTPUTS:
%   Creates plots showing the atomic number. Valid plots are total number, 
%   BEC number, total number, or lattice peak number
%
format shortEng %format numbers outputted

for basenameNum = 1:analyVar.numBasenamesAtom
    % Reference variables in structure by shorter names for convenience
    % (will not create copy in memory as long as the vectors are not modified)
    indVar    = analyVar.funcDataScale(indivDataset{basenameNum}.imagevcoAtom);
    CloudRadX = indivDataset{basenameNum}.cloudRadX(1,:);
    CloudRadY = indivDataset{basenameNum}.cloudRadY(1,:);
    
%% Plot of radius in X & Y
%%%%%%%-----------------------------------%%%%%%%%%%
    figNum = analyVar.figNum.atomSize; 
    radLabel = {'Cloud Radius [um]', 'Cloud Radius [um]'}; 
    radTitle = {'', 'X - axis', 'Y - axis'};
    default_plot(analyVar,[basenameNum analyVar.numBasenamesAtom],...
        figNum,radLabel,radTitle,analyVar.timevectorAtom,...
        repmat(indVar,1,2)',[CloudRadX; CloudRadY]);
end

%% Loop through each batch file and image
%%%%%%%-----------------------------------%%%%%%%%%%
indVarCell=cell(1,analyVar.numBasenamesAtom);
partNumCell=cell(1,analyVar.numBasenamesAtom);
CloudRadXCell=cell(1,analyVar.numBasenamesAtom);
CloudRadYCell=cell(1,analyVar.numBasenamesAtom);

for basenameNum = 1:analyVar.numBasenamesAtom
    % Reference variables in structure by shorter names for convenience
    % (will not create copy in memory as long as the vectors are not modified)
    
    indVarCell{basenameNum} = indivDataset{basenameNum}.imagevcoAtom;
    partNumCell{basenameNum} = indivDataset{basenameNum}.winTotNum;
    CloudRadXCell{basenameNum} = indivDataset{basenameNum}.cloudRadX(1,:);
    CloudRadYCell{basenameNum} = indivDataset{basenameNum}.cloudRadY(1,:);
    
    %% Spectrum of Total number 
%%%%%%%-----------------------------------%%%%%%%%%%
    figNum = analyVar.figNum.atomNum; 
    numLabel = {'Total Number'}; 
    numTitle = {};
    default_plot(analyVar,[basenameNum analyVar.numBasenamesAtom],...
        figNum,numLabel,numTitle,analyVar.timevectorAtom,...
        analyVar.funcDataScale(indVarCell{basenameNum})',sum(partNumCell{basenameNum},1));
end

%     indVarCell = indivDataset{1}.imagevcoAtom;
%     partNumCell = indivDataset{1}.winTotNum';

    %% Define Physical Functions Used in Calculations
    % coeffs has elements coeffs = [initial_population, trap_lifetime]
    kB = 1.38E-23;%Boltzmanns constant
    M86 = (86/84)*1.39E-25;%mass of strontium 84
    M84 = 1.39E-25;%mass of strontium 84
    specFit = @(coeffs,x) sqrt(coeffs(1).^2+(kB*coeffs(2)/M86)*x.^2);%input radii are in um so I..
    %account for it by scaling the temperature
    %% Initialize loop variables
    [initialradiusX, initialradiusY, temperatureX, temperatureY, temperatureAve] = deal(zeros(length(indVarCell),3));
    %% Define Plot parameters
    specFitFig = figure;
    [subPlotRows,subPlotCols] = optiSubPlotNum(length(indVarCell));

    %% Loop through each batch file or average scan value
    
for iterVar = 1:length(indVarCell)
    % Reference variables in structure by shorter names for convenience
    scaletime=1E-3;
    indVar = indVarCell{iterVar}.*scaletime;
    scaleradius=1E-6;
    radiusX= CloudRadXCell{iterVar}.*scaleradius;%in m
    radiusY= CloudRadYCell{iterVar}.*scaleradius;
    
    initRadiusX = radiusX(1);%Guess that the initial radius is close in size to the first data point
    initRadiusY = radiusY(1);%
    initTemperature = 1E-6; % Guess(1mK)
    
    % Fitting routine
    specFitModelX = NonLinearModel.fit(indVar',radiusX,specFit,[initRadiusX initTemperature],...
        'CoefficientNames',{'Initial Radius X','Temperature X'});
    specFitModelY = NonLinearModel.fit(indVar',radiusY,specFit,[initRadiusY initTemperature],...
        'CoefficientNames',{'Initial Radius Y','Temperature Y'});
    % Calculate output quantities
    % Outputs estimated value of each coefficient and the standard error (standard deviation) of
    % the estimate
    
    initialradiusX(iterVar,1:2)  = double(specFitModelX.Coefficients('Initial Radius X',{'Estimate', 'SE'}));
    initialradiusX(iterVar,3)=initialradiusX(iterVar,2)/initialradiusX(iterVar,1);%uncertainty of parameter/ parameter
        
    initialradiusY(iterVar,1:2)  = double(specFitModelY.Coefficients('Initial Radius Y',{'Estimate', 'SE'}));
    initialradiusY(iterVar,3)=initialradiusY(iterVar,2)/initialradiusY(iterVar,1);%uncertainty of parameter/ parameter
    
    temperatureX(iterVar,1:2) = double(specFitModelX.Coefficients('Temperature X',{'Estimate', 'SE'}));
    temperatureX(iterVar,3)=temperatureX(iterVar,2)/temperatureX(iterVar,1);
    
    temperatureY(iterVar,1:2) = double(specFitModelY.Coefficients('Temperature Y',{'Estimate', 'SE'}));
    temperatureY(iterVar,3)=temperatureY(iterVar,2)/temperatureY(iterVar,1);

    temperatureAve(iterVar,1) = (temperatureX(iterVar,1)+temperatureY(iterVar,1))/2;
    temperatureAve(iterVar,2) = (1/2)*sqrt(temperatureX(iterVar,2)^2+temperatureY(iterVar,2)^2);
    temperatureAve(iterVar,3) = temperatureAve(iterVar,2)/temperatureAve(iterVar,1);
    % Plot number vs. fit for inspection
    
    figure(specFitFig); subplot(subPlotRows,subPlotCols,iterVar);
    fitIndVar = linspace(min(indVar),max(indVar),1e4)';
    
% % 	lower_Coeff_amp=radius(iterVar,1)-radius(iterVar,2);
% %     upper_Coeff_amp=radius(iterVar,1)+radius(iterVar,2);
% %     
% %     lower_Coeff_life=temperature(iterVar,1)-temperature(iterVar,2);
% %     upper_Coeff_life=temperature(iterVar,1)+temperature(iterVar,2);
% %     
% %     lower=specFit([lower_Coeff_amp,lower_Coeff_life],indVar);
% %     upper=specFit([upper_Coeff_amp,upper_Coeff_life],indVar);
% %     
% %     ciplot(lower,upper,indVar,'y');
    hold on
    
    rawdataHan   = plot(indVar,[radiusX' radiusY']);
    fitdataHan   = plot(fitIndVar,[specFitModelX.predict(fitIndVar) specFitModelY.predict(fitIndVar)]);
    

    %%% Plot axis details
%     title(num2str(labelVec(iterVar)));
    xlabel('Time (s)'); grid on; axis tight
    ylabel('Cloud Radius (m)');
    set(rawdataHan,'LineStyle','none','Marker','o'); 
    set(fitdataHan,'LineWidth',2,'Color','b')
    if iterVar == length(indVarCell);
        set(gcf,'Name','Spectra Fits');
    end
    
%     %http://www.mathworks.com/help/curvefit/confidence-and-prediction-bounds.html
%     Confi_Level=0.99;
%     [exp_out,gof,output] = fit(x,y,'exp1');
%     Confi_Bound= confint(exp_out,Confi_Level);
%     Confi_Bound(:,1)
%     Confi_Bound(:,2)
%     p21 = predint(exp_out,x,Confi_Level,'functional','off');
%     semilogy(x,y','o');
%     grid on;
%     hold on;
%     plot(exp_out)
%     plot(x,p21,'m--')
%     title('Nonsimultaneous functional bounds','Color','m')
end

%      initialradiusX
%      initialradiusY
      temperatureX
      temperatureY
     temperatureAve
    

%% Pack workspace into a structure for output
% If you don't want a variable output, prefix it with lcl_
exp_out = who();
exp_out = v2struct(cat(1,'fieldNames',exp_out(cellfun('isempty',regexp(exp_out,'\<lcl_')))));
end

