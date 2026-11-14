function summary = plot_parameter_recovery(theta, recovered, output_base)
%PLOT_PARAMETER_RECOVERY Plot true and fitted coordinates for simulated agents.
assert(isequal(size(theta),size(recovered)),'Recovery matrix size mismatch.');
actual=1./(1+exp(-theta)); estimated=1./(1+exp(-recovered));
actual(:,3:4)=actual(:,3:4)/2; estimated(:,3:4)=estimated(:,3:4)/2;
names={'mu_v','mu_s','eta_v','eta_s'}; rho=zeros(4,1);pearson_r=zeros(4,1);
labels={'\mu_v','\mu_s','\eta_v','\eta_s'};
figure('Color','w','Units','inches','Position',[1 1 7.1 2.3]);
tiledlayout(1,4,'TileSpacing','compact','Padding','compact');
for k=1:4
    rho(k)=corr(actual(:,k),estimated(:,k),'Type','Spearman');
    pearson_r(k)=corr(actual(:,k),estimated(:,k),'Type','Pearson');
    ax=nexttile; ax.Toolbar.Visible='off'; hold on;
    upper=1; if k>2, upper=.5; end
    plot([0 upper],[0 upper],'--','Color',[.64 .66 .69],'LineWidth',.8);
    scatter(actual(:,k),estimated(:,k),14,[.30 .40 .60],'filled', ...
        'MarkerFaceAlpha',.8,'MarkerEdgeColor','w','LineWidth',.25);
    xlim([0 upper]); ylim([0 upper]); axis square;
    xticks([0 upper/2 upper]); yticks([0 upper/2 upper]);
    set(ax,'FontName','Helvetica','FontSize',8,'LineWidth',.75, ...
        'Box','off','TickDir','out');
    xlabel('True value','FontSize',9); ylabel('Recovered value','FontSize',9);
    title(labels{k},'Interpreter','tex','FontSize',12,'FontWeight','normal');
    text(.04,.95,sprintf('r = %.2f',rho(k)),'Units','normalized', ...
        'VerticalAlignment','top','FontSize',9);
end
summary=table(string(names)',rho,pearson_r,'VariableNames',{'parameter','rho','pearson_r'}); disp(summary);
writetable(summary,[output_base '.csv']);
exportgraphics(gcf,[output_base '.png'],'Resolution',300);
exportgraphics(gcf,[output_base '.pdf'],'ContentType','vector');
end
