function run_recovery(started)
%RUN_RECOVERY Generate, fit or resume 100-agent MAP recovery with the default model.
% As in the original source, synthetic predictions have no added response noise.
if nargin<1, started=tic; end
p=cbf_paths(); folder=fullfile(p.results,'recovery');
if ~exist(folder,'dir'), mkdir(folder); end
filename=fullfile(folder,'simulation.mat');
signature=fit_model_signature();
if exist(filename,'file')
    f=load(filename,'data','params','signature');
    assert(isfield(f,'signature') && isequaln(f.signature,signature), ...
        'Recovery model changed or is unrecorded. Move %s aside before running fit_all.',folder);
    data=f.data; params=f.params;
else
    rng(40,'twister'); params=-3+6*rand(100,4);
    human=load_behavior(1); outcome=human{1}.bag; data=cell(100,1);
    for n=1:100
        t=params(n,:); cfg=make_drl_config({[t(1),t(3),1],[t(2),t(4),1]},'sim');
        [~,bucket]=distr_model_p(outcome,cfg);
        data{n}=struct('bag',outcome,'bucket',bucket);
    end
    save(filename,'data','params','signature');
end
fit_subjects(data,folder,started);
fprintf('Recovery fits saved. Run analyze_all to generate figures and tables.\n');
end
