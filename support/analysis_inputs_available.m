function available = analysis_inputs_available(component)
%ANALYSIS_INPUTS_AVAILABLE Check for completed fits in this checkout.
p = cbf_paths();
switch component
    case 'standard'
        files = {fullfile(p.data,'experiment1','data.mat'), ...
                 fullfile(p.data,'experiment2','data.mat')};
        for e = 1:2
            folder = fullfile(p.results,'fits',sprintf('experiment%d',e));
            files = [files, {fullfile(folder,'aggregate.mat'), fullfile(folder,'fit_inputs.mat')}];
        end
    case 'recovery'
        folder = fullfile(p.results,'recovery');
        files = {fullfile(folder,'simulation.mat'), fullfile(folder,'aggregate.mat'), ...
                 fullfile(folder,'fit_inputs.mat')};
    case 'sensitivity'
        files = {fullfile(p.results,'sensitivity','aggregate.mat')};
end
missing = find(~cellfun(@isfile,files),1);
available = isempty(missing);
if ~available
    fprintf('Skipping %s analysis. Missing %s\n',component,files{missing});
end
end
