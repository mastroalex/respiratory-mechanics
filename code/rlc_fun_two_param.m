% % % % % % % % % % % % % % % % % % % % % % % % 
% F. Caselli, MSSF A.A. 2020/2021
% % % % % % % % % % % % % % % % % % % % % % % % 

function [y_pred,u]=rlc_fun_two_param(theta,u,t)
% generates a vector y_pred, containing the values of the
% model prediction in response to input forcing (given in vector u)
% and for given parameter values of R, L and C

% it's not neceessary to extract components
% only pass theta1=LC and theta2=RC to the transfer function

%%%%%%%%%%%%%%%%%%%%
% check theta to avoid use this function with the 3 parameters version of
% the code. It could be a problem because would not return an error but
% only return a different response (not corrected) 

if not(length(theta)==2)
    error('Check theta lenght')
end
%%%%%%%%%%%%%%%%%%%%

% define transfer function
num=(1);
den=[theta(1)  theta(2)  1];
Hs=tf(num,den);

% predict output
y_pred=lsim(Hs,u,t);

end
