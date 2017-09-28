function indivBatch = param_extract_ind_var_to_wavemeter(analyVar, indivBatch)
%PARAM_EXTRACT_IND_VAR_TO_WAVEMETER Summary of this function goes here
%   Detailed explanation goes here


        
    ind_var = indivBatch.imagevcoAtom;
    wavemeter = indivBatch.wavemeterAtom;

    p = polyfit(ind_var,wavemeter,1);
    figure()
    hold on
    plot(ind_var,wavemeter)
    plot(ind_var,polyval(p,ind_var))

    indivBatch.imagevcoAtom = mod(polyval(p, ind_var),10);

    

end

