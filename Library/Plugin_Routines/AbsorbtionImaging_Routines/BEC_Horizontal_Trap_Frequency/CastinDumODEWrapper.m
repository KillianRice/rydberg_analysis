%% Main Function
function x = CastinDumODEWrapper(b, t, sigma_0)
% returns the solution to the ode based on the given parameters, to be used
% when fitting the trap frequencies.

t = [0;t];

omega_r = abs(b(1));
omega_z = abs(b(2));
initial_sigma_r = sigma_0 * omega_r^(-2/5);
initial_sigma_z  = sigma_0 * omega_z^(-2/5);
init = [initial_sigma_r 0 initial_sigma_z 0];

[tt,x] = ode45(@(t,x) CastinDumODE(t,x,sigma_0,omega_z,omega_r), t, init);

x = [x(2:end,1),x(2:end,3)];

end

%% Helper Functions

function dxdt = CastinDumODE(t,x,sigma_0,omega_z,omega_r)
% Returns the rhs of the castin dum ode for a given set of params
dxdt = zeros(4,1);
dxdt(1) = x(2); % d/dt r_ax = r_ax dot
dxdt(2) = sigma_0^5 * omega_z^(-2/5) * omega_r^(2/5)/(x(1)^3*x(3));
dxdt(3) = x(4); %d/dt r_z = \dot{r_z}
dxdt(4) = sigma_0^5 * omega_z^(4/5) * omega_r^(-4/5)/(x(1)^2 * x(3)^2);

end

