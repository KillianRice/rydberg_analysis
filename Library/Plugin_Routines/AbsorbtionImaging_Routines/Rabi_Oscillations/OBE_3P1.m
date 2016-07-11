function OBE_3P1
% Function for solving the optical bloch equations with dissipation for 1S0->3P1
% This function will simply plot the results of the parameters below, there is no fitting. It is simply a
% demonstration of how to solve the OBE's

%% Initialize variables
% Physical variables
omegaRabi = 2*pi*325e3; %[s^-1] bare Rabi freq.
gammaLife = 2*pi*7.5e3; %[s^-1] natural decay lifetime of 3P1 state
delta     = 2*pi*0e3;   %[s^-1] detuning from 3P1 state
gammaCoh  = 2*pi*80e3;  %[s^-1] empirical laser linewidth of 3P1 laser

% Computational variables
tRange   = linspace(0,10e-6,1e3); % in units of Rabi periods
initCond = [1; 0; 0; 0];          % organized as [p11; p22; p21; p12]

%% Numerically solve OBE
[solT,rho] = ode45(@(t,rho) funcOBE(t,rho,omegaRabi,gammaLife,gammaCoh,delta),tRange,initCond);

%% Plotting result of 
figure;
popHan = plot([solT solT]*1e6,rho(:,[1,2]));
legHan = legend('p11','p22');
set(popHan,...
    'LineWidth' ,   2   )
set(gca,...
    'Box'       ,   'on'    ,...
    'LineWidth' ,   2       ,...
    'FontSize'  ,   20      ,...
    'FontWeight',   'bold'  );
xlabel('Time [\mus]',...
      'FontSize'      ,   20  ,...
      'FontWeight'    ,   'bold'  );
ylabel('Populations',...
      'FontSize'      ,   20  ,...
      'FontWeight'    ,   'bold'  );
axis tight
grid on

end