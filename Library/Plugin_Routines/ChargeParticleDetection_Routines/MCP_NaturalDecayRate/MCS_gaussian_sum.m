function indivDataset = MCS_gaussian_sum(analyVar,indivDataset)
error('code doesnt know how to deal with data of diff dimentions')
[MCS_trace_integrals_w_Delay, MCS_trace_integrals_wo_Delay,...
    MCS_Spectrum_Integral, MCS_Spectrum_Integral_wo_Delay]     =   deal(cell(1,analyVar.numBasenamesAtom));

for iterVar = 1:analyVar.numBasenamesAtom;

    MCS_trace_integrals_w_Delay{iterVar}        =   indivDataset{iterVar}.mcsSum(:,1);%integral of traces
    MCS_trace_integrals_wo_Delay{iterVar}       =   indivDataset{iterVar}.mcsSum(:,2);%same but for the second data set in the same sample which is done w/o ionization ramp delay
    if analyVar.ConstFreq 
        MCS_Spectrum_Integral(iterVar,1) =  MCS_trace_integrals_w_Delay{iterVar};
        MCS_Spectrum_Integral(iterVar,2) =  MCS_trace_integrals_wo_Delay{iterVar};
    else
        MCS_Spectrum_Integral{iterVar,1}            =   sum(MCS_trace_integrals_w_Delay{iterVar});
        MCS_Spectrum_Integral{iterVar,2}            =   std(MCS_trace_integrals_w_Delay{iterVar});
    end
    warning('MCS_Spectrum_Integral(iterVar,2) doesnt mean anything atm, have to redefine')
    MCS_Spectrum_Integral_wo_Delay(iterVar,1)   =   sum(MCS_trace_integrals_wo_Delay{iterVar});
    MCS_Spectrum_Integral_wo_Delay(iterVar,2)   =   std(MCS_trace_integrals_wo_Delay{iterVar});
    warning('MCS_Spectrum_Integral_wo_Delay(iterVar,2) doesnt mean anything atm, have to redefine')
    
    indivDataset{iterVar}.MCS_Spectrum_Integral = MCS_Spectrum_Integral(iterVar,:);
    indivDataset{iterVar}.MCS_Spectrum_Integral_wo_Delay = MCS_Spectrum_Integral_wo_Delay(iterVar,:);
end
    
end
    