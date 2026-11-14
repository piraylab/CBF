function [data, params, metrics] = replay_cbf(fit_source)
%REPLAY_CBF Load or compute a replay with the default model, without any fitting.
arguments
    fit_source (1,:) char {mustBeMember(fit_source,{'refit'})}
end
p = cbf_paths();
data = {};
for e = 1:2
    d = load_behavior(e);
    data = [data; d(:)]; %#ok<AGROW>
end
params = load_fit_parameters(fit_source);
assert(size(params,1)==numel(data),'Fit/data subject count mismatch.');
% Replays depend on fitted parameters, outcome sequences and the model code.
key.params=params;
key.bags=cellfun(@(d) d.bag,data,'UniformOutput',false);
key.model=fileread(which('distr_model_p'));
key.config=fileread(which('make_drl_config'));
key.replay=fileread([mfilename('fullpath') '.m']);
cache_folder=fullfile(p.results,'cache');
cache_file=fullfile(cache_folder,['replay_' fit_source '.mat']);
if exist(cache_file,'file')
    cached=load(cache_file,'key','metrics');
    if isequaln(cached.key,key)
        metrics=cached.metrics;
        fprintf('Using saved CBF replay (%s).\n',fit_source);
        return;
    end
end
fprintf('Computing CBF replay (%s); parameters are not refitted.\n',fit_source);
N = numel(data);
fields = {'lr','vol','sto','likelihood_std','likelihood_mean','prediction_error'};
for k = 1:numel(fields), metrics.(fields{k}) = nan(50,4,N); end
for n = 1:N
    theta = params(n,:);
    cfg = make_drl_config({[theta(1),theta(3),1],[theta(2),theta(4),1]},'predict');
    [lr,~,~,v,s,~,~,~,~,~,lik,pe] = distr_model_p(data{n}.bag,cfg);
    metrics.lr(:,:,n) = lr;
    metrics.vol(:,:,n) = v;
    metrics.sto(:,:,n) = s;
    metrics.likelihood_std(:,:,n) = reshape(std(lik,0,2),50,4);
    metrics.likelihood_mean(:,:,n) = reshape(mean(lik,2),50,4);
    metrics.prediction_error(:,:,n) = pe;
end
if ~exist(cache_folder,'dir'), mkdir(cache_folder); end
save(cache_file,'key','metrics');
end
