function [result, fig] = figure1_dynamics()
%FIGURE1_DYNAMICS Reproduce the synthetic design of Figure 1 / Appendix B.1.
% 50 independent Gaussian random walks per condition, 200 trials, M=20.
% Seed 0 and latent state x_0=60 are explicit reproducibility choices; the
% original figure's seed and initial latent position were not reported.
state = rng;
cleanup = onCleanup(@() rng(state));
rng(0,'twister');

result.seed = 0;
result.initial_state = 60;
result.num_runs = 50;
result.num_trials = 200;
result.true_vol = [20 50 20 50];
result.true_sto = [20 20 50 50];
result.parameters = [0 0 2 2]; % [x_v, x_s, y_v, y_s]
result.config = make_drl_config({[0 2 1],[0 2 1]},'predict');
result.config.num_neurons = 20;
result.config.init_range = {[1 70],[1 70]}; % Figure 1's explicit Appendix B.1 setting.
result.grid_formula = 'eps + lower + (upper-lower) * BetaQuantile';
result.latent = nan(200,4,50);
result.observations = nan(200,4,50);
result.vol = nan(200,4,50);
result.sto = nan(200,4,50);
for run = 1:result.num_runs
    % v and s are variances, so random-walk and observation SDs are sqrt(v/s).
    latent = result.initial_state + cumsum(randn(200,4).*sqrt(result.true_vol),1);
    observations = latent + randn(200,4).*sqrt(result.true_sto);
    [~,~,~,vol,sto] = distr_model_p(observations,result.config);
    result.latent(:,:,run) = latent;
    result.observations(:,:,run) = observations;
    result.vol(:,:,run) = vol;
    result.sto(:,:,run) = sto;
end
result.vol_mean = mean(result.vol,3);
result.sto_mean = mean(result.sto,3);
result.vol_sem = std(result.vol,0,3)/sqrt(result.num_runs);
result.sto_sem = std(result.sto,0,3)/sqrt(result.num_runs);

% Panel pairings and one-row layout match Figure 1 of the paper.
fig = figure('Color','w','Position',[100 100 1500 380]);
layout = tiledlayout(fig,1,4,'TileSpacing','compact','Padding','compact');
means = {result.sto_mean,result.sto_mean,result.vol_mean,result.vol_mean};
sems = {result.sto_sem,result.sto_sem,result.vol_sem,result.vol_sem};
truth = {result.true_sto,result.true_sto,result.true_vol,result.true_vol};
conditions = {[1 3],[2 4],[1 2],[3 4]};
titles = {'(a) Small true volatility','(b) Large true volatility', ...
    '(c) Small true stochasticity','(d) Large true stochasticity'};
colors = {[0 .447 .741; .850 .325 .098],[0 0 0; 1 .2 .6]};
x = (1:result.num_trials)';
for panel = 1:4
    ax = nexttile(layout); hold(ax,'on');
    palette = colors{1+(panel>2)};
    lines = gobjects(2,1);
    for level = 1:2
        condition = conditions{panel}(level);
        mu = means{panel}(:,condition); se = sems{panel}(:,condition);
        fill(ax,[x;flipud(x)],[mu-se;flipud(mu+se)],palette(level,:), ...
            'FaceAlpha',.18,'EdgeColor','none');
        lines(level) = plot(ax,x,mu,'Color',palette(level,:),'LineWidth',1.8);
        yline(ax,truth{panel}(condition),'--','Color',palette(level,:),'LineWidth',1.2);
    end
    title(ax,titles{panel},'FontWeight','normal');
    xlim(ax,[0 200]); ylim(ax,[0 70]); xticks(ax,0:50:200);
    set(ax,'Box','off','TickDir','out','FontName','Arial','FontSize',11);
    if panel<=2, ylabel(ax,'Stochasticity estimate'); else, ylabel(ax,'Volatility estimate'); end
    xlabel(ax,'Trial');
    if panel==1 || panel==3
        lg = legend(ax,lines,{'Small','Large'},'Location','northwest','Box','off');
        if panel==1, title(lg,'True stochasticity'); else, title(lg,'True volatility'); end
    end
end
p = cbf_paths();
if ~exist(p.results,'dir'), mkdir(p.results); end
save(fullfile(p.results,'figure1_dynamics.mat'),'result');
exportgraphics(fig,fullfile(p.results,'figure1_dynamics.png'),'Resolution',300);
exportgraphics(fig,fullfile(p.results,'figure1_dynamics.pdf'),'ContentType','vector');
end
