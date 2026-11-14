function [val, parameters_transformed] = bird_cbf_native(parameters, data, transform)
%BIRD_CBF_NATIVE MLE adapter: [mu_v, eta_v, mu_s, eta_s].
if nargin<3, transform = 1; end
    
outcome = data.outcome;

if transform
    eps_sigmoid = 1e-6;
    sigmoid = @(x)(1-eps_sigmoid)./(1+exp(-x)) + eps_sigmoid;
    u_vol = sigmoid(parameters(1));
    v_vol = sigmoid(parameters(2))/2;
    u_sto = sigmoid(parameters(3));
    v_sto = sigmoid(parameters(4))/2;
else
    u_vol = parameters(1);
    v_vol = parameters(2);
    u_sto = parameters(3);
    v_sto = parameters(4);
end

% Use the shared filter and standard defaults; keep the native [mu_v, eta_v, mu_s, eta_s] order.
parameters_transformed = [u_vol, v_vol, u_sto, v_sto];
config = make_drl_config({[0 0 1],[0 0 1]},'predict');
config.native_parameters = parameters_transformed;
[~, val] = distr_model_p(outcome, config);
end
