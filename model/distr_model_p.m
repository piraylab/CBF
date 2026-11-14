function [lr, val, ll, vol, sto, acv, var, v_particles, s_particles, weights, likelihoods, prediction_errors] = distr_model_p(observations, config)

    if nargin < 2
        error('Not enough input arguments!');
    end

    native_parameters = [];
    if isfield(config,'native_parameters')
        native_parameters = config.native_parameters;
        config = rmfield(config,'native_parameters');
    end

    p = inputParser;
    addParameter(p, 'num_neurons', config.num_neurons);
    addParameter(p, 'init', config.init);
    addParameter(p, 'init_range', config.init_range);
    addParameter(p, 'prior', config.prior);
    addParameter(p, 'mode', config.mode);
    if strcmp(config.mode, 'fit')
        addParameter(p, 'subj', config.subj);
    end
    
    parse(p, config);
    config = p.Results;

    val = nan(size(observations));
    prediction_errors = nan(size(observations));
    for i=1:size(observations,2)
        [lr(:,i), val(:,i), ll(i), vol(:,i), sto(:,i), acv(:, i), var(:,i), v_particles(:,:,i), s_particles(:,:,i), weights(:,:,i), likelihoods(:,:,i), prediction_errors(:, i)] = model_per_block(observations(:,i), config, i, native_parameters);
    end

end

%--------------------------------------------------------------------------
function [lr, val, ll, vol, sto, acv, var, v_particles, s_particles, weights, likelihoods, prediction_error] = model_per_block(observations, config, i, native_parameters)

    N = length(observations); % number of time steps
    M = config.num_neurons;  % number of quantiles

    prior = config.prior;

    eps_sigmoid = 1e-6;
    sigmoid = @(x)(1-eps_sigmoid)./(1+exp(-x)) + eps_sigmoid;

    if isempty(native_parameters)
        u_vol = prior{1}(1);
        v_vol = prior{1}(2);

        u_sto = prior{2}(1);
        v_sto = prior{2}(2);

        u_vol = sigmoid(u_vol);
        u_sto = sigmoid(u_sto);

        v_vol = sigmoid(v_vol)/2;
        v_sto = sigmoid(v_sto)/2;
    else
        u_vol = native_parameters(1);
        v_vol = native_parameters(2);
        u_sto = native_parameters(3);
        v_sto = native_parameters(4);
    end
    alpha_v = eps + u_vol / v_vol;
    beta_v = eps + (1 - u_vol) / v_vol;
    alpha_s = eps + u_sto / v_sto;
    beta_s = eps + (1 - u_sto) / v_sto;


    init_range = config.init_range;
    min_v = init_range{1}(1);
    max_v = init_range{1}(2);
    min_s = init_range{2}(1);
    max_s = init_range{2}(2);

    if strcmp(config.init, 'direct')
        vs_init = config.init_range;
        quantiles = linspace(0.005, 0.995, M);

        v = linspace(vs_init{1}(1), vs_init{1}(2), M);
        s = linspace(vs_init{2}(1), vs_init{2}(2), M);

        if prior{1}(3) == 1
            v = eps + min_v + (max_v - min_v) * betainv(quantiles, alpha_v, beta_v);
        end
        if prior{2}(3) == 1
            s = eps + min_s + (max_s - min_s) * betainv(quantiles, alpha_s, beta_s);
        end

        [v_, s_] = meshgrid(v, s);
        v = v_(:);
        s = s_(:);
        
    else
        error('Unknown config.init: %s', config.init);
    end
    
    w = 80 * ones(M * M, 1);
    weights = ones(M * M, 1) / (M * M);
    m = 60 * ones(M * M, 1);
    
    val = nan(N, 1);
    vol = nan(N, 1);
    sto = nan(N, 1);
    lr = nan(N, 1);

    acv = nan(N, 1);
    var = nan(N, 1);

    % Storage for particles and weights at each trial
    v_particles = nan(N, M*M);
    s_particles = nan(N, M*M);
    weights_storage = nan(N, M*M);
    likelihood_storage = nan(N, M*M);
    prediction_error = nan(N, 1);

    mu_obs = 0;
    M2_obs = 0;

    for t=1:size(observations,1)
        val(t) = sum(m.*weights);

        vol(t) = sum(v.*weights);
        sto(t) = sum(s.*weights);
        prediction_error(t) = observations(t) - val(t);

        % Store particles and weights before update
        v_particles(t, :) = v';
        s_particles(t, :) = s';
        weights_storage(t, :) = weights';

        likelihood = normpdf(observations(t),m, sqrt(v+s+w));
        likelihood_storage(t, :) = likelihood';
        [weights] = update_weights(likelihood, weights);

        [m, w, k, delta] = kalman(observations(t),m, w, s, v);
        lr(t) = sum(k.*weights);

        if t>=3
            past_pe_2 = observations(t-2) - val(t-2);
            past_pe_1 = observations(t-1) - val(t-1);
            acv(t) = past_pe_2 * past_pe_1;
        else
            acv(t) = NaN;
        end

        if t == 1
            mu_obs = observations(t);
            var(t) = NaN;  % or 0 if you prefer
        else
            delta = observations(t) - mu_obs;
            mu_obs = mu_obs + delta / t;
            M2_obs = M2_obs + delta * (observations(t) - mu_obs);
            var(t) = M2_obs / (t - 1);  % sample variance
        end

    end

    ll = 1;
    % Compute log likelihood of human predictions
    if strcmp(config.mode, 'fit')
        subj_i = config.subj(:, i);
        ll = -0.5 * sum((subj_i - val).^2);
    end

    % Return stored particles and weights
    weights = weights_storage;
    likelihoods = likelihood_storage;
    vars = struct('val',val,'lr', lr, 'vol', vol, 'sto', sto, 'll', ll, 'acv', acv, 'var', var, 'prediction_error', prediction_error);

end

function [weights] = update_weights(likelihood, weights)
    weights = weights.*(likelihood+eps);
    weights = weights/sum(weights);
end


function [m, w, k, delta]=kalman(outcome, m, w, s, v)
    delta = outcome - m;
    k = (w+v)./(w+v+s);
    m = m + k.*(outcome-m);
    w = (1-k).*(w+v);
end
