function [resp, vars] = social_rbpf(parameters, data, mode)


if strcmp(mode, 'config')
    pnames = {'mu', 'beta'};
    mu = optimizableVariable(pnames{1}, [0.5, 1]);
    beta = optimizableVariable(pnames{2}, [0, 100]);
    opt_var = [mu, beta];
    InitialX = array2table( [.5 1; .75 1; 1 1] , 'VariableNames', pnames);  
    rand_func = @(n)[.5+.5*rand(n,1) rand(n, 1)*3];

    resp = nan;
    vars = struct('opt_var', opt_var, 'InitialX', InitialX, 'parameters_name', {pnames}, 'rand_func', rand_func);
    return;
end

outcome = data.outcome;
characters = data.characters;
dimension = data.dimension;

[resp, vars] = pf_process(parameters, outcome, dimension, characters, mode);

end

function [particles] = transition_func(particles, mu)
epsil = binornd(1,mu,3,size(particles,2));

z_1 = particles(1:3,:);
z = epsil.*z_1 + (1-epsil).*(1-z_1);
particles(1:3,:) = z;

end

%--------------------------------------------------------------------------
function [resp, vars] = pf_process(parameters, observations, dimensions, characters, mode, config)
if nargin < 6
    config.resampling_strategy = 'systematic';
end

p = inputParser;
p.addParameter('resampling_strategy', 'systematic');
p.addParameter('resample_percentaje', .5);
p.addParameter('num_particles', 1000);
p.parse(config);
config    = p.Results;

[resp, vars] = rbpf(parameters.mu, observations, dimensions, characters, config);
end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
function [resp_c, vars] = rbpf(mu, observations, dimension, characters, config)

phi = .0001;
omega = .0001;
num_particles = config.num_particles;

weights = 1/num_particles*ones(1, num_particles);

N = length(observations);
z = round(rand(3, num_particles));
warmup = 10;

m = zeros(3, num_particles);
w = ones(3, num_particles);

resp_c = nan(N, 1);
for t=1:size(observations,1)    
%     val(t) = sum(m.*weights);    
    
    c1 = characters(t, 1);
    c2 = characters(t,2);
        
    if t>warmup
        [z] = transition_func(z, mu);
    end
            
    likelihood1 = normpdf(observations(t), m(c1, :), sqrt(phi+omega+w(c1, :)));
    likelihood2 = normpdf(observations(t), m(c2, :), sqrt(phi+omega+w(c2, :)));
    likelihood = z(dimension(t), :).*likelihood1 + (1-z(dimension(t), :)).*likelihood2;

    [idx, weights] = resample(likelihood, weights, config);    
    z = z(:, idx);

    resp_c(t,:) = weights*z(dimension(t), :)';    
            
    [m, w] = kalman(z(dimension(t), :), observations(t),characters(t,:),m(:,idx),w(:,idx),phi,omega);      
    
end

resp_c(resp_c<=0) = eps;
resp_c(resp_c>=1) = 1-eps;
resp_c = [resp_c 1-resp_c];

% p = resp_c(:, 1);
% action = data.action;
% loglik = -sum(log(sum([p 1-p].*[action 1-action], 2)+eps));

vars = struct('resp_c',resp_c);
end

function [idx, weights, resampled] = resample(likelihood, weights, config)
NumParticles = length(likelihood);

weights = weights.*(likelihood+eps);
weights = weights/(sum(weights)+eps);

Neff = 1/sum(weights.^2);
resample_percentaje = config.resample_percentaje;
Nt = resample_percentaje*NumParticles;
idx = 1:NumParticles;
resampled = 0;
if Neff < Nt
    [idx, weights] = resampling(config.resampling_strategy, weights);
    resampled = 1;
end

if any(isnan(weights))
    disp('')
end

end

function [idx, w] = resampling(resampling_strategy, w)
N  = length(w);
switch resampling_strategy
    case 'systematic'
        edges = min([0 cumsum(w)],1); % protect against accumulated round-off
        edges(end) = 1;                 % get the upper edge exact
        u = rand/N;
        [~, idx] = histc(u:1/N:1, edges);
    case 'multinomial'        
        u = rand(N,1);
        wc = cumsum(w');
        wc = wc(:);
        wc = wc/wc(N);
        [~,ind1] = sort([u;wc]);
        ind2 = find(ind1<=N);
        idx = ind2'-(0:N-1);
   otherwise
      error('Resampling strategy is unknown');
end

w = ones(size(w))/N;

end


function [mm, ww, kk]=kalman(z,outcome,characters,m,w,sigma,omega)

z = [z;1-z];

P = w(characters,:)+sigma;
v = P+omega;

k = bsxfun(@times,P,v.^-1);
k = k.*z;

kk = zeros(3,size(m,2));
kk(characters,:) = k;

mm = m + kk.*( outcome -m);
ww = (ones(3,1) - kk).*(w+sigma+omega);

end
