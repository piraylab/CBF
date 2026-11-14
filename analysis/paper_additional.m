function summary = paper_additional(source)
%PAPER_ADDITIONAL Figure 3 comparison and additional CBF analyses.
arguments
    source (1,:) char {mustBeMember(source,{'refit'})} = 'refit'
end
p=cbf_paths();summary=struct();
if ~exist(p.results,'dir'),mkdir(p.results);end
[data,theta,metrics]=replay_cbf(source);human=behavior_learning_rates(data);
groups=behavior_groups(human);vb=groups.vol_blind==1;sb=groups.sto_blind==1;
writetable(groups,fullfile(p.results,'behavior_groups.csv'));
mu=1./(1+exp(-theta(:,1:2)));
model_lr=squeeze(mean(metrics.lr,1))';contrast=[-1 1 -1 1;-1 -1 1 1]';
H=human*contrast;C=model_lr*contrast;
names=["Volatility";"Stochasticity"];
for k=1:2
    effect=H(:,k)/2;
    [~,behavior_p(k,1),~,st]=ttest(effect);
    behavior_mean(k,1)=mean(effect);behavior_sem(k,1)=std(effect)/sqrt(numel(effect));
    behavior_t(k,1)=st.tstat;behavior_df(k,1)=st.df;
end
summary.behavior_effects=emit(table(names,behavior_mean,behavior_sem,behavior_t,behavior_df,behavior_p, ...
    'VariableNames',{'effect','mean','sem','t','df','p'}),p,'behavior_main_effects',source);
fprintf('  Additional: full cross-over figure and tests.\n');
[group_table,tests]=figure3_group_statistics(theta,load_rbpf_rates(),groups);
plot_group_comparison(group_table);
export_plot(p,'figure3_models',source);
summary.figure3_rbpf_scale='Sigmoid of bundled native RBPF rates; group tests use native rates';
summary.groups=emit(group_table,p,'figure3_models',source);
summary.group_tests=emit(tests,p,'figure3_models_tests',source);
effect_r=diag(corr(H,C,'Type','Pearson'));
summary.model_human=emit(table(repmat("CBF",2,1),names,effect_r, ...
    'VariableNames',{'model','effect','pearson_r'}),p,'model_human_effects',source);
fprintf('  Additional: continuous associations and mu distributions.\n');
for k=1:2
    [rho(k,1),pv(k,1)]=corr(theta(:,k+2),H(:,k),'Type','Spearman');
    [partial(k,1),pp(k,1)]=partialcorr(theta(:,k+2),H(:,k),mu(:,k),'Type','Spearman');
end
summary.continuous=emit(table(names,rho,pv,partial,pp,'VariableNames',{'parameter','spearman_r','p','partial_r','partial_p'}),p,'continuous_behavior',source);
[off_r,off_p]=corr(theta(:,3),H(:,2),'Type','Spearman');
summary.off_dimension=emit(table(off_r,off_p,'VariableNames',{'eta_v_vs_stochasticity_r','p'}),p,'off_dimension',source);
labels=["Volatility-blind";"Rest (not volatility-blind)";"Stochasticity-blind";"Rest (not stochasticity-blind)"];
masks={vb,~vb,sb,~sb};distribution=table();
for g=1:4
    for k=1:2
        x=mu(masks{g},k);q=prctile(x,[25 75]);
        distribution=[distribution;table(labels(g),names(k),numel(x),mean(x),std(x)/sqrt(numel(x)),median(x),min(x),q(1),q(2),max(x),'VariableNames',{'group','mu_parameter','n','mean','sem','median','min','q25','q75','max'})];
    end
end
summary.mu_distributions=emit(distribution,p,'mu_distributions',source);
fprintf('  Additional: grid and support sensitivity.\n');
if analysis_inputs_available('sensitivity')
    f=load(fullfile(p.results,'sensitivity','aggregate.mat'));
    assert(isequaln(f.signature,fit_model_signature()) ...
        && strcmp(f.fitter_code,fileread(which('fit_sensitivity'))), ...
        'Sensitivity model or fitting settings changed. Move results/sensitivity aside and refit.');
    cases=f.cases;
    baseline=find([cases.M]==10 & [cases.upper]==70);
    assert(isscalar(baseline) && cases(baseline).lower==1 ...
        && isequaln(cases(baseline).parameters,theta), ...
        'Sensitivity baseline differs from the current standard fits. Rerun fit_sensitivity.');
    sensitivity=table();sensitivity_tests=table();
    for a=1:numel(cases)
        c=cases(a);v=.5./(1+exp(-c.parameters(:,3:4)));
        for k=1:2
            for g=1:2
                mask=vb;if g==2,mask=sb;end
                x=v(mask,k);sensitivity=[sensitivity;table(string(c.label),c.M,c.lower,c.upper,g,names(k),numel(x),mean(x),std(x)/sqrt(numel(x)),'VariableNames',{'fit_set','M','lower','upper','group','eta_parameter','n','mean','sem'})];
            end
            % Test on the unconstrained y scale (Appendix E), in the paper's directions.
            x=c.parameters(vb,k+2);y=c.parameters(sb,k+2);
            if k==2,temporary=x;x=y;y=temporary;end
            [~,pv_case,~,st]=ttest2(x,y);
            sensitivity_tests=[sensitivity_tests;table(string(c.label),c.M,c.lower,c.upper,names(k),st.tstat,st.df,pv_case, ...
                'VariableNames',{'fit_set','M','lower','upper','parameter','t_paper_direction','df','p'})];
        end
    end
    summary.sensitivity=emit(sensitivity,p,'sensitivity',source);
    summary.sensitivity_tests=emit(sensitivity_tests,p,'sensitivity_tests',source);
end
summary.fit_source=source;
summary.rbpf_source='Bundled Bird Task RBPF parameter exports';
save(fullfile(p.results,['additional_summary_' source '.mat']),'summary');
end
function value=emit(value,p,name,source)
writetable(value,fullfile(p.results,[name '_' source '.csv']));disp(value);
end
function export_plot(p,name,source)
axes_list=findall(gcf,'Type','axes');for k=1:numel(axes_list),axes_list(k).Toolbar.Visible='off';end
exportgraphics(gcf,fullfile(p.results,[name '_' source '.png']),'Resolution',200);
exportgraphics(gcf,fullfile(p.results,[name '_' source '.pdf']),'ContentType','vector');
end
