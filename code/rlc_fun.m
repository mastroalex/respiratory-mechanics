% % % Medical Engineering - University of Rome Tor Vergata
% % % MSSF - Caselli, F
% % % Lungs mechanics models - Mastrofini, A

function [y_pred]=rlc_fun(theta,u,t)
% generates a vector y_pred, containing the values of the
% model prediction in response to input forcing (given in vector u)
% and for given parameter values of R, L and C

% extract R, L, and C from parameter vector
R=theta(1); L=theta(2); C=theta(3);

% define transfer function
num=(1);
den=[L*C  R*C  1];
Hs=tf(num,den);

% predict output
y_pred=lsim(Hs,u,t);

end
