function [ ramp_coeffs ] = param_extract_ramp_coeffs( analyVar, indivDataset )
%PARAM_EXTRACT_RAMP_COEFFS Look for ramp coefficients in file or fit ramp
%data and save coefficients
%   Joe Whalen - 2016.12.15
%   Takes ramp data measured from oscilloscope and fits it to a 5th order
%   polynomial, saves the fit parameters to a file for fast plotting of
%   sfi's vs field

    tMin = 0;
    tMax = indivDataset.mcsSpectra{1}(end,1);

    disp(['Positive Ramp File: ' analyVar.positive_ramp_file])
    disp(['Negative Ramp File: ' analyVar.negative_ramp_file])
    pos_filename = analyVar.positive_ramp_file;
    neg_filename = analyVar.negative_ramp_file;
    
    posData = dlmread(pos_filename, ',', 0, 3);
    negData = dlmread(neg_filename, ',', 0 ,3);
    
    posData = posData(:,1:2);
    negData = negData(:,1:2);
    
    deltaV = [posData(:,1) posData(:,2) - negData(:,2)];
    
    firstIndex = 0;
    lastIndex = 0;
    
    flag = 0;
    for i = 1:size(deltaV,1)
        if deltaV(i,1) > tMin && flag == 0
            firstIndex = i;
            flag = 1;
        end
        if deltaV(i,1) > tMax
            lastIndex = i;
            break
        end
    end
    
    if firstIndex == 0 || lastIndex == 0
        warning('Ramp file does not appear to have correct time range, check that they are valid.')
    end
    
    ramp_coeffs = polyfit(deltaV(firstIndex:lastIndex,1)*10^6, deltaV(firstIndex:lastIndex,2),10);
    
end

