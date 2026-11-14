function fit_all()
%FIT_ALL Run the Bird Task CBF fits and synthetic recovery.
started=tic;setup;
fprintf('1/3: Standard human MAP and MAP recovery.\n');fit_standard(started);
fprintf('2/3: Native-space human CBF MLE.\n');fit_mle_comparison(started);
fprintf('3/3: Atom-count and support sensitivity fits.\n');fit_sensitivity(started);
fprintf('Fitting complete. Run analyze_all.\n');
end
