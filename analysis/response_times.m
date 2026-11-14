function summary = response_times(fit_source)
%RESPONSE_TIMES Table 2, using original five-predictor per-subject RT regression.
% Preserve source preprocessing: remove within-subject |z(RT)|>5, center RT,
% z-score each predictor after that removal, then exclude nonfinite rows.
arguments
    fit_source (1,:) char {mustBeMember(fit_source,{'refit'})} = 'refit'
end
[data,~,m] = replay_cbf(fit_source);
N = numel(data); beta = nan(N,5); counts = zeros(N,1);
for n = 1:N
    rt = double(data{n}.response_time(:));
    cols = {m.likelihood_std(:,:,n),m.likelihood_mean(:,:,n), ...
        m.prediction_error(:,:,n).^2,m.vol(:,:,n),m.sto(:,:,n)};
    X = zeros(numel(rt),5);
    for k = 1:5, X(:,k) = cols{k}(:); end
    zrt = local_zscore(rt);
    keep = ~(abs(zrt)>5);
    rt = rt(keep); X = X(keep,:);
    rt = rt-mean(rt,'omitnan');
    for k = 1:5, X(:,k) = local_zscore(X(:,k)); end
    valid = isfinite(rt)&all(isfinite(X),2);
    counts(n) = sum(valid);
    lm = fitlm(X(valid,:),rt(valid));
    beta(n,:) = lm.Coefficients.Estimate(2:end)';
end
names = ["Likelihood standard deviation";"Likelihood mean";"Squared prediction error"; ...
    "Estimated volatility";"Estimated stochasticity"];
t = nan(5,1); pvalue=t; df=t;
for k=1:5
    [~,pvalue(k),~,st] = ttest(beta(:,k)); t(k)=st.tstat; df(k)=st.df;
end
summary = table(names,mean(beta,1)',t,df,pvalue,'VariableNames',{'predictor','beta','t','df','p'});
disp(summary);
p=cbf_paths(); if ~exist(p.results,'dir'), mkdir(p.results); end
writetable(summary,fullfile(p.results,['table2_' fit_source '.csv']));
save(fullfile(p.results,['rt_coefficients_' fit_source '.mat']),'beta','counts','fit_source');
end
function z = local_zscore(x)
s = std(x,0,'omitnan');
if ~isfinite(s) || s==0, z=zeros(size(x)); else, z=(x-mean(x,'omitnan'))/s; end
z(~isfinite(x))=NaN;
end
