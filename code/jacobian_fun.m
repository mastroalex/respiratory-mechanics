function [J]=jacobian_fun(theta_ref,u,t)
% number of parameters
N_p=length(theta_ref);
y_ref=rlc_fun_two_param(theta_ref,u,t);
% number of measures
N_m=length(y_ref);
% increment
h=1e-6; % 1e-7
pert=h*theta_ref;
% jacobian matrix
J=zeros(N_m,N_p);
for i=1:N_p
    % initialization to reference parameters
    theta_pert=theta_ref;
    % perturbation of i-th parameter
    theta_pert(i)=theta_pert(i)+pert(i);
    % output corresponding to perturbed parameters
    y_pert=rlc_fun_two_param(theta_pert,u,t);
    % sensitivity
    J(:,i)=(y_pert-y_ref)/pert(i); % similar to (f(x_0+h)-f(x_0))/h
end

end