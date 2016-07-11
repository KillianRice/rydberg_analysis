function [indivDataset] = MCS_gaussian_fit2(analyVar, indivDataset)

for mbatchIndex = 1:analyVar.numBasenamesAtom
    
    numFrequency = indivDataset{mbatchIndex}.CounterMCS;
    numTimeDelay = length(indivDataset{mbatchIndex}.timedelayOrderMatrix{1});%need to generalize, assumes time delay values are shared within the master batch file
    numDensities = indivDataset{mbatchIndex}.numDensityGroups{1};%need to generalize, assumes each sample took the same number of density points and the same values
    
    x_data_Array = repmat(indivDataset{mbatchIndex}.synthFreq,[1 numTimeDelay numDensities]); %independant variable; frequency

    MCS_Sum = nan(size(x_data_Array));
    for batchIndex = 1:numFrequency      
        MCS_Sum(batchIndex,:,:) = indivDataset{mbatchIndex}.mcsSumUnnormalized{batchIndex};
    end
    
    [amplitude, center, sigma, offset, MCS_Spectrum_Integral] = deal(nan(size(x_data_Array,2),size(x_data_Array,3),3));% each output will be a matrix of (# of batch files) x 2, one column for the parameter and the other for the uncertainty in the parameter 
    
    for delayIndex = 1:numTimeDelay
        for DensityIndex = 1:numDensities
            [amplitude(delayIndex,DensityIndex,1:2), center(delayIndex,DensityIndex,1:2), sigma(delayIndex,DensityIndex,1:2), offset(delayIndex,DensityIndex,1:2)]  =...
                gaussian_fit(x_data_Array(:,delayIndex,DensityIndex), MCS_Sum(:,delayIndex,DensityIndex), analyVar.MCS_Gaussian_Fit_Offset);%fit first data from sample; data with delay of ramp

            amplitude(delayIndex,DensityIndex,3)= amplitude(delayIndex,DensityIndex,2)/amplitude(delayIndex,DensityIndex,1);%ratio of uncertainty to value of the parameter
            center(delayIndex,DensityIndex,3)   = center(delayIndex,DensityIndex,2)/center(delayIndex,DensityIndex,1);
            sigma(delayIndex,DensityIndex,3)    = sigma(delayIndex,DensityIndex,2)/sigma(delayIndex,DensityIndex,1);
            offset(delayIndex,DensityIndex,3)   = offset(delayIndex,DensityIndex,2)/offset(delayIndex,DensityIndex,1);

            MCS_Spectrum_Integral(delayIndex,DensityIndex,1)    =   amplitude(delayIndex,DensityIndex,1)*sigma(delayIndex,DensityIndex,1)*(2.0*pi)^(0.5);
            MCS_Spectrum_Integral(delayIndex,DensityIndex,2)    =   MCS_Spectrum_Integral(delayIndex,DensityIndex,1)*((amplitude(delayIndex,DensityIndex,2)/amplitude(delayIndex,DensityIndex,1))^2+(sigma(delayIndex,DensityIndex,2)/sigma(delayIndex,DensityIndex,1))^2)^(0.5);
            MCS_Spectrum_Integral(delayIndex,DensityIndex,3)    =   MCS_Spectrum_Integral(delayIndex,DensityIndex,2)./MCS_Spectrum_Integral(delayIndex,DensityIndex,1);
        end
    end
    
    indivDataset{mbatchIndex}.MCSamplitude = amplitude;
    indivDataset{mbatchIndex}.MCScenter = center;
    indivDataset{mbatchIndex}.MCSsigma = sigma;
    indivDataset{mbatchIndex}.MCSoffset = offset;
    indivDataset{mbatchIndex}.MCS_Spectrum_Integral = MCS_Spectrum_Integral;

    if analyVar.ShowMCSFits
    GaussianFitModel = @(coeffs,x) coeffs(1) .* exp(-(x - coeffs(2)).^2 /(2 * coeffs(3)^2))+coeffs(4);
    plot_with_confidence_intervals_Gaussian2(...
        analyVar,...
        indivDataset,...
        x_data_Array,...
        MCS_Sum,...
        indivDataset{mbatchIndex}.timedelayOrderMatrix{1},... %have to check that this is ok, works if all time delays used in the batch group are the same, and by this line I have sorted them in param_extract_mcs_sum, so should be ok
        amplitude,...
        center,...
        sigma,...
        offset,...
        GaussianFitModel)
    end
    
end
warning('need to generalize initialization of MCS_Sum array.')

if analyVar.ShowMCSFitParameters
    amplitude
    center
    sigma
    if analyVar.MCS_Gaussian_Fit_Offset
        offset
    end
    MCS_Spectrum_Integral
    
end
    
end
    