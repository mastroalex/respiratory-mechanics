% % % % % % % % % % % % % % % % % % % % % % % % 
% F. Caselli, MSSF A.A. 2020/2021
% % % % % % % % % % % % % % % % % % % % % % % % 

function [y_pred,u]=rlc_fun_two_param(theta,u,t)
% generates a vector y_pred, containing the values of the
% model prediction in response to input forcing (given in vector u)
% and for given parameter values of R, L and C

% extract R, L, and C from parameter vector
%R=theta(1); L=theta(2); C=theta(3);
%non serve estrarre RLC ma uso direttamente theta1 e theta2
if not(length(theta)==2)
    error('Check theta lenght')
end
% define transfer function
num=(1);
den=[theta(1)  theta(2)  1];
Hs=tf(num,den);

% predict output
y_pred=lsim(Hs,u,t);

end
