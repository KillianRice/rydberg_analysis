function exp_out=Exponential_Fit(analyVar,indivDataset,avgDataset)
%Function to fit exponential to Atom Number Plots; for example, fit to find
%lifetime of magnetic trap.
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

%% Loop through each batch file and image
%%%%%%%-----------------------------------%%%%%%%%%%
indVarCell=cell(1,analyVar.numBasenamesAtom);
partNumCell=cell(1,analyVar.numBasenamesAtom);

for basenameNum = 1:analyVar.numBasenamesAtom
    % Reference variables in structure by shorter names for convenience
    % (will not create copy in memory as long as the vectors are not modified)
    
    indVarCell{basenameNum} = indivDataset{basenameNum}.imagevcoAtom;
    partNumCell{basenameNum} = indivDataset{basenameNum}.winTotNum;
    
    logpartNumCell{basenameNum}=log(partNumCell{basenameNum});
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

%% Spectrum of Total number 
%%%%%%%-----------------------------------%%%%%%%%%%
    %figNum = analyVar.figNum.atomNum;

    %default_plot(analyVar,[basenameNum analyVar.numBasenamesAtom],...
    %   figNum,numLabel,numTitle,analyVar.timevectorAtom,...
    %    analyVar.funcDataScale(indVar)',sum(winTotNum,1));
    
    %% Define Physical Functions Used in Calculations
    % coeffs has elements coeffs = [initial_population, trap_lifetime]
    specFit = @(coeffs,x) coeffs(1)*exp(-x/coeffs(2));
    
    %% Initialize loop variables
    [amplitude, lifetime] = deal(zeros(length(indVarCell),2));
   
    %% Define Plot parameters
    specFitFig = figure;
    [subPlotRows,subPlotCols] = optiSubPlotNum(length(indVarCell));

    %% Loop through each batch file or average scan value
    numtraces =size(indVarCell,2);
    
for iterVar = 1:length(indVarCell)
    % Reference variables in structure by shorter names for convenience
    indVar = indVarCell{iterVar};
    totNum = partNumCell{iterVar};

    % Initial Guesses
%     smoothNum = smooth(totNum,'sgolay',1); % smooth for helping make guesses
%     [minVal, minLoc] = min(smoothNum); % find location of minimum
%     
%     initOffset = mean(totNum([1:5 end-5 end])); % Mean of first 5 and last 5 points
%     initCenter = indVar(minLoc);                % Location of minimum in smoothed data
%     initWidth  = 0.05*1e6;                       % Fixed since guess is not sensitive
%     initAmp    = (initOffset - minVal);         % Value below guessed offset
    
    initNum = totNum(1); % Guess that the initial population is the first value of the data set,...
    %which is valid if the first point is taken with a small hold time in
    %the magnetic trap
    initLifetime = indVar(end);% Guess that the lifetime is about the length of the last data point in time,
    %this assume with took data spaning a range comparable to the lifetime
    
    % Fitting routine
    specFitModel = NonLinearModel.fit(indVar',totNum,specFit,[initNum initLifetime],...
        'CoefficientNames',{'Initial Atom Number','Trap Lifetime'});

    % Calculate output quantities
    % Outputs estimated value of each coefficient and the standard error (standard deviation) of
    % the estimate
    amplitude(iterVar,:)  = double(specFitModel.Coefficients('Initial Atom Number',{'Estimate', 'SE'}));
    lifetime(iterVar,:) = double(specFitModel.Coefficients('Trap Lifetime',{'Estimate', 'SE'}));
     
%     fullWidth(iterVar,1)  = fullwidthFunc(double(specFitModel.Coefficients('Halfwidth','Estimate')));
%     fullWidth(iterVar,2)  = fullwidthFunc(double(specFitModel.Coefficients('Halfwidth','SE')));
    
    % Plot number vs. fit for inspection
    
    figure(specFitFig); subplot(subPlotRows,subPlotCols,iterVar);
    fitIndVar = linspace(min(indVar),max(indVar),1e4)';
    
	lower_Coeff_amp=amplitude(iterVar,1)-amplitude(iterVar,2);
    upper_Coeff_amp=amplitude(iterVar,1)+amplitude(iterVar,2);
    
    lower_Coeff_life=lifetime(iterVar,1)-lifetime(iterVar,2);
    upper_Coeff_life=lifetime(iterVar,1)+lifetime(iterVar,2);
    
    lower=specFit([lower_Coeff_amp,lower_Coeff_life],indVar);
    upper=specFit([upper_Coeff_amp,upper_Coeff_life],indVar);
    
    ciplot(lower,upper,indVar,'y');
    hold on
    
    rawdataHan   = plot(indVar,totNum);
    fitdataHan   = plot(fitIndVar,specFitModel.predict(fitIndVar));
    

    %%% Plot axis details
%     title(num2str(labelVec(iterVar)));
    xlabel('MHz'); grid on; axis tight
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
amplitude
lifetime
%% Pack workspace into a structure for output
% If you don't want a variable output, prefix it with lcl_
exp_out = who();
exp_out = v2struct(cat(1,'fieldNames',exp_out(cellfun('isempty',regexp(exp_out,'\<lcl_')))));
end

