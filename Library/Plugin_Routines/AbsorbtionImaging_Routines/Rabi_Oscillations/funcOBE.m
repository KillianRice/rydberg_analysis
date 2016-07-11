function rhoOut = funcOBE(t,rho,omegaRabi,gammaLife,gammaCoh,delta)
% Setup 2 level optical bloch equations with damping

 % Initialize output rho
 rhoOut = zeros(4,1);
 
 % extract current values of density matrix
 pgg = rho(1); %ground state population
 pee = rho(2); %excited state population
 pge = rho(3); %ground-excited coherence
 peg = rho(4); %excited-ground coherence
 
 % Determine response of function
 rhoOut(1) = gammaLife*pee + 1i*omegaRabi/2*(peg - pge); %pgg out
 rhoOut(2) = -gammaLife*pee - 1i*omegaRabi/2*(peg - pge); %pee out
 rhoOut(3) = -(gammaLife/2 + gammaCoh + 1i*delta)*pge + 1i*omegaRabi/2*(pee - pgg); %pge out
 rhoOut(4) = -(gammaLife/2 + gammaCoh - 1i*delta)*peg - 1i*omegaRabi/2*(pee - pgg); %peg out
 
end