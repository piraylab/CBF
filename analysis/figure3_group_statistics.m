function [group_table, tests] = figure3_group_statistics(theta, rbpf_rates, groups)
%FIGURE3_GROUP_STATISTICS Compute Figure 3 summaries and contrasts from fits.
vb = groups.vol_blind;
sb = groups.sto_blind;
assert(height(groups)==size(theta,1) && height(groups)==size(rbpf_rates,1), ...
    'Group and fit rows must match.');

raw_dispersion = theta(:,3:4);
eta = .5./(1+exp(-raw_dispersion));
% Preserve the original display scale and test the RBPF rates on their native scale.
rbpf_display = 1./(1+exp(-rbpf_rates));
values = {eta, rbpf_display};
models = ["CBF"; "RBPF"];
names = ["Volatility"; "Stochasticity"];
group_labels = ["Volatility-blind"; "Stochasticity-blind"];
group_table = table();
for k = 1:2
    v = values{k};
    means = [mean(v(vb,:)); mean(v(sb,:))];
    sem = [std(v(vb,:))/sqrt(sum(vb)); std(v(sb,:))/sqrt(sum(sb))];
    group_table = [group_table; table(repmat(models(k),4,1), repelem(group_labels,2), ...
        repmat(names,2,1), reshape(means',[],1), reshape(sem',[],1), ...
        'VariableNames',{'model','group','parameter','mean','sem'})];
end

scales = {raw_dispersion, eta, rbpf_rates};
labels = ["CBF unconstrained y";"CBF transformed eta"; "RBPF native mu"];
tests = table();
for s = 1:numel(scales)
    for k = 1:2
        a = scales{s}(vb,k);
        b = scales{s}(sb,k);
        if k==2
            [~,p,~,stats] = ttest2(b,a);
        else
            [~,p,~,stats] = ttest2(a,b);
        end
        tests = [tests; table(labels(s), names(k), stats.tstat, stats.df, p, ...
            'VariableNames',{'scale','parameter','t_paper_direction','df','p'})];
    end
end
end
