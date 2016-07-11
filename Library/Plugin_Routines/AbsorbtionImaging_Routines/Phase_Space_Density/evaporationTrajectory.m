function voltage = evaporationTrajectory(scanDataSet)
    error('Broken, need to find where scanDataSet structure is made and what ever fields it has, make them fields of indivDataset instead')
    initialVoltage = scanDataSet.Evaporation_InitialVoltage;
    finalVoltage = scanDataSet.Evaporation_FinalVoltage;
    eta = scanDataSet.Evaporation_Eta;
    tau = scanDataSet.Evaporation_Tau;
    time = scanDataSet.imagevcoAtom / 1000; %time is reported in ms, tau is in s
    beta = 2*((eta - 5)./(eta - 4) - 3 + eta) ./ ((eta - 5)./(eta - 4)+eta);
    voltage = initialVoltage./(1 + time./tau).^beta + finalVoltage;

end