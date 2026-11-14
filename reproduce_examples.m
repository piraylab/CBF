function reproduce_examples()
%REPRODUCE_EXAMPLES Recreate figures without participant-level data.
setup;
p=cbf_paths();
inputs=fullfile(p.root,'examples');
output=fullfile(p.results,'examples');
if ~isfolder(output),mkdir(output);end

fprintf('Figure 1: generating synthetic dynamics.\n');
figure1_dynamics;

fprintf('Figure 2: plotting saved synthetic recovery parameters.\n');
pairs=readmatrix(fullfile(inputs,'recovery_parameters.csv'));
plot_parameter_recovery(pairs(:,1:4),pairs(:,5:8),fullfile(output,'figure2_recovery'));

fprintf('Figure 3: plotting saved aggregate means and standard errors.\n');
groups=readtable(fullfile(inputs,'figure3_models_refit.csv'),'TextType','string');
fig=plot_group_comparison(groups);
exportgraphics(fig,fullfile(output,'figure3_groups.png'),'Resolution',200);
exportgraphics(fig,fullfile(output,'figure3_groups.pdf'),'ContentType','vector');

fprintf('Figure 1 saved in %s\n',p.results);
fprintf('Figures 2 and 3 saved in %s\n',output);
fprintf('Saved aggregate tables are in %s\n',inputs);
end
