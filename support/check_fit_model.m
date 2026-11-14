function check_fit_model(folder)
%CHECK_FIT_MODEL Prevent reuse of fits from a different or unrecorded model.
filename=fullfile(folder,'fit_inputs.mat');
assert(exist(filename,'file')==2, ...
    'Fit model is unrecorded. Move %s aside and run fit_all for the current model.',folder);
f=load(filename,'signature');
assert(isfield(f,'signature') && isequaln(f.signature,fit_model_signature()), ...
    'Fit model changed. Move %s aside and run fit_all for the current model.',folder);
end
