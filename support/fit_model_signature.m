function signature = fit_model_signature()
%FIT_MODEL_SIGNATURE Record the model definition used for fitting and simulation.
names={'distr_model_p','model_dRL_p','make_drl_config'};
for k=1:numel(names)
    signature.(names{k})=fileread(which(names{k}));
end
end
