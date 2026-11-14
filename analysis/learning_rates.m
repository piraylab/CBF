function summary = learning_rates(fit_source)
%LEARNING_RATES Across-subject average and condition-level CBF correlations.
% The average is a Spearman correlation across subjects between the mean of
% four empirical block-regression slopes and the mean model learning rate.
% Uses the completed standard CBF fits in results/.
arguments
    fit_source (1,:) char {mustBeMember(fit_source,{'refit'})} = 'refit'
end
[data,~,m] = replay_cbf(fit_source);
human = behavior_learning_rates(data);
model = reshape(mean(m.lr,1),4,[])';
labels = ["Across-subject average"; "Low V, low S"; "High V, low S"; ...
    "Low V, high S"; "High V, high S"];
H = [mean(human,2),human];
M = [mean(model,2),model];
rho = nan(5,1); pvalue = rho; n = rho;
for k = 1:5
    x=H(:,k); y=M(:,k);
    valid = isfinite(x)&isfinite(y);
    n(k)=sum(valid);
    [rho(k),pvalue(k)] = corr(x(valid),y(valid),'Type','Spearman');
end
summary = table(labels,rho,pvalue,n); disp(summary);
p = cbf_paths();
if ~exist(p.results,'dir'), mkdir(p.results); end
writetable(summary,fullfile(p.results,['learning_rates_' fit_source '.csv']));
end
