function summary = figure2_recovery(source)
%FIGURE2_RECOVERY Spearman recovery of mu_v, mu_s, eta_v, eta_s.
arguments
    source (1,:) char {mustBeMember(source,{'refit'})} = 'refit'
end
p=cbf_paths();
folder = fullfile(p.results,'recovery');
check_fit_model(folder);
simulation = load(fullfile(folder,'simulation.mat'),'params');
fit = load(fullfile(folder,'aggregate.mat'),'cbm');
theta = simulation.params;
recovered = fit.cbm.output.parameters;
if ~exist(p.results,'dir'), mkdir(p.results); end
summary=plot_parameter_recovery(theta,recovered,fullfile(p.results,['figure2_' source]));
end
