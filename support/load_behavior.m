function [data, meta_data] = load_behavior(experiment)
%LOAD_BEHAVIOR Experiment 1: 223 subjects; experiment 2: 420 subjects.
assert(ismember(experiment,[1 2]), 'Experiment must be 1 or 2.');
p = cbf_paths();
filename = fullfile(p.data,sprintf('experiment%d',experiment),'data.mat');
assert(isfile(filename),'Missing Bird Task input: %s. See README.md for download instructions.',filename);
s = load(filename,'data','meta_data');
data = s.data;
meta_data = s.meta_data;
for n = 1:numel(data)
    data{n}.bag = meta_data.bag;
end
end
