function [ indivDataset ] = PeakDensity3( analyVar, indivDataset)

%% Fitting Flags
% 0 - No Fitting
% 1 - Constant Value
% 2 - Exponential Decay
% 3 - Exponential Loading Rate
% 4 - Gaussian
% 5 - Lorentzian

AtomNumFit_Flag = 0;
TempFit_Flag    = 0;
DensityFit_Flag = AtomNumFit_Flag;
SpacingFit_Flag = 0;
BECSize_Flag    = AtomNumFit_Flag;

convertFreqFlag = 0;

%% XLabel Strings
xString = {'UV Detuning (MHz)'};
% xString = {'UV Frequency (MHz)'};
% xString = {'Num Loop Sets'};

%% Color array
colors = FrancyColors2(-1);

%% Cell of Data Cells
% analyVar.meanListVar
% analyVar.uniqScanList
% analyVar.posOccurUniqVar

NumTraces = length(analyVar.uniqScanList);
[NumDataSets, error_flag, xDataParent, xData, fit_xData]= deal(cell(1,NumTraces));
for TraceIndex = 1:NumTraces
    NumDataSets{TraceIndex} = length(analyVar.posOccurUniqVar{TraceIndex});
    
    %% Flag Display Error Bars
    % if there are more than 1 data sets, use standard deviation of the
    % distributions as the uncertainty
    if NumDataSets{TraceIndex} == 1
        error_flag = 0;
    elseif NumDataSets{TraceIndex} > 1
        error_flag = 1;
    end    
   
    %% Independant Variable
    % use independant variable of experiment
    xCell = cell(1, NumDataSets{TraceIndex});
    for mbIndex = 1:NumDataSets{TraceIndex}
        pos             = analyVar.posOccurUniqVar{TraceIndex}(mbIndex);
        xCell{mbIndex}  = indivDataset{pos}.imagevcoAtom;
    end
    [xData{TraceIndex}, ~, ~] = AggregateData(xCell, xCell);    

    %% Convert Independant variable
    % if the flag is 1, convert assuming xData came in as synth frequency units
    % and will now be UV frequency units.
    if convertFreqFlag == 1
        AtomicFreq = analyVar.atomic_LineCenter;
        FreqConversion = analyVar.FreqConversion; %unitless, unit of UV freq per unit of Synth Freq.
        xData{TraceIndex} = -FreqConversion.*(xData{TraceIndex} - AtomicFreq);
    end

    fit_xData{TraceIndex} = linspace( min(xData{TraceIndex}) , max(xData{TraceIndex}), 1e4)';
    xDataParent{TraceIndex} = xCell;
end 

%% Atom Number
[yParent_AtomNum, Ave_AtomNum, Ave_AtomNum_error]= deal(cell(1,NumTraces));
for TraceIndex = 1:NumTraces
    %% Aggregate Atom Number
    [yCell_AtomNum] = cell(1,NumDataSets{TraceIndex});
    for mbIndex = 1:NumDataSets{TraceIndex}
        pos                     = analyVar.posOccurUniqVar{TraceIndex}(mbIndex);        
        yCell_AtomNum{mbIndex}  = indivDataset{pos}.winTotNum;
    end

    [~, Ave_AtomNum{TraceIndex}, Ave_AtomNum_error{TraceIndex}] = AggregateData(xDataParent{TraceIndex}, yCell_AtomNum); 
    
    yParent_AtomNum{TraceIndex} = yCell_AtomNum;
end

    %% Plot Atom Number Data
    [Ave_AtomNum0, Ave_AtomNum0_order, Ave_AtomNum0_error]= deal(cell(1,NumTraces));  
    MaxOrder_AtomNum = [];
    for TraceIndex = 1:NumTraces
        [ Ave_AtomNum0{TraceIndex}, Ave_AtomNum0_order{TraceIndex} ] = EngineeringForm( Ave_AtomNum{TraceIndex} );
        Ave_AtomNum0_error{TraceIndex} = Ave_AtomNum_error{TraceIndex}/10^Ave_AtomNum0_order{TraceIndex};      
        MaxOrder_AtomNum = cat(1, MaxOrder_AtomNum, Ave_AtomNum0_order{TraceIndex});
    end
    MaxOrder_AtomNum = max(MaxOrder_AtomNum);
    PlotStruct_AtomNum.xData = xData;
    PlotStruct_AtomNum.yData = Ave_AtomNum0;
    PlotStruct_AtomNum.yData_error = Ave_AtomNum0_error;
    PlotStruct_AtomNum.hXLabel = xString;
    PlotStruct_AtomNum.hYLabel = {['Atom Number (10^' sprintf('%0.0f', MaxOrder_AtomNum) ')']};
    PlotStruct_AtomNum.colors = colors(1:6,:);
    PlotStruct_AtomNum.colors2 = colors(7:12,:);
    PlotStruct_AtomNum.LineStyle = '-';
    FC_Plotter(analyVar, PlotStruct_AtomNum);

    %% Fit Atom Number
    switch AtomNumFit_Flag

        case 1
            %% Fit Atom Number to Constant Value
            [AtomNum0, AtomNumFitRoutine] = Constant_Value_Fit( xData, Ave_AtomNum0, Ave_AtomNum0_error, 1 );           
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
            [AtomNum0, AtomDecay, ~, AtomNumFitRoutine] = Exponential_Decay_Fit2(xData, Ave_AtomNum0, Ave_AtomNum0_error, error_flag, 0);  
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
            [yCell_Temp] = deal(cell(1,NumDataSets{TraceIndex}));
            for mbIndex = 1:NumDataSets{TraceIndex}
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
            switch Ave_Temp0_order
                case -6
                    TempString = {'Temperature (\muK)'};
                    TempBoxString = ')~\mu\textup{K}$$';
                case -9
                    TempString = {'Temperature (nK)'};
                    TempBoxString = ')~\textup{mK}$$';
            end
            PlotStruct_Temp.hYLabel = TempString;
            FC_Plotter(analyVar, PlotStruct_Temp);        

            %% Fit Temperature
            switch TempFit_Flag                
                case 1
                    %% Fit Temperature to Constant Value
                    [Temperature, TempFitRoutine] = Constant_Value_Fit( xData, Ave_Temp0, Ave_Temp_error0, 1 );        
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
    FC_Plotter(analyVar, PlotStruct_Density);
    
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
    %% Calculate Density

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
    FC_Plotter(analyVar, PlotStruct_Spacing);
    
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
    if SpacingFit_Flag ~= 0
        plot(fit_xData, fitSpacing_yData, 'Color', FrancyColors2(2));
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
        FC_Plotter(analyVar, PlotStruct_BECSize);

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
        if BECSize_Flag ~= 0
            plot(fit_xData, fitBECSize_yData, 'Color', FrancyColors2(2));
        end 
    end

end