% % % % % % % % % % % % % % % % % % % % % % % %
% F. Caselli, MSSF A.A. 2020/2021
% % % % % % % % % % % % % % % % % % % % % % % %

function E=obj_fun(theta,y,u,t)
% evaluate objective function value (E) corresponding to given parameter
% values (theta) in the state-space formulation of the linear lung
% mechanics model

% predicted output (output corresponding to the given guessed parameter values)
y_pred=rlc_fun(theta,u,t);

% error
e=y-y_pred; % y_pred-y
% objective function
E=1/2*sum(e.^2);
% E=1/2*norm(e);

end
