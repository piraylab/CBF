function config = make_drl_config(true_param, config_mode)
%MAKE_DRL_CONFIG Build a standard dRL config struct for predict/sim workflows.
%   CONFIG = MAKE_DRL_CONFIG(TRUE_PARAM, CONFIG_MODE) constructs the
%   standard configuration used throughout this repository when replaying fitted
%   parameters or generating simulated trajectories.

    M = 10;
    config = struct();
    config.init = 'direct';
    config.num_neurons = M;
    config.init_range = {[1.0, 70.0], [1.0, 70.0]};
    config.prior = true_param;
    config.mode = config_mode;
end
