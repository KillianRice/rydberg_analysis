function [InitialValue, DecayRate, Offset, Fitting_Routine] = Exponential_Decay_Fit2(xData, yData, yData_error, error_flag, offset_flag)
%fit data to exponential decay

%% Reshape
%reshape such that is doesn't matter weather the inputs are column or row vectors
yData       = reshape(yData, size(xData)); 
yData_error = reshape(yData_error, size(xData));

%% Initial Guesses
InitialValue_Guess = max(yData);
DecayRate_Guess  = 1/max(xData);
Offset_Guess    = min(yData);

switch error_flag
    case 0
        switch offset_flag
            case 0          
                Model = @(coeffs,x) coeffs(1)*exp(-coeffs(2)*x);
                Fitting_Routine = NonLinearModel.fit(...
                    xData, yData,...
                    Model, [InitialValue_Guess, DecayRate_Guess],...
                    'CoefficientNames',{'InitialValue','DecayRate'}...
                    );                
                Offset = 0;                
            case 1
                Model = @(coeffs,x) coeffs(1)*exp(-coeffs(2)*x)+coeffs(3);
                Fitting_Routine = NonLinearModel.fit(...
                    xData, yData,...
                    Model, [InitialValue_Guess, DecayRate_Guess, Offset_Guess],...
                    'CoefficientNames',{'InitialValue','DecayRate','Offset'}...
                    );     
                Offset    = double(Fitting_Routine.Coefficients('Offset',{'Estimate','SE'}));                
        end
        
    case 1
        switch offset_flag
            case 0 
                Model = @(coeffs,x) coeffs(1)*exp(-coeffs(2)*x);
                Fitting_Routine = NonLinearModel.fit(...
                    xData, yData,...
                    Model, [InitialValue_Guess, DecayRate_Guess],...
                    'CoefficientNames',{'InitialValue','DecayRate'},...
                    'Weights', (yData_error).^-2 ...
                    );                
                Offset = 0;                
            case 1
                Model = @(coeffs,x) coeffs(1)*exp(-coeffs(2)*x)+coeffs(3);
                Fitting_Routine = NonLinearModel.fit(...
                    xData, yData,...
                    Model, [InitialValue_Guess, DecayRate_Guess, Offset_Guess],...
                    'CoefficientNames',{'InitialValue','DecayRate','Offset'},...
                    'Weights', (yData_error).^-2 ...
                    );     
                Offset    = double(Fitting_Routine.Coefficients('Offset',{'Estimate','SE'}));                
        end
end

InitialValue    = double(Fitting_Routine.Coefficients('InitialValue',{'Estimate','SE'}));
DecayRate       = double(Fitting_Routine.Coefficients('DecayRate',{'Estimate','SE'}));
    
end