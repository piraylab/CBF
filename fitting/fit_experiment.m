function fit_experiment(experiment, started)
%FIT_EXPERIMENT Fit or resume experiment 1 or 2 with M10 and [1,70] support.
% Writes results/fits/experiment<N>; never modifies the bundled fits/ CSVs.
if nargin<2, started=tic; end
data=load_behavior(experiment);
for n=1:numel(data)
    data{n}=struct('bag',data{n}.bag,'bucket',data{n}.bucket);
end
p=cbf_paths();
fit_subjects(data,fullfile(p.results,'fits',sprintf('experiment%d',experiment)),started);
end
