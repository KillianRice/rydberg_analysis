function funcOut = trap_effective_volume(analyVar, indivDataset, ~)


for basename = 1:analyVar.numBasenamesAtom
    if analyVar.UseImages==1
        Tempx =indivDataset{basename}.atomTempX;
        Tempy = indivDataset{basename}.atomTempY;   % Temperature of the sample
        num = indivDataset{basename}.winTotNum;     % total number of atoms in the trap
    else
        num = indivDataset{basename}.numberAtom;
        Tempx =indivDataset{basename}.tempXAtom;
        Tempy =indivDataset{basename}.tempYAtom;
    end
%%%%%%%%%%% constants %%%%%%%%%%%%
hbar = 6.626*10^(-34)/2/pi;     % Reduced Planck's constant 
omega_r = 2*pi*125;             % 125 Hz Radial Trap frequency
omega_dimple = 2*pi*295;        % 295 Hz Vertical Trap frequency
kb = 1.38*10^(-23);             % Boltzmann constant
lambda = omega_dimple/omega_r;  
T= (Tempx.^2.*Tempy).^(1/3);
m = 87.62*1.673*10^(-27);       % avg mass of Sr 
num=double(mean(num));
T=double(mean(T));

%%%%%%%%%% defining the transition temp for the sample
Tf = hbar*omega_r*(6*lambda*num)^(1/3)/kb;                      % Fermi temperature
numstates = 10;                                                 % number of hyperfine ground states;  Sr87 has 10
Tfunpol = hbar*omega_r*(6*lambda*num/numstates)^(1/3)/kb;       % Fermi temperature for the unpol Sample  
Tc = hbar*num^(1/3)*(omega_r^2*omega_dimple)^(1/3)*0.94/kb;     % BEC transition temp


%%%%%%%%% solving for fugacity of the thermal gas 
syms fugacity;
assume(fugacity,'real');
fug{basename} = double(vpasolve(polylog_BEC_fermi(-fugacity)+1./(6*(T/Tf).^3)==0,fugacity,[0,1]));
fugbose{basename} =double(vpasolve(polylog_BEC_fermi(fugacity)-num.*((hbar*((omega_r^2)*(omega_dimple))^(1/3))./(kb.*T)).^3==0,fugacity,[0,1]));
fugunpol{basename} =double(vpasolve(polylog_BEC_fermi(-fugacity)+1./(6*(T./Tfunpol).^3)==0,fugacity,[0,1]));



%%%This sets the limits of the integral ; make sure it covers the whole cloud
xmini=-40*10^(-6);     
xmaxi=40*10^(-6);

%%%%%%%%%% Functions %%%%%%%%%%%%
densityfermi = @(x,y,z) -(kb*m.*T).^(3/2)./((2*pi)^(3/2)*hbar^3).*polylog_BEC_fermi(-fug{basename}.*exp((-m*omega_r.^2.*(x.^2 + y.^2 + lambda.^2.*z.^2))./(2*kb.*T)));
densityfermiunpol = @(x,y,z) -(kb*m.*T).^(3/2)./((2*pi).^(3/2)*hbar^3).*polylog_BEC_fermi(-fugunpol{basename}.*exp((-m*omega_r.^2.*(x.^2 + y.^2 + lambda.^2.*z.^2))./(2*kb.*T)));
densitybose =  @(x,y,z) (kb*m*T)^(3/2)/((2*pi)^(3/2)*hbar^3).*polylog_BEC_fermi(fugbose{basename}.*exp((-m*omega_r^2.*(x.^2 + y.^2 + lambda^2.*z.^2))./(2*kb*T))); 

%%%%%%% column density from density
coldensityfermi = @(y,z) integral(@(x) densityfermi(x,y,z),xmini,xmaxi,'ArrayValued',true); 
coldensitybose = @(y,z) integral(@(x) densitybose(x,y,z),xmini,xmaxi,'ArrayValued',true);
coldensityfermiunpol = @(y,z) integral(@(x) densityfermiunpol(x,y,z),xmini,xmaxi,'ArrayValued',true);



%%%%%%%%% Effective Volume integrals %%%%%%%%%%%
    for i=1:3
        vbose{basename,i} =integral3(@(x,y,z) densitybose(x,y,z).^i,xmini,xmaxi,xmini,xmaxi,xmini,xmaxi)/(densitybose(0,0,0))^i;
        vfermi{basename,i} =integral3(@(x,y,z) densityfermi(x,y,z).^i,xmini,xmaxi,xmini,xmaxi,xmini,xmaxi)./(densityfermi(0,0,0).^i);
        vfermiunpol{basename,i} =integral3(@(x,y,z) densityfermiunpol(x,y,z).^i,xmini,xmaxi,xmini,xmaxi,xmini,xmaxi)./(densityfermiunpol(0,0,0).^i);
    end
    
    if analyVar.UseImages==1  
        %%%%%% creating Mesh to plot %%%%%%%%%
        Y=xmini:1*10^(-6):xmaxi;
        Z=xmini:1*10^(-6):xmaxi;
        [YY,ZZ]=meshgrid(Y,Z');
        coldensityfermi=reshape(coldensityfermi(YY,ZZ),length(Y),length(Z));
        coldensitybose=reshape(coldensitybose(YY,ZZ),length(Y),length(Z));
        coldensityfermiunpol=reshape(coldensityfermiunpol(YY,ZZ),length(Y),length(Z));
        ndensityvector={coldensitybose,coldensityfermi,numstates.*coldensityfermiunpol,coldensityfermi-coldensitybose,...
        coldensityfermi-numstates.*coldensityfermiunpol,numstates.*coldensityfermiunpol-coldensitybose};
        titlevec={'bosons','fermions','unpolarised fermions','residual Fermi-bose','res. UnpolFermi-fermi','res unpolFermi-bose'};

        %%%  Plots 
        figure(basename)
        title(basename);

        for i =1:length(ndensityvector)
            subplot(2,3,i)
            imagesc(Y,Z,ndensityvector{i})
            title(titlevec{i});

            
            colorbar
        end
    end
    funcOut.indivDataset = indivDataset;
end
            disp('The V1, V2 and V3 values for bose, fermi and fermi-unpolarised are:')
            disp(vbose)
            disp(vfermi)
            disp(vfermiunpol)
            disp('the fugacities are for bose, fermi and fermiunpol:')
            disp('fugbose')
            disp(fug)
            disp(fugunpol)





