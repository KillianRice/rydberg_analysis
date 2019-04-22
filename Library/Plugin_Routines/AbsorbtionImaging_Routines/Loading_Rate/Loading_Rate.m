function exp_out=Loading_Rate(analyVar,indivDataset,avgDataset)
%Fit to solution of loading rate equation of constant loading minus one
%body loss
%d_t N(t)=R-N/tau
%Solution
%N(t)=R tau (1-e^(-t/tau))

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
format shortEng
%% Loop through each batch file and image
%%%%%%%-----------------------------------%%%%%%%%%%
indVarCell=cell(1,analyVar.numBasenamesAtom);
partNumCell=cell(1,analyVar.numBasenamesAtom);

for basenameNum = 1:analyVar.numBasenamesAtom
    % Reference variables in structure by shorter names for convenience
    % (will not create copy in memory as long as the vectors are not modified)
    
    indVarCell{basenameNum} = indivDataset{basenameNum}.imagevcoAtom;
    partNumCell{basenameNum} = indivDataset{basenameNum}.winTotNum;
    
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
    
    specFit = @(coeffs,x) coeffs(1)*coeffs(2)*(1-exp(-x/coeffs(2)));
    %% Initialize loop variables
    [loading_rate, one_body_coeff saturationNum] = deal(zeros(length(indVarCell),3));
    %% Define Plot parameters
    specFitFig = figure;
    [subPlotRows,subPlotCols] = optiSubPlotNum(length(indVarCell));

    %% Loop through each batch file or average scan value
    
for iterVar = 1:length(indVarCell)
    % Reference variables in structure by shorter names for convenience
    scaletime=1E-3;
    indVar = indVarCell{iterVar}*scaletime;
    totNum = partNumCell{iterVar};

    initOneBodyLoss = indVar(end);% Guess that the lifetime is about the length of the last data point in time,
    %this assume with took data spaning a range comparable to the lifetime
    initLoadRate = totNum(end)/initOneBodyLoss; % Guess that the initial population is the first value of the data set,...
    %which is valid if the first point is taken with a small hold time in
    %the magnetic trap
    
    % Fitting routine
    specFitModel = NonLinearModel.fit(indVar',totNum,specFit,[initLoadRate initOneBodyLoss],...
        'CoefficientNames',{'Loading Rate','One Body Loss Coefficient'});

    % Calculate output quantities
    % Outputs estimated value of each coefficient and the standard error (standard deviation) of
    % the estimate
    %loading_rate(iterVar,1:2)  = double(specFitModel.Coefficients('Loading Rate',{'Estimate', 'SE'}));
    loading_rate(iterVar,1:2)  = table2array(specFitModel.Coefficients('Loading Rate',{'Estimate', 'SE'}));
    loading_rate(iterVar,3)=loading_rate(iterVar,2)/loading_rate(iterVar,1);
    one_body_coeff(iterVar,1:2) = table2array(specFitModel.Coefficients('One Body Loss Coefficient',{'Estimate', 'SE'}));
    one_body_coeff(iterVar,3)=one_body_coeff(iterVar,2)/one_body_coeff(iterVar,1);
    saturationNum(iterVar,1) = loading_rate(iterVar,1)*one_body_coeff(iterVar,1);
    saturationNum(iterVar,2) = saturationNum(iterVar,1)*sqrt((loading_rate(iterVar,2)/loading_rate(iterVar,1))^2+(one_body_coeff(iterVar,2)/one_body_coeff(iterVar,1))^2);
    saturationNum(iterVar,3)=saturationNum(iterVar,2)/saturationNum(iterVar,1);

    % Plot number vs. fit for inspection
    
    figure(specFitFig); subplot(subPlotRows,subPlotCols,iterVar);
    fitIndVar = linspace(min(indVar),max(indVar),1e4)';
    
	lower_Coeff_amp=loading_rate(iterVar,1)-loading_rate(iterVar,2);
    upper_Coeff_amp=loading_rate(iterVar,1)+loading_rate(iterVar,2);
    
    lower_Coeff_life=one_body_coeff(iterVar,1)-one_body_coeff(iterVar,2);
    upper_Coeff_life=one_body_coeff(iterVar,1)+one_body_coeff(iterVar,2);
    
    lower=specFit([lower_Coeff_amp,lower_Coeff_life],indVar);
    upper=specFit([upper_Coeff_amp,upper_Coeff_life],indVar);
    
    ciplot(lower,upper,indVar,'y');
    hold on
    
    rawdataHan   = plot(indVar,totNum);
    fitdataHan   = plot(fitIndVar,specFitModel.predict(fitIndVar));
    

    %%% Plot axis details
%     title(num2str(labelVec(iterVar)));
    xlabel('Time (ms)'); grid on; axis tight
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

    loading_rate
    one_body_coeff
    saturationNum

%% Pack workspace into a structure for output
% If you don't want a variable output, prefix it with lcl_
exp_out = who();
exp_out = v2struct(cat(1,'fieldNames',exp_out(cellfun('isempty',regexp(exp_out,'\<lcl_')))));
end

