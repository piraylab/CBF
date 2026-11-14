function [resp, transformed] = social_cbf(parameters, data, transform)
do_transform = 1;
if nargin>2, do_transform = transform; end

if do_transform
    eps_sigmoid = 1e-6;
    sigmoid = @(x)(1-eps_sigmoid)./(1+exp(-x)) + eps_sigmoid;
    u_mu = sigmoid(parameters(1));
    v_mu = sigmoid(parameters(2))/2;
else
    u_mu = parameters(1);
    v_mu = parameters(2);
end

config = struct('num_neurons', 25);
outcome = data.outcome;
characters = data.characters;
dimension = data.dimension;
[resp] = cbf_process([u_mu v_mu], outcome, dimension, characters, config);
transformed = [u_mu, v_mu];
end

function [resp_c, vars] = cbf_process(params, observations, dimension, characters, config)
u_mu = params(1);
v_mu = params(2);

alf = eps + u_mu / v_mu;
bet = eps + (1 - u_mu) / v_mu;

M = config.num_neurons;
quantiles = linspace(0.005, 0.995, M);
z = betainv(quantiles, alf, bet);        % 1 x M support; array axis d = dimension d's z

% each character belongs to exactly two dimensions, so its Kalman bank only
% needs an M x M grid over those two axes (singleton along the third axis,
% so it broadcasts against the M^3 joint weights). Mapping derived from data,
% with the canonical coding as fallback.
char_of_dim = [1 2; 1 3; 2 3];
for d = 1:3
    k = find(dimension == d, 1);
    if ~isempty(k)
        char_of_dim(d,:) = sort(characters(k,:));
    end
end

phi = .0001;
omega = .0001;
num_particles = M^3;
weights = 1/num_particles*ones(M, M, M);
N = length(observations);
m = cell(3,1);
w = cell(3,1);
for c = 1:3
    sz = ones(1,3);
    sz(any(char_of_dim == c, 2)) = M;
    m{c} = zeros(sz);
    w{c} = ones(sz);
end
resp_c = nan(N, 1);
for t=1:size(observations,1)
    c1 = characters(t, 1);
    c2 = characters(t,2);
    sz = ones(1,3);
    sz(dimension(t)) = M;
    zd = reshape(z, sz);                 % this dimension's z, along its own axis
    likelihood1 = normpdf(observations(t), m{c1}, sqrt(phi+omega+w{c1}));
    likelihood2 = normpdf(observations(t), m{c2}, sqrt(phi+omega+w{c2}));
    likelihood = zd.*likelihood1 + (1-zd).*likelihood2;   % expands to M x M x M
    weights = update_weights(likelihood, weights);
    wz = weights.*zd;
    resp_c(t,:) = sum(wz(:));
    [m, w] = kalman(zd, observations(t),characters(t,:),m, w, phi, omega);
end
resp_c(resp_c<=0) = eps;
resp_c(resp_c>=1) = 1-eps;
resp_c = [resp_c 1-resp_c];
vars = struct('resp_c',resp_c);
end
function [weights] = update_weights(likelihood, weights)
    weights = weights.*(likelihood+eps);
    weights = weights/sum(weights(:));
end
function [m, w]=kalman(z,outcome,characters,m,w,sigma,omega)
zz = {z, 1-z};
for i = 1:2
    c = characters(i);
    P = w{c}+sigma;
    v = P+omega;
    k = (P./v).*zz{i};
    m{c} = m{c} + k.*( outcome - m{c});
    w{c} = (1 - k).*(w{c}+sigma+omega);
end
c3 = setdiff(1:3, characters);
w{c3} = w{c3}+sigma+omega;   % same growth the original applied to the uninvolved character
end