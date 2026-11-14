function p = cbf_paths()
%CBF_PATHS Resolve data and results relative to this checkout.
p.root = fileparts(fileparts(mfilename('fullpath')));
p.data = fullfile(p.root,'data');
p.results = fullfile(p.root,'results');
end
