function root = setup()
%SETUP Add this checkout's code folders to the MATLAB path.
root = fileparts(mfilename('fullpath'));
addpath(root, fullfile(root,'model'), fullfile(root,'analysis'), ...
    fullfile(root,'fitting'), fullfile(root,'support'), fullfile(root,'cbm'));
for name = {'distr_model_p','model_dRL_p','make_drl_config'}
    assert(strcmp(which(name{1}),fullfile(root,'model',[name{1} '.m'])), ...
        'Another file shadows %s. Start MATLAB in this checkout and rerun setup.',name{1});
end
assert(strcmp(which('cbm_lap'),fullfile(root,'cbm','cbm_lap.m')), ...
    'Another file shadows the bundled cbm_lap. Start MATLAB in this checkout and rerun setup.');
end
