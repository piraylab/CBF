function report=retry_mle_nonconverged()
%RETRY_MLE_NONCONVERGED Continue flagged MLE fits; preserve original checkpoints.
% Same model/objective/bounds/interior-point tolerances; central differences.
setup;p=cbf_paths();folder=fullfile(p.results,'mle');
f=load(fullfile(folder,'aggregate.mat'));
assert(isequaln(f.signature,fit_model_signature()) ...
    && strcmp(f.model_code,fileread(which('bird_cbf_native'))) ...
    && strcmp(f.fitter_code,fileread(which('fit_mle_comparison'))), ...
    'MLE model or fitting settings changed. Move results/mle aside and refit.');
mle=f.mle;
failed=find(mle.flag<=0);report=table();
if isempty(failed),fprintf('All saved MLE fits have positive exit flags; no retries needed.\n');return;end
a=load_behavior(1);b=load_behavior(2);data=[a(:);b(:)];
inputs=load(fullfile(folder,'inputs.mat'),'data');
assert(isequaln(inputs.data,data),'MLE subject inputs changed; do not reuse these fits.');
backup=fullfile(folder,'retry_history',char(datetime('now','TimeZone','America/New_York','Format','yyyyMMdd_HHmmss')));
mkdir(backup);copyfile(fullfile(folder,'aggregate.mat'),fullfile(backup,'aggregate_before.mat'));
options=optimoptions('fmincon','Display','off','FiniteDifferenceType','central', ...
    'MaxFunctionEvaluations',20000,'MaxIterations',2000);
started=tic;
for j=1:numel(failed)
    n=failed(j);filename=fullfile(folder,sprintf('subject_%04d.mat',n));previous=load(filename);
    if previous.flag>0,continue;end % A prior interrupted retry may already have saved it.
    dat=data{n};dat.outcome=dat.bag;
    objective=@(x).5*sum((reshape(bird_cbf_native(x,dat,0),[],1)-double(dat.bucket(:))).^2)+.5*log(2*pi);
    old_loss=objective(previous.parameters);
    [parameters,loss,flag,output]=fmincon(objective,previous.parameters,[],[],[],[],[0 0 0 0],[1 .5 1 .5],[],options);
    attempt=struct('subject',n,'previous',previous,'parameters',parameters, ...
        'old_loss',old_loss,'loss',loss,'flag',flag,'output',output,'options',options, ...
        'matlab_version',version,'platform',computer,'retry_code',fileread([mfilename('fullpath') '.m']));
    save(fullfile(backup,sprintf('attempt_%04d.mat',n)),'attempt');
    accepted=flag>0&&isfinite(loss)&&loss<=old_loss;
    if accepted
        copyfile(filename,fullfile(backup,sprintf('subject_%04d_before.mat',n)));
        result=previous;result.parameters=parameters;result.flag=flag;
        result.log_evidence=-loss-.5*4*log(numel(dat.bucket));
        result.retry=rmfield(attempt,{'previous','parameters','options','retry_code'});
        result.retry.attempt_file=fullfile(backup,sprintf('attempt_%04d.mat',n));
        save(filename,'-struct','result');
    end
    report=[report;table(n,previous.flag,flag,old_loss,loss,accepted, ...
        'VariableNames',{'subject','previous_flag','retry_flag','previous_loss','retry_loss','accepted'})];
    fprintf('Elapsed %.1fs | MLE retry: subject %d/%d, flag %d, accepted %d.\n',toc(started),n,numel(data),flag,accepted);
end
% Refresh aggregate from saved checkpoints, including any interrupted prior retry.
f=load(fullfile(folder,'aggregate.mat'));
for n=1:numel(data)
    s=load(fullfile(folder,sprintf('subject_%04d.mat',n)));
    f.mle.parameters(n,:)=s.parameters;f.mle.log_evidence(n,1)=s.log_evidence;f.mle.flag(n,1)=s.flag;
end
f.mle.retry_policy='Only nonpositive flags continued from saved estimates using central finite differences, unchanged interior-point tolerances, MaxFunctionEvaluations=20000, MaxIterations=2000; original files/diagnostics in retry_history';
f.mle.protocol=[f.mle.protocol '; targeted nonconverged-fit continuation with central finite differences'];
save(fullfile(folder,'aggregate.mat'),'-struct','f');
writetable(report,fullfile(backup,'retry_summary.csv'));disp(report);
fprintf('Original fits and retry diagnostics: %s\n',backup);
if any(f.mle.flag<=0)
    warning('%d MLE fits still have nonpositive exit flags; inspect retry_history before reporting.',sum(f.mle.flag<=0));
else
    fprintf('All %d MLE fits now have positive exit flags. Run analyze_all.\n',numel(data));
end
end
