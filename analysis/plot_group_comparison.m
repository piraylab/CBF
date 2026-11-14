function fig = plot_group_comparison(group_table)
%PLOT_GROUP_COMPARISON Draw Figure 3 from group means and standard errors.
fig=figure('Color','w','Units','inches','Position',[1 1 7.1 3.3]);
tiledlayout(1,2,'TileSpacing','loose','Padding','compact');
models={'CBF','RBPF'};
for k=1:2
    ax=nexttile; ax.Toolbar.Visible='off';
    rows=string(group_table.model)==models{k};
    means=reshape(group_table.mean(rows),2,2)';
    sem=reshape(group_table.sem(rows),2,2)';
    bars=bar(means',.75);hold on;
    colors=[.70 .27 .10;.30 .40 .60];
    for g=1:2,bars(g).FaceColor=colors(g,:);bars(g).EdgeColor='none';end
    for g=1:2
        errorbar(bars(g).XEndPoints,means(g,:),sem(g,:),'k', ...
            'LineStyle','none','LineWidth',1.05,'CapSize',6);
    end
    set(ax,'FontName','Helvetica','FontSize',11,'LineWidth',.85, ...
        'Box','off','TickDir','out');
    xticks(1:2);xlim([.5 2.5]);ylabel('Parameter value','FontSize',12);
    title(models{k},'FontSize',15,'FontWeight','bold');
    if k==1,xticklabels({'\eta_v','\eta_s'});ylim([0 .55]);yticks(0:.1:.5);
    else,xticklabels({'{\it v} update rate','{\it s} update rate'});ylim([0 1.05]);yticks(0:.2:1);end
    ax.XAxis.FontSize=12;
    xtickangle(0);
    legend(bars,{'Volatility-blind','Stochasticity-blind'}, ...
        'Location','northwest','Box','off','FontSize',11);
end
end
