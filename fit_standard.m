function fit_standard(started)
%FIT_STANDARD Fit/resume 643 human MAP fits and 100 MAP recovery agents.
if nargin<1,started=tic;end
setup;
fprintf('Standard MAP: experiment 1 (223 subjects).\n');fit_experiment(1,started);
fprintf('Standard MAP: experiment 2 (420 subjects).\n');fit_experiment(2,started);
fprintf('Standard MAP: parameter recovery (100 agents).\n');run_recovery(started);
end
