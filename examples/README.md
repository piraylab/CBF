# Example inputs and reference summaries

These CSVs contain no trial-level or participant-level human records. The Bird Task summaries come from the completed `[1,70]` refit; social recovery uses separate task models. `reproduce_examples` uses the synthetic recovery parameter pairs and the aggregate Figure 3 summary; it generates Figure 1 independently.

| File(s) | Contents |
| --- | --- |
| `recovery_parameters.csv` | True and fitted unconstrained coordinates for 100 **simulated** recovery agents, in `[x_v,x_s,y_v,y_s]` order. No observed outcomes or responses are present. |
| `figure2_refit.csv` | Reference recovery correlations for the four CBF parameters. |
| `figure3_models_refit.csv`, `figure3_models_tests_refit.csv` | Group means/SEMs and group-level tests for the two-model figure. |
| `learning_rates_refit.csv`, `average_lr_models_refit.csv`, `model_human_effects_refit.csv` | Aggregate average and condition-specific learning-rate and model–behavior correlations. |
| `table2_refit.csv` | Group-level response-time regression results. |
| `model_comparison_matched_mle_bic_refit.csv` | Matched MLE/BIC population comparison. |
| `sensitivity_refit.csv`, `sensitivity_tests_refit.csv` | Group summaries and contrasts across grid settings. |
| `mu_distributions_refit.csv`, `continuous_behavior_refit.csv` | Subgroup distribution summaries and correlations. |
| `social_recovery_refit.csv` | Recovery correlations from simulated social-task agents. |

Human summary tables describe groups or analyses across the sample. The separately bundled fit exports support Figure 3 recomputation with the original Bird Task data. [Figure 3 workflow](../README.md#recompute-figure-3-from-fitted-parameters) · [Fit export documentation](../fits/README.md)
