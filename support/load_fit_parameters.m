function params = load_fit_parameters(source)
%LOAD_FIT_PARAMETERS Load completed standard CBF fits in experiment order.
arguments
    source (1,:) char {mustBeMember(source,{'refit'})} = 'refit'
end
p=cbf_paths(); params=[];
for e=1:2
    folder=fullfile(p.results,'fits',sprintf('experiment%d',e));
    filename=fullfile(folder,'aggregate.mat');
    assert(exist(filename,'file')==2, ...
        'Missing fit file: %s. Run fit_standard first.',filename);
    check_fit_model(folder);
    f=load(filename,'cbm');
    data=load_behavior(e);
    assert(size(f.cbm.output.parameters,1)==numel(data), ...
        'Fit/data subject count mismatch in experiment %d.',e);
    params=[params; f.cbm.output.parameters]; %#ok<AGROW>
end
end
