# Release scope

This page lists every result reported in the paper and how to reproduce it from this repository. `fit_standard`, `recompute_figure3`, and `analyze_all` need the public Bird Task data in `data/` ([download instructions](../README.md#get-the-bird-task-data)). Most rows have saved reference values in `examples/`.

## Included

| Paper result | How to reproduce it |
| --- | --- |
| Figure 1 | `reproduce_examples` or `analyze_all` simulates and plots the dynamics. The seed and initial latent state used for the published figure were not recorded, so `analysis/figure1_dynamics.m` sets them explicitly (seed 0, initial state 60), and individual curves can differ slightly from the published panels. |
| Figure 2 and the MAP recovery correlations (Section 4.1, Appendix B.2) | `reproduce_examples` plots the bundled true and recovered parameters. To regenerate them, run `fit_standard` (or `run_recovery` alone after `setup`), then `analyze_all`. The simulations use the Bird Task outcome sequence, so they also need the data. |
| Figure 3, the group counts (76 and 79), and the group t tests (Section 4.2) | `reproduce_examples` draws the saved group summaries. `recompute_figure3` recomputes both panels and the tests from the bundled fits and the Bird Task data. `analyze_all` recomputes them from your own fits. |
| Table 1 and the CBF learning-rate correlations in Section 4.3 (rank r = 0.866; main effects r = 0.52 and 0.61) | `analyze_all` after `fit_standard`. |
| Table 2 (response times, Section 4.4) | `analyze_all` after `fit_standard`. |
| Tables 4–5 (grid sensitivity, Appendix E) | `fit_sensitivity` after `fit_standard`, then `analyze_all`. |
| Tables 7–9, the off-dimension correlation (Appendix G), and the behavioral main effects (Section 4.2) | `analyze_all` after `fit_standard`. |

For Figure 3, the CBF panel displays transformed dispersions and the RBPF panel displays sigmoid-transformed rates. The group-test table identifies the scale used for each contrast. The bundled fitted parameters retain the original study row order. [Fit export documentation](../fits/README.md)

## Partly included

| Paper result | Included | Not included |
| --- | --- | --- |
| Table 3 (Bayesian model selection, Section 4.5, Appendix D.3) | `fit_mle_comparison` computes the CBF maximum-likelihood BIC values. The result table is saved in `examples/model_comparison_matched_mle_bic_refit.csv`. | The RBPF evidence values, which come from the original study's fits (Piray & Daw, 2024), and the model-selection step. |
| RBPF learning-rate correlations in Section 4.3 (rank r = 0.800; main effects r = 0.34 and 0.36) | Saved results in `examples/average_lr_models_refit.csv` and `examples/model_human_effects_refit.csv`. | Trial-by-trial RBPF learning rates and the code that correlates them with behavior. |
| Table 6 (social latent-cause task, Section 4.6, Appendix F) | Model functions `model/social_cbf.m` and `model/social_rbpf.m`. Saved results in `examples/social_recovery_refit.csv`. | Task design, simulation, and fitting scripts. |

## Not included

These reported results have no code or data in this repository:

- Psychiatric associations (Section 4.2, Appendix H, Table 10). The questionnaire data are not part of the public Bird Task dataset.
- Split-half reliability of the behavioral main effects and the correlation ceilings derived from it (Section 4.3).
- Maximum-likelihood parameter recovery without priors (Appendix B.2).
- RBPF parameter recovery (Section 4.1) and RBPF refit reliability across seeds (Section 4.2).

[Quick start](../README.md#quick-start) · [Example inventory](../examples/README.md)
