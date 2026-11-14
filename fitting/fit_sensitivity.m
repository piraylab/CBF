function fit_sensitivity(started)
%FIT_SENSITIVITY Four additional M/support settings; reuse standard M10/max70.
if nargin<1,started=tic;end
baseline=load_fit_parameters('refit'); % Require current standard fits before any extra fitting.
p=cbf_paths();a=load_behavior(1);b=load_behavior(2);data=[a(:);b(:)];
settings=[5 70;10 50;10 70;10 100;20 70];signature=fit_model_signature();
fitter_code=fileread([mfilename('fullpath') '.m']);
prior=struct('mean',zeros(1,4),'variance',6.25*ones(1,4));
config=struct('numinit',10,'range',[-3 -3 -3 -3;3 3 3 3],'verbose',0);
for k=1:5
    M=settings(k,1);upper=settings(k,2);
    cases(k)=struct('label',sprintf('fresh_M%d_max%d',M,upper),'M',M,'lower',1,'upper',upper,'parameters',[]);
    if M==10&&upper==70,cases(k).parameters=baseline;continue;end
    folder=fullfile(p.results,'sensitivity',sprintf('M%d_max%d',M,upper));if ~exist(folder,'dir'),mkdir(folder);end
    checkpoint=fullfile(folder,'inputs.mat');
    if exist(checkpoint,'file')
        old=load(checkpoint);assert(isequaln(old.data,data)&&isequaln(old.signature,signature)&&strcmp(old.fitter_code,fitter_code),'Sensitivity inputs changed; move %s aside before refitting.',folder);
    else
        assert(isempty(dir(fullfile(folder,'subject_*.mat'))),'Sensitivity fit provenance is unrecorded; move %s aside before refitting.',folder);
        save(checkpoint,'data','signature','fitter_code','M','upper','prior','config');
    end
    for n=1:numel(data)
        filename=fullfile(folder,sprintf('subject_%04d.mat',n));status='reused';
        if ~exist(filename,'file')
            seed=n;if n>223,seed=n-223;end % Same within-experiment starts as standard fitting.
            rng(seed,'twister');cbm_lap(data(n),@(x,d)loglik(x,d,M,upper),prior,filename,config);status='fitted';
        end
        f=load(filename,'cbm');assert(all(f.cbm.profile.optim.flag>0),'No fitted optimum in %s.',filename);
        cases(k).parameters(n,:)=f.cbm.output.parameters;
        elapsed=floor(toc(started));fprintf('Elapsed %02d:%02d:%02d | M%d/max%d: %s subject %d/%d.\n',floor(elapsed/3600),floor(mod(elapsed,3600)/60),mod(elapsed,60),M,upper,status,n,numel(data));
    end
end
save(fullfile(p.results,'sensitivity','aggregate.mat'),'cases','signature','fitter_code');
end
function value=loglik(x,data,M,upper)
cfg=make_drl_config({[x(1) x(3) 1],[x(2) x(4) 1]},'fit');
cfg.num_neurons=M;cfg.init_range={[1 upper],[1 upper]};cfg.subj=data.bucket;
[~,~,ll]=distr_model_p(data.bag,cfg);value=sum(ll);
end
