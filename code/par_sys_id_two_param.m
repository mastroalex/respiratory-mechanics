% Parametric system identification
%
% conversion in two parameters identification
%
% (modified from M. Khoo)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Mastrofini Alessandro
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Medical Engineering - University of Rome Tor Vergata
% Physiological Systems Modeling and Simulation
% F. Caselli, MSSF A.Y. 2021/2022
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

clear
close all
clc

% parametric system identification of respiratory mechnaics; data are
% generated by simulating the linear lung mechanics model (RLC) and then
% adding Gaussian white noise to the output; different input, u (p_ao), are
% considered; the output, y (p_A), is the noisy response to the input;

% time vector
T_final=0.8;
T=0.005; % 0.001
t=(0:T:T_final)';
% we do not have a real patient under hands, so we perform input-output
% measurements on a "virtual" patient (this way, we also know its "true"
% impulse response).

% linear model of lung mechanics (see lecture notes)
% parameter values of model
R=0.1; % resistance in units of cm H2O s/L
L=0.01; % inertance in units of cm H2O s^2/L
C=0.1; % compliance in units of L/cm H2O

% the first function set up system by obtaining response
% the second one do optimization cycle
% set last variables to 'plot' and 'verobse' to obtain plot and comment
% or to somewhat different to avoid plot and other comments

%y=setup_my_system(R,L,C,u,t,'plot');
%[error,theta_est,obj_fun_val]=my_optimization(L,R,C,u,t,y,'verbose');
 
% % STARTING 

% input: step
u=ones(size(t));
y_step=setup_my_system(R,L,C,u,t,'plot');
[error_step,theta_est_step,obj_fun_val_step]=my_optimization(L,R,C,u,t,y_step,'verbose');

% input: random gaussian signal 
u=1/3*idinput(size(t),'rgs');
y_rgs=setup_my_system(R,L,C,u,t,'plot');
[error_rgs,theta_est_rgs,obj_fun_val_rgs]=my_optimization(L,R,C,u,t,y_rgs,'verbose');

% input: random binary signal 
u=idinput(size(t),'rbs');
y_rbs=setup_my_system(R,L,C,u,t,'plot');
[error_rbs,theta_est_rbs,obj_fun_val_rbs]=my_optimization(L,R,C,u,t,y_rbs,'verbose');

% input: pseudo random binary signal 
u=idinput(size(t),'prbs');
y_prbs=setup_my_system(R,L,C,u,t,'plot');
[error_prbs,theta_est_prbs,obj_fun_val_prbs]=my_optimization(L,R,C,u,t,y_prbs,'verbose');

% plot error result
% it may variate between different iteration

figure;plot(100*[error_step, error_prbs, error_rbs, error_rgs]','-*');
legend({'\theta_1', '\theta_2'})
xticks([1 2 3 4])
xticklabels({'step','rgs','rbs','prbs'})
xlim([0, 5])
ylabel('Errore relativo %')


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

function y=setup_my_system(R,L,C,u,t,plotOpt)
% theta=[R,L,C];
% now considering only two parameters
theta=[L*C; R*C];

% solve model using lsim (cf. rlc_fun) and plot results
y=rlc_fun_two_param(theta,u,t);

% add gaussian noise to simulate measurement error/noise
y=y+0.05/3*randn(size(y)); % 0.01
% y=y+0.05/3*max(abs(y(:)))*randn(size(y)); % 0.01

if strcmp(plotOpt,'plot')
    % plot input signal
    figure()
    plot(t,u,'b','linewidth',2)
    title('Input','fontsize',12)
    xlabel('Time [s]','fontsize',12)
    set(gca,'fontsize',12)
    ylim([-1.3,1.3])

    % plot system response

    figure()
    plot(t,y,'m','linewidth',2)
    title('Output','fontsize',12)
    xlabel('Time [s]','fontsize',12)
    set(gca,'fontsize',12)
end
end

function [error,theta_est,obj_fun_val]=my_optimization(L,R,C,u,t,y,verbosity)


% PARAMETRIC SYSTEM IDENTIFICATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% true parameter values
%theta_true=[R; L; C];
theta_true=[L*C; R*C]; % now considering only two parameters
% initial guesses for the parameters to be estimated
% parameters vector: theta=[R;L;C]
%theta_init=[1.5; 0.8; 2.8].*theta_true;
% update for two parameters test:
theta_init=[0.8*2.8; 1.5*0.8].*theta_true;

% optimization
options = optimset('PlotFcns',@optimplotfval); % add monitoring graphs
[theta_est,obj_fun_val,exitflag,output]=fminsearch('obj_fun_two_param',theta_init,options,y,u,t);

if strcmp(verbosity,'verbose')
    % visualize optimization report
    disp(' ')
    disp('************* Report *************')
    disp(['exitflag=', num2str(exitflag)])
    disp('true, initial and estimated parameter values')
    disp([theta_true,theta_init,theta_est])
    disp('final value of the objective function')
    disp(obj_fun_val)
    disp(output)
    disp(output.message)

end

% compute estimated output
y_pred=rlc_fun_two_param(theta_est,u,t);

if strcmp(verbosity,'verbose')
    % plot true and predicted output
    figure()
    plot(t,y,'m','linewidth',2)
    hold on
    plot(t,y_pred,'g','linewidth',2)
    title('Output','fontsize',12)
    legend('true','predicted','location','best')
    xlabel('Time [s]','fontsize',12)
    set(gca,'fontsize',12)
end
% relative errors on parameter values
disp('relative errors on parameter values')
error=0.*theta_est; % initialize the vector
for i=1:length(theta_est)
    error(i)=abs(theta_est(i)-theta_true(i))/abs(theta_true(i));
    disp(error(i))
end
if strcmp(verbosity,'verbose')

    % SENSITIVITY ANALYSIS ***************************************************

    % Sensitivity of measurements with respect to parameters
    % J (N_m x N_p)
    % J_mp=derivative of m-th measure with respect to p-th parameter
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
    disp('Sensitivity analysis')
    disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
end
% reference parameter values
theta_ref=theta_true;
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

if strcmp(verbosity,'verbose')
    % J
    format long
    disp('condition number of sensitivity matrix J')
    cond(J)
    disp('rank of sensitivity matrix (wng: fake news!)')
    rank(J)
    disp('singular values of sensitivity matrix')
    [U,S,V]=svd(J);
    diag(S)
end
end

