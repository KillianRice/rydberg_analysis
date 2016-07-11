function [ indivDataset ] = PeakDensity( analyVar,indivDataset)
%calculate the Peak Density in ODT

[EffVolume]= deal(cell(1,analyVar.numBasenamesAtom));

indivDataset = Trap_Frequency(analyVar, indivDataset);

for ii = 1:analyVar.numBasenamesAtom

    EffVolume{ii}=(...
        2*pi*analyVar.kBoltz*indivDataset{ii}.atomTemp./...
        (analyVar.mass*indivDataset{ii}.Trap_Frequency.^2)...
        ).^(3/2);
    
    indivDataset{ii}.Peak_Density = indivDataset{ii}.winTotNum./EffVolume{ii};
    
end

end