function [ indivDataset ] = PeakDensity2( analyVar, indivDataset)

%% Fitting Flags
% 0 - No Fitting
% 1 - Constant Value
% 2 - Exponential Decay
% 3 - Exponential Loading Rate
% 4 - Gaussian
% 5 - Lorentzian

AtomNumFit_Flag = 1;
TempFit_Flag    = 1;
DensityFit_Flag = AtomNumFit_Flag;
SpacingFit_Flag = AtomNumFit_Flag;
BECSize_Flag    = AtomNumFit_Flag;
VolRatioFit_Flag = AtomNumFit_Flag;

%% XLabel Strings
xCase = 2; % 1 for spectrum, 2 for density calibration

switch xCase
    case 1
        xString = {'UV Detuning (MHz)'};
        convertFreqFlag = 1;    
    case 2
        xString = {'Num Loop Sets'};       
        convertFreqFlag = 0;

end

%% Color array
colors = FrancyColors2(-1);

NumDataSets = analyVar.numBasenamesAtom;

%% Flag Display Error Bars
% if there are more than 1 data sets, use standard deviation of the
% distributions as the uncertainty
if NumDataSets == 1
    error_flag = 0;
elseif NumDataSets > 1
    error_flag = 1;
end

%% Independant Variable
% use independant variable of experiment
xCell = cell(1,NumDataSets);
for mbIndex = 1:NumDataSets
    xCell{mbIndex}          = indivDataset{mbIndex}.imagevcoAtom;
end

[xData, ~, ~] = AggregateData(xCell, xCell);

%% Convert Independant variable
% if the flag is 1, convert assuming xData came in as synth frequency units
% and will now be UV frequency units.
if convertFreqFlag == 1
    AtomicFreq = analyVar.atomic_LineCenter;
    FreqConversion = analyVar.FreqConversion; %unitless, unit of UV freq per unit of Synth Freq.
    xData = -FreqConversion.*(xData - AtomicFreq);
end

fit_xData = linspace( min(xData) , max(xData), 1e4)'; 

%% Atom Number
    %% Aggregate Atom Number
    [yCell_AtomNum] = deal(cell(1,NumDataSets));
    for mbIndex = 1:NumDataSets
        yCell_AtomNum{mbIndex}  = indivDataset{mbIndex}.winTotNum;
    end

    [~, Ave_AtomNum, Ave_AtomNum_error] = AggregateData(xCell, yCell_AtomNum);

    %% Plot Atom Number Data
    [ Ave_AtomNum0, Ave_AtomNum0_order ] = EngineeringForm( Ave_AtomNum );
    Ave_AtomNum_error0 = Ave_AtomNum_error/10^Ave_AtomNum0_order;      

    PlotStruct_AtomNum.xData = xData;
    PlotStruct_AtomNum.yData = {Ave_AtomNum0};
    PlotStruct_AtomNum.yData_error = {Ave_AtomNum_error0};
    PlotStruct_AtomNum.hXLabel = xString;
    PlotStruct_AtomNum.hYLabel = {['Atom Number (10^' sprintf('%0.0f', Ave_AtomNum0_order) ')']};
    PlotStruct_AtomNum.colors = colors(1:6,:);
    PlotStruct_AtomNum.colors2 = colors(7:12,:);
    PlotStruct_AtomNum.FCaxisfontsize = analyVar.FCaxisfontsize;
    PlotStruct_AtomNum.FCfigPos     = analyVar.FCfigPos;
    PlotStruct_AtomNum.FCmarkerSize = analyVar.FCmarkerSize;
    PlotStruct_AtomNum.FCaxesPos    = analyVar.FCaxesPos;
    FC_Plotter(PlotStruct_AtomNum);

    %% Fit Atom Number
    switch AtomNumFit_Flag

        case 1
            %% Fit Atom Number to Constant Value
            [AtomNum0, AtomNumFitRoutine] = Constant_Value_Fit( xData, Ave_AtomNum0, Ave_AtomNum_error0, 0 );           
            fitAtomNum_yData = AtomNumFitRoutine.predict(fit_xData);    
            
            %% Display Fitting Results            
            disp(VariableName(AtomNum0))
            disp(AtomNum0)            
            
            %% Add Fitting Parameters Text Box 
            [ AtomNum_String{1},  AtomNum_String{2}] = Concise_Notation( AtomNum0(1), AtomNum0(2), 1);
            AtomNum_String{3} = sprintf('%0.0f', Ave_AtomNum0_order);            
            string = [...
                {['$$N=' AtomNum_String{1} '(' AtomNum_String{2} ')\times 10^' AtomNum_String{3} '$$']}...    
                ];    
            hText1   = text(0,0, string ,'Interpreter','latex');
            set(hText1,...
                'Units', 'Normalized',...
                'BackgroundColor', 'white',...
                'EdgeColor', 'black',...
                'Position', [.03, .22],...
                'FontSize', analyVar.FClatexfontsize)   
       
        case 2
            %% Make YScale to be Log
            set(gca,... 
                'YTick'         , [0.1:0.1:0.9 1:9 10:10:100],...
                'YScale'        , 'log');
            
            %% Fit Atom Number to Exponential Decay
            [AtomNum0, AtomDecay, ~, AtomNumFitRoutine] = Exponential_Decay_Fit2(xData, Ave_AtomNum0, Ave_AtomNum_error0, error_flag, 1);  
            fitAtomNum_yData = AtomNumFitRoutine.predict(fit_xData);  
            AtomLifetime(1) = AtomDecay(1)^-1;
            AtomLifetime(2) = AtomDecay(2)*AtomDecay(1)^-2;
            
            %% Display Fitting Results
            disp(VariableName(AtomNum0))
            disp(AtomNum0)  
            disp(VariableName(AtomLifetime))
            disp(AtomLifetime)            
            
            %% Add Fitting Parameters Text Box                
            [ AtomNum_String{1},  AtomNum_String{2}] = Concise_Notation( AtomNum0(1), AtomNum0(2), 1);
            AtomNum_String{3} = sprintf('%0.0f', Ave_AtomNum0_order);            
            [ AtomLifetime_String{1},  AtomLifetime_String{2}] = Concise_Notation( AtomLifetime(1), AtomLifetime(2), 1);                      
            string = [{'$$N~=N_0~\textup{exp}(-t/\tau)$$'},...
                {['$$N_0=' AtomNum_String{1} '(' AtomNum_String{2} ')\times 10^' AtomNum_String{3} '$$']}... 
                {['$$\tau~~=' AtomLifetime_String{1} '(' AtomLifetime_String{2} ')$$']}...    
                ];
            hText1   = text(0,0, string ,'Interpreter','latex');
            set(hText1,...
                'Units', 'Normalized',...
                'BackgroundColor', 'white',...
                'EdgeColor', 'black',...
                'Position', [.03, .22],...
                'FontSize', analyVar.FClatexfontsize)       
    end
            if AtomNumFit_Flag ~= 0
                plot(fit_xData, fitAtomNum_yData, 'Color', FrancyColors2(2));
            end    
        
%% Temperature
    switch analyVar.sampleType
        case {'Thermal'}
            %% Aggregate Temperature Data
            [yCell_Temp] = deal(cell(1,NumDataSets));
            for mbIndex = 1:NumDataSets
                yCell_Temp{mbIndex}     = indivDataset{mbIndex}.atomTempY;
            end
            [~, Ave_Temp, Ave_Temp_error]       = AggregateData(xCell, yCell_Temp);        

            %% Plot Temperature Data
            [ Ave_Temp0, Ave_Temp0_order ] = EngineeringForm( Ave_Temp );
            Ave_Temp_error0 = Ave_Temp_error/10^Ave_Temp0_order;      

            PlotStruct_Temp.xData = xData;
            PlotStruct_Temp.yData = {Ave_Temp0};
            PlotStruct_Temp.yData_error = {Ave_Temp_error0};
            PlotStruct_Temp.hXLabel = xString;
            PlotStruct_Temp.colors = colors(1:6,:);
            PlotStruct_Temp.colors2 = colors(7:12,:);   
            PlotStruct_Temp.FCaxisfontsize     = analyVar.FCaxisfontsize;
            PlotStruct_Temp.FCfigPos     = analyVar.FCfigPos;
            PlotStruct_Temp.FCmarkerSize = analyVar.FCmarkerSize;
            PlotStruct_Temp.FCaxesPos    = analyVar.FCaxesPos;
            switch Ave_Temp0_order
                case -6
                    TempString = {'Temperature (\muK)'};
                    TempBoxString = ')~\mu\textup{K}$$';
                case -9
                    TempString = {'Temperature (nK)'};
                    TempBoxString = ')~\textup{mK}$$';
            end
            PlotStruct_Temp.hYLabel = TempString;
            FC_Plotter(PlotStruct_Temp);        

            %% Fit Temperature
            switch TempFit_Flag                
                case 1
                    %% Fit Temperature to Constant Value
                    [Temperature, TempFitRoutine] = Constant_Value_Fit( xData, Ave_Temp0, Ave_Temp_error0, error_flag );        
                    fitTempyData = TempFitRoutine.predict(fit_xData);
                    
                    %% Display Fitting Results            
                    disp(VariableName(Temperature))
                    disp(Temperature)         
                    %% Add Text Box
                    [ Temperature_String{1},  Temperature_String{2}] = Concise_Notation( Temperature(1), Temperature(2), 1);           
                    
                    string = [...
                        {['$$T_Y ~= ~' Temperature_String{1} '(' Temperature_String{2} TempBoxString]}...    
                        ];

                    hText1   = text(0,0, string ,'Interpreter','latex');
                    set(hText1,...
                        'Units', 'Normalized',...
                        'BackgroundColor', 'white',...
                        'EdgeColor', 'black',...
                        'Position', [.03, .22],...
                        'FontSize', analyVar.FClatexfontsize)    
            end
            if TempFit_Flag ~= 0
                plot(fit_xData, fitTempyData, 'Color', FrancyColors2(2));        
            end        
    end
    
%% Density

    %% Calculate Density
    switch analyVar.sampleType
        case {'Thermal'}
        %% Calculate Thermal Cloud Density
        [ Density, Density_error ] = Thermal_PeakDensity( analyVar, Ave_AtomNum, Ave_AtomNum_error, Ave_Temp, Ave_Temp_error);
        case {'BEC'}
        %% Calculate BEC Density
        [ Density, Density_error ] = BEC_PeakDensity( analyVar, Ave_AtomNum, Ave_AtomNum_error);
    end

    %% Plot Density Data
    [ Density0, Density0_order ] = EngineeringForm( Density );
    Density_error0 = Density_error/10^Density0_order;      

    PlotStruct_Density.xData = xData;
    PlotStruct_Density.yData = {Density0};
    PlotStruct_Density.yData_error = {Density_error0};
    PlotStruct_Density.hXLabel = xString;
    PlotStruct_Density.hYLabel = {['Density (10^{' sprintf('%0.0f', Density0_order-6) '} cm^{-3})']};
    PlotStruct_Density.colors = colors(1:6,:);
    PlotStruct_Density.colors2 = colors(7:12,:);
    PlotStruct_Density.FCaxisfontsize     = analyVar.FCaxisfontsize;
    PlotStruct_Density.FCfigPos     = analyVar.FCfigPos;
    PlotStruct_Density.FCmarkerSize = analyVar.FCmarkerSize;
    PlotStruct_Density.FCaxesPos    = analyVar.FCaxesPos;    
    FC_Plotter(PlotStruct_Density);

    
    %% Fit Density
    switch DensityFit_Flag
        case 1
            %% Fit Density to a Constant Value
            [InitialDensity, DensityFittingRoutine] = Constant_Value_Fit( xData, Density0, Density_error0, 1 );           
            fitDensity_yData = DensityFittingRoutine.predict(fit_xData);
            
            %% Display Fitting Results
            disp(VariableName(InitialDensity))
            disp(InitialDensity)
            
            %% Add Text Box
            [ InitialDensity_String{1},  InitialDensity_String{2}] = Concise_Notation( InitialDensity(1), InitialDensity(2), 1); 
            InitialDensity_String{3} = sprintf('%0.0f', Density0_order-6);                        
            string = [...
                {['$$n_0=' InitialDensity_String{1} '(' InitialDensity_String{2} ')~10^{' InitialDensity_String{3} '}\textup{cm}^{-3}$$']}...  
                ];
            hText1   = text(0,0, string ,'Interpreter','latex');
            set(hText1,...
                'Units', 'Normalized',...
                'BackgroundColor', 'white',...
                'EdgeColor', 'black',...
                'Position', [.03, .22],...
                'FontSize', analyVar.FClatexfontsize)    
                
        case 2
            %% Set YLabel to Log
            set(gca,... 
                'YTick'         , [0.1:0.1:0.9 1:9 10:10:100],...
                'YScale'        , 'log');   
            
            %% Fit to Exponential Decay
            [InitialDensity, DensityDecay, ~, DensityFittingRoutine] = Exponential_Decay_Fit2(xData, Density0, Density_error0, error_flag, 0);  
            fitDensity_yData = DensityFittingRoutine.predict(fit_xData);            
            DensityLifetime(1) = DensityDecay(1)^-1;
            DensityLifetime(2) = DensityDecay(2)*DensityDecay(1)^-2; 
            
            %% Display Fitting Results
            disp(VariableName(InitialDensity))
            disp(InitialDensity)
            disp(VariableName(DensityLifetime))
            disp(DensityLifetime)     
            
            %% Add Text Box
            [ InitialDensity_String{1},  InitialDensity_String{2}] = Concise_Notation( InitialDensity(1), InitialDensity(2), 1);
            InitialDensity_String{3} = sprintf('%0.0f', Density0_order-6);
            
            [ DensityLifetime_String{1},  DensityLifetime_String{2}] = Concise_Notation( DensityLifetime(1), DensityLifetime(2), 1);

            string = [
                {'$$n_0=\eta~\textup{exp}(-t/\tau)$$'}...
                {['$$\eta=' InitialDensity_String{1} '(' InitialDensity_String{2} ')\times 10^{' InitialDensity_String{3} '}\textup{cm}^{-3}$$']}...
                {['$$\tau~=' DensityLifetime_String{1} '(' DensityLifetime_String{2} ')$$']}...    
                ];
            hText1   = text(0,0, string ,'Interpreter','latex');
            set(hText1,...
                'Units', 'Normalized',...
                'BackgroundColor', 'white',...
                'EdgeColor', 'black',...
                'Position', [.03, .22],...
                'FontSize', analyVar.FClatexfontsize)    
 
    end
    if DensityFit_Flag ~= 0
        plot(fit_xData, fitDensity_yData, 'Color', FrancyColors2(2));
    end    

%% Interparticle Spacing
    %% Calculate Spacing

    [Spacing, Spacing_error] = Interparticle_Spacing(Density, Density_error);

    %% Plot Spacing Data
    [ Spacing0, Spacing0_order ] = EngineeringForm( Spacing );
    Spacing_error0 = Spacing_error/10^Spacing0_order;      

    PlotStruct_Spacing.xData = xData;
    PlotStruct_Spacing.yData = {Spacing0};
    PlotStruct_Spacing.yData_error = {Spacing_error0};
    PlotStruct_Spacing.hXLabel = xString;
    switch Spacing0_order
        case -6
            SpacingString       = {'Interparticle Spacing (\mum)'};
            SpacingBoxString    = ')~\mu\textup{m}$$';
        case -9
            SpacingString       = {'Interparticle Spacing (nm)'};
            SpacingBoxString    = ')~\textup{nm}$$';
    end
    PlotStruct_Spacing.hYLabel = SpacingString;
    PlotStruct_Spacing.colors = colors(1:6,:);
    PlotStruct_Spacing.colors2 = colors(7:12,:);
    PlotStruct_Spacing.FCaxisfontsize     = analyVar.FCaxisfontsize;
    PlotStruct_Spacing.FCfigPos     = analyVar.FCfigPos;
    PlotStruct_Spacing.FCmarkerSize = analyVar.FCmarkerSize;
    PlotStruct_Spacing.FCaxesPos    = analyVar.FCaxesPos;    
    FC_Plotter(PlotStruct_Spacing);
    
    %% Fit Spacing
    switch SpacingFit_Flag
        case 1
            %% Fit Spacing to a Constant Value
            [InitialSpacing, SpacingFittingRoutine] = Constant_Value_Fit( xData, Spacing0, Spacing_error0, 1 );           
            fitSpacing_yData = SpacingFittingRoutine.predict(fit_xData);
            
            %% Display Fitting Results
            disp(VariableName(InitialSpacing))
            disp(InitialSpacing)
            
            %% Add Text Box
            [ InitialSpacing_String{1},  InitialSpacing_String{2}] = Concise_Notation( InitialSpacing(1), InitialSpacing(2), 1); 
                        
            string = [...
                {['$$r=' InitialSpacing_String{1} '(' InitialSpacing_String{2} SpacingBoxString]}...  
                ];
            hText1   = text(0,0, string ,'Interpreter','latex');
            set(hText1,...
                'Units', 'Normalized',...
                'BackgroundColor', 'white',...
                'EdgeColor', 'black',...
                'Position', [.03, .22],...
                'FontSize', analyVar.FClatexfontsize)        
 
    end
    if SpacingFit_Flag == 1
        plot(fit_xData, fitSpacing_yData, 'Color', FrancyColors2(2));
    end 
    
%% Ratio of Rydberg Wavefunction volume to volume per particle (inverse of density)
    
    %% Calculate Ratio
    RydDiameter = 2*analyVar.aBohr*(analyVar.PrincQN-analyVar.QDefect)^2;
    VolRatio = (4/3)*pi*RydDiameter^3*Density;
    VolRatio_error = (4/3)*pi*RydDiameter^3*Density_error;

    %% Plot Spacing Data
    [ VolRatio0, VolRatio0_order ] = EngineeringForm( VolRatio );
    VolRatio_error0 = VolRatio_error/10^VolRatio0_order;      

    PlotStruct_VolRatio.xData = xData;
    PlotStruct_VolRatio.yData = {VolRatio0};
    PlotStruct_VolRatio.yData_error = {VolRatio_error0};
    PlotStruct_VolRatio.hXLabel = xString;
    PlotStruct_VolRatio.hYLabel = {'Ryd. Vol/ Volume per particle'};
    PlotStruct_VolRatio.colors = colors(1:6,:);
    PlotStruct_VolRatio.colors2 = colors(7:12,:);
    PlotStruct_VolRatio.FCaxisfontsize     = analyVar.FCaxisfontsize;
    PlotStruct_VolRatio.FCfigPos     = analyVar.FCfigPos;
    PlotStruct_VolRatio.FCmarkerSize = analyVar.FCmarkerSize;
    PlotStruct_VolRatio.FCaxesPos    = analyVar.FCaxesPos;    
    FC_Plotter(PlotStruct_VolRatio);
    
    %% Fit Spacing
    switch VolRatioFit_Flag
        case 1
            %% Fit Spacing to a Constant Value
            [InitialVolRatio, VolRatioFittingRoutine] = Constant_Value_Fit( xData, VolRatio0, VolRatio_error0, 1 );           
            fitVolRatio_yData = VolRatioFittingRoutine.predict(fit_xData);
            
            %% Display Fitting Results
            disp(VariableName(InitialVolRatio))
            disp(InitialVolRatio)
            
            %% Add Text Box
            [ InitialSpacing_String{1},  InitialSpacing_String{2}] = Concise_Notation( InitialVolRatio(1), InitialVolRatio(2), 1); 
                        
            string = [...
                {['$$\textup{Ratio}=' InitialSpacing_String{1} '(' InitialSpacing_String{2} ')$$']}...  
                ];
            hText1   = text(0,0, string ,'Interpreter','latex');
            set(hText1,...
                'Units', 'Normalized',...
                'BackgroundColor', 'white',...
                'EdgeColor', 'black',...
                'Position', [.03, .22],...
                'FontSize', analyVar.FClatexfontsize)        
 
    end
    if VolRatioFit_Flag == 1
        plot(fit_xData, fitVolRatio_yData, 'Color', FrancyColors2(2));
    end
    
    %% BEC Size
    switch analyVar.sampleType
        case {'BEC'}
        %% Calculate BEC Size
        [ BECSize, BECSize_error ] = BEC_Size( analyVar, Ave_AtomNum, Ave_AtomNum_error);
        %% Plot Density Data
        [ BECSize0, BECSize0_order ] = EngineeringForm( BECSize );
        BECSize_error0 = BECSize_error/10^BECSize0_order;      

        PlotStruct_BECSize.xData = xData;
        PlotStruct_BECSize.yData = {BECSize0};
        PlotStruct_BECSize.yData_error = {BECSize_error0};
        PlotStruct_BECSize.hXLabel = xString;
        switch BECSize0_order
            case -6
                BECSizeString       = {'BEC Radius (\mum)'};
                BECSizeBoxString    = ')~\mu\textup{m}$$';
            case -9
                BECSizeString       = {'BEC Radius (nm)'};
                BECSizeBoxString    = ')~\textup{nm}$$';
        end
        PlotStruct_BECSize.hYLabel = BECSizeString;
        PlotStruct_BECSize.colors = colors(1:6,:);
        PlotStruct_BECSize.colors2 = colors(7:12,:);
        PlotStruct_BECSize.FCaxisfontsize     = analyVar.FCaxisfontsize;
        PlotStruct_BECSize.FCfigPos     = analyVar.FCfigPos;
        PlotStruct_BECSize.FCmarkerSize = analyVar.FCmarkerSize;
        PlotStruct_BECSize.FCaxesPos    = analyVar.FCaxesPos;        
        FC_Plotter(PlotStruct_BECSize);

        %% Fit BECSize
        switch BECSize_Flag
            case 1
                %% Fit BECSize to a Constant Value
                [InitialBECSize, BECSizeFittingRoutine] = Constant_Value_Fit( xData, BECSize0, BECSize_error0, 1 );           
                fitBECSize_yData = BECSizeFittingRoutine.predict(fit_xData);

                %% Display Fitting Results
                disp(VariableName(InitialBECSize))
                disp(InitialBECSize)

                %% Add Text Box
                [ InitialBECSize_String{1},  InitialBECSize_String{2}] = Concise_Notation( InitialBECSize(1), InitialBECSize(2), 1); 

                string = [...
                    {['$$R_{BEC}=' InitialBECSize_String{1} '(' InitialBECSize_String{2} BECSizeBoxString]}...  
                    ];
                hText1   = text(0,0, string ,'Interpreter','latex');
                set(hText1,...
                    'Units', 'Normalized',...
                    'BackgroundColor', 'white',...
                    'EdgeColor', 'black',...
                    'Position', [.03, .22],...
                    'FontSize', analyVar.FClatexfontsize)        

        end
        if BECSize_Flag == 1
            plot(fit_xData, fitBECSize_yData, 'Color', FrancyColors2(2));
        end 
       
    end

end