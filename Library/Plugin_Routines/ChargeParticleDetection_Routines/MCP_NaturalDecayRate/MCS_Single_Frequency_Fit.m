function [indivDataset] = MCS_Single_Frequency_Fit(analyVar,indivDataset,avgDataset)

indivDataset = PeakDensity(analyVar,indivDataset); %extract peak density from data.

indivDataset = param_extract_mcs_sum(analyVar,indivDataset);%get data out of mcs files, normalization to atomnumber and/or number of ramps is done here

if analyVar.plotMCS_traces
    create_plot_mcs_traces(analyVar,indivDataset);
end

if analyVar.plot_mcs_sum
    create_plot_mcs_sum(analyVar,indivDataset);
end

if analyVar.fitMCS_SpectraGaussian
    MCS_GaussianFit_Output = MCS_gaussian_fit(analyVar,indivDataset);
else 
    MCS_GaussianFit_Output = MCS_gaussian_sum(analyVar,indivDataset);
end

%%Fit Exponential Decay to data
MCS_Integral_Cell = cell(1,1); %make it a cell because the plot function wants a cell

if analyVar.MCS_normalize %%bad code, need to generalize this function to fit to any number of traces per sample per batch.
    MCS_Integral_Cell{1} = MCS_GaussianFit_Output.MCS_Spectrum_Integral(:,1)./MCS_GaussianFit_Output.MCS_Spectrum_Integral_wo_Delay(:,1);
else
    MCS_Integral_Cell{1} = MCS_GaussianFit_Output.MCS_Spectrum_Integral(:,1);
end  
       
%% Define Physical Functions Used in Calculations
% coeffs has elements coeffs = [initial_population, trap_lifetime]

ExponentialDecayFitModel = @(coeffs,x) coeffs(1)*exp(-x/coeffs(2))+coeffs(3);

RampDelay = nan(analyVar.numBasenamesAtom,1);

for kk=1:analyVar.numBasenamesAtom
    RampDelay(kk) = indivDataset{kk}.RampDelay(1);
end

%% Initialize loop variables
[InitialValue, TimeConstant, Offset] = deal(zeros(1,3));
for ii=1:analyVar.numBasenamesAtom
    
[InitialValue(1:2), TimeConstant(1:2), Offset(1:2)] =...
    Exponential_Decay_Fit(RampDelay, MCS_Integral_Cell{1}, analyVar.MCS_Exponential_Fit_Offset);

InitialValue(3) = InitialValue(2)/InitialValue(1);%ratio of uncertainty to value of the parameter
TimeConstant(3) = TimeConstant(2)/TimeConstant(1);
Offset(3) = Offset(2)/Offset(1);

plot_with_confidence_intervals_Exponential_Decay({RampDelay'}, MCS_Integral_Cell, InitialValue, TimeConstant, Offset, ExponentialDecayFitModel)

% data_Folder = analyVar.dataDirName
format short
analyVar.timevectorAtom

% bath_file_names=zeros(analyVar.numBasenamesAtom,1);
% for kk=1:analyVar.numBasenamesAtom
% bath_file_names(kk)=cell2mat(indivDataset{kk}.fileMCS(1));
% end
% bath_file_names

datestr(now,'mm/dd/yy HH:MM:SS.FFF')
format shortEng
if analyVar.ShowMCS_Exponential_Decay_FitParameters
InitialValue
TimeConstant
    if analyVar.MCS_Exponential_Fit_Offset
    Offset
    end
end

end

end

