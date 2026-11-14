function fit_subjects(data, folder, started)
%FIT_SUBJECTS Serial MAP fitting with original CBM priors and initializations.
% Individual files permit resuming this exact model and data.
if nargin<3, started=tic; end
if ~exist(folder,'dir'), mkdir(folder); end
prior=struct('mean',zeros(1,4),'variance',6.25*ones(1,4));
config=struct('numinit',10,'range',[-3 -3 -3 -3;3 3 3 3],'verbose',0);
signature=fit_model_signature();
checkpoint=fullfile(folder,'fit_inputs.mat');
if exist(checkpoint,'file')
    check_fit_model(folder);
    previous=load(checkpoint,'data','prior','config');
    assert(isequaln(previous.data,data) && isequaln(previous.prior,prior) && isequaln(previous.config,config), ...
        'Fit data or settings changed. Move %s aside before running fit_all.',folder);
else
    assert(isempty(dir(fullfile(folder,'subject_*.mat'))) && ~exist(fullfile(folder,'aggregate.mat'),'file'), ...
        'Fit model is unrecorded. Move %s aside before running fit_all.',folder);
    save(checkpoint,'data','prior','config','signature');
end
[~,label]=fileparts(folder);
files=cell(numel(data),1);
for n=1:numel(data)
    files{n}=fullfile(folder,sprintf('subject_%04d.mat',n));
    if ~exist(files{n},'file')
        rng(n,'twister');
        cbm_lap(data(n),@model_dRL_p,prior,files{n},config);
        status='fitted';
    else
        status='reused';
    end
    fitted = load(files{n},'cbm');
    assert(all(fitted.cbm.profile.optim.flag > 0), ...
        'No fitted optimum in %s. Inspect and move this failed file before retrying.', files{n});
    elapsed=floor(toc(started));
    fprintf('Elapsed %02d:%02d:%02d | %s: %s subject %d/%d.\n', ...
        floor(elapsed/3600),floor(mod(elapsed,3600)/60),mod(elapsed,60),label,status,n,numel(data));
end
cbm_lap_aggregate(files,fullfile(folder,'aggregate.mat'));
end
