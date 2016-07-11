    Guess_LoadRate = 2e3;
    Guess_OneBodyLoss = 10e-6;
    Guess_timeoffset = -0.5E-6;
    
    specFit = @(coeffs,x) coeffs(1)*(1-exp(-(x-coeffs(3))/coeffs(2)));

    xData = time(time>=0);
    xData = xData(1:7.5e3);
    yData = pos-neg;
    yData = yData(time>=0);
    yData = 100*yData;
    yData = yData(1:7.5e3);
    
    specFitModel = NonLinearModel.fit(xData,yData,specFit,[Guess_LoadRate Guess_OneBodyLoss Guess_timeoffset],...
        'CoefficientNames',{'Loading Rate','Time Constant','Time Offset'});
        
    loading_rate(1:2)  = double(specFitModel.Coefficients('Loading Rate',{'Estimate', 'SE'}));
    
    time_Constant(1:2) = double(specFitModel.Coefficients('Time Constant',{'Estimate', 'SE'}));

    saturationNum(1) = loading_rate(1)*time_Constant(1);
    saturationNum(2) = saturationNum(1)*sqrt((loading_rate(2)/loading_rate(1))^2+(time_Constant(2)/time_Constant(1))^2);

    timeoffset(1:2) = double(specFitModel.Coefficients('Time Offset',{'Estimate', 'SE'}));
    
    %%
    rate = loading_rate(1);
    tau  = time_Constant(1);
    toff = timeoffset(1);

    result = @(x) rate*(1-exp(-(x-toff)/tau));    
    %%
    
    figure
    subplot(2,1,1)
    hold on
    plot(xData, yData,'o','MarkerSize',1)
    xlabel('Time (s)')
    ylabel('Voltage (V)')
    fplot(result,[xData(1) xData(end)])
    hold off
    box on
    grid on
    mTextBox = uicontrol('style','text');
    string = [{'y = A(1-exp(-(t-t0)/tau))'}, {['A = ' mat2str(round(rate)) ' V']},...
        {['tau = ' mat2str(round(100*tau/1e-6)/100) 'us']}...
        {['t0 = ' mat2str(round(100*toff/1e-6)/100) 'us']}...
        ];
    set(mTextBox,'String',string)
    set(mTextBox,'Units','characters')
%     set(mTextBox,'Units','Normalized')
    set(mTextBox,'Position',[70 22 30 4.5])

    axis tight 
    
    subplot(2,1,2)
    res = (result(xData)-yData)/rate;
    plot(xData/1e-6,res,'o','MarkerSize',1)
    xlabel('Time (us)')
    ylabel('Residuals')
    box on
    grid on
    axis tight 
    
    
    
    
    