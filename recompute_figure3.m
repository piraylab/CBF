function [group_table, tests] = recompute_figure3()
%RECOMPUTE_FIGURE3 Combine bundled parameters with downloaded Bird Task data.
setup;
p = cbf_paths();
expected = [223 420];
theta = cell(2,1);
human = cell(2,1);
for e = 1:2
    data = load_behavior(e);
    cbf_table = readtable(fullfile(p.root,'fits',sprintf('cbf_experiment%d.csv',e)));
    assert(numel(data)==expected(e) && height(cbf_table)==expected(e), ...
        'Experiment %d data and fits must have %d rows.',e,expected(e));
    theta{e} = cbf_table{:,{'x_v','x_s','y_v','y_s'}};
    human{e} = behavior_learning_rates(data);
end

groups = behavior_groups(vertcat(human{:}));
[group_table, tests] = figure3_group_statistics(vertcat(theta{:}),load_rbpf_rates(),groups);
fig = plot_group_comparison(group_table);
if ~isfolder(p.results), mkdir(p.results); end
base = fullfile(p.results,'figure3_from_fits');
exportgraphics(fig,[base '.pdf'],'ContentType','vector');
exportgraphics(fig,[base '.png'],'Resolution',200);
writetable(group_table,[base '_groups.csv']);
writetable(tests,[base '_tests.csv']);
fprintf('Figure 3 and group statistics saved in %s\n',p.results);
end
