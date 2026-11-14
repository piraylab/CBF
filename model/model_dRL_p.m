function [loglik] = model_dRL_p(parameters,subj)
    if isstruct(subj)
        outcome = subj.bag;
        subj_bucket = subj.bucket;
    else
        error('model_dRL_p expects subject data with fields "bag" and "bucket".');
    end

    mean_v = parameters(1); %
    mean_s = parameters(2); %

    var_v = parameters(3); % 
    var_s = parameters(4); % 

    M = 10;
    max_v = 70.0;
    max_s = 70.0;
    min_v = 1.0;
    min_s = 1.0;
    config = struct();
    config.init = 'direct';
    config.num_neurons = M;
    config.init_range = {[min_v, max_v], [min_s, max_s]};
    config.prior = {[mean_v, var_v, 1], [mean_s, var_s, 1]};
    config.mode = "fit";
    config.subj = subj_bucket;

    [~, ~, ll] = distr_model_p(outcome, config);
    loglik = sum(ll);
    % disp(ll);
    
end
