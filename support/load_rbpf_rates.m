function rates = load_rbpf_rates()
%LOAD_RBPF_RATES Read bundled native update rates in experiment order.
p = cbf_paths();
expected = [223 420];
experiment = cell(2,1);
for e = 1:2
    filename = fullfile(p.root,'fits',sprintf('rbpf_experiment%d.csv',e));
    fits = readtable(filename);
    assert(height(fits)==expected(e),'Expected %d RBPF fit rows in %s.',expected(e),filename);
    experiment{e} = fits{:,{'mu_v','mu_s'}};
end
rates = vertcat(experiment{:});
end
