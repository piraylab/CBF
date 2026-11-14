function fit_mle_comparison(started)
%FIT_MLE_COMPARISON Human native-space MLE/BIC; separate from MAP recovery.
if nargin<1,started=tic;end
p=cbf_paths();folder=fullfile(p.results,'mle');if ~exist(folder,'dir'),mkdir(folder);end
a=load_behavior(1);b=load_behavior(2);data=[a(:);b(:)];
signature=fit_model_signature();
model_code=fileread(which('bird_cbf_native'));fitter_code=fileread([mfilename('fullpath') '.m']);checkpoint=fullfile(folder,'inputs.mat');
if exist(checkpoint,'file')
    old=load(checkpoint);assert(isfield(old,'signature')&&isequaln(old.signature,signature)&&isequaln(old.data,data)&&strcmp(old.model_code,model_code)&&strcmp(old.fitter_code,fitter_code),'MLE data/model/settings changed; move results/mle aside before refitting.');
else
    assert(isempty(dir(fullfile(folder,'subject_*.mat'))),'MLE fit provenance is unrecorded; move results/mle aside before refitting.');
    save(checkpoint,'data','model_code','fitter_code','signature');
end
range=[0 0 0 0;1 .5 1 .5];options=optimoptions('fmincon','Display','off');
for n=1:numel(data)
    filename=fullfile(folder,sprintf('subject_%04d.mat',n));status='reused';
    if ~exist(filename,'file')
        dat=data{n};dat.outcome=dat.bag;
        [parameters,loss,flag]=fmincon(@(x)objective(x,dat),median(range),[],[],[],[],range(1,:),range(2,:),[],options);
        log_evidence=-loss-.5*4*log(numel(dat.bucket));
        save(filename,'parameters','log_evidence','flag');status='fitted';
    end
    f=load(filename);mle.parameters(n,:)=f.parameters;mle.log_evidence(n,1)=f.log_evidence;mle.flag(n,1)=f.flag;
    elapsed=floor(toc(started));fprintf('Elapsed %02d:%02d:%02d | MLE: %s subject %d/%d.\n',floor(elapsed/3600),floor(mod(elapsed,3600)/60),mod(elapsed,60),status,n,numel(data));
end
mle.protocol='Fresh human MLE/BIC, M10, eps + 1 + 69*q, native [mu_v,eta_v,mu_s,eta_s], no prior, median start';
save(fullfile(folder,'aggregate.mat'),'mle','model_code','fitter_code','signature');
if any(mle.flag<=0),warning('%d MLE optimizations did not report convergence; inspect saved flags before reporting.',sum(mle.flag<=0));end
end
function loss=objective(x,data)
value=bird_cbf_native(x,data,0);
loss=.5*sum((value(:)-double(data.bucket(:))).^2)+.5*log(2*pi);
end
