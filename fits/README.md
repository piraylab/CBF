# Bird Task fitted parameters

| Files | Columns | Source |
| --- | --- | --- |
| `cbf_experiment1.csv`, `cbf_experiment2.csv` | `x_v`, `x_s`, `y_v`, `y_s` | `cbm.output.parameters` from the completed standard MAP refits. The first two coordinates control the means and the last two control the dispersions for volatility and stochasticity. |
| `rbpf_experiment1.csv`, `rbpf_experiment2.csv` | `mu_v`, `mu_s` | Native volatility and stochasticity update rates from the supplied Bird Task RBPF fits. |

The standard CBF refits use 10 atoms per dimension, bounds `[1,70]`, and `eps + min + (max-min)*BetaQuantile`. The Figure 3 analysis transforms the CBF dispersion coordinates with `0.5/(1+exp(-y))` and the RBPF rates with `1/(1+exp(-mu))` for plotting. The test output identifies the scale of each contrast.

Each CSV has one row per participant. Experiment 1 has 223 rows and experiment 2 has 420. Within each experiment, row `n` corresponds to `data{n}` in the original Bird Task `data.mat`. Use those files in their original order when recomputing Figure 3.

The CSV columns contain only fitted parameters. Row order links these derived outputs to the original study records. [Figure 3 workflow](../README.md#recompute-figure-3-from-fitted-parameters)
