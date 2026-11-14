# Categorical Bayes Filtering for Computational Phenotyping in Adaptive Learning

This repository contains MATLAB code and fitted model results reported in this article:

Junxi Chen and Payam Piray. **Categorical Bayes filtering for computational phenotyping in adaptive learning.** NeurIPS (2026).

GitHub: [https://github.com/piraylab/CBF](https://github.com/piraylab/CBF)

## Repository contents

The `model/` folder contains the model implementations. The main CBF implementation for the Bird Task is [`distr_model_p.m`](model/distr_model_p.m). This folder also contains the two social-task models.

The `fitting/` folder contains code for fitting the Bird Task models and running parameter recovery. The `analysis/` folder contains code for generating figures and statistical results.

The `support/` folder contains shared functions for loading inputs and checking saved fits. The `cbm/` folder contains the CBM fitting functions used by this code, together with their license.

The `fits/` folder contains fitted CBF and RBPF parameters for the two Bird Task experiments, with one row per participant. It contains no trial-level responses. [Fit file documentation](fits/README.md)

The `examples/` folder contains parameters from simulated recovery agents and aggregate result tables. These files let you draw the main figures without downloading human data. [Example file documentation](examples/README.md)

The `docs/` folder contains the [release scope](docs/RELEASE_SCOPE.md), which lists how to reproduce each included result and identifies analyses that are not included.

The `data/` folder is for downloaded Bird Task data. The `results/` folder is created when you run the code and stores generated fits, figures, and tables. Both folders are ignored by Git. Raw behavioral data and questionnaire records are not included in this repository.

## Requirements

The code has been implemented and tested in MATLAB R2024b with Statistics and Machine Learning Toolbox and Optimization Toolbox.

Open MATLAB in the repository folder. The commands in the repository root add the code folders to the search path automatically. To call functions inside the subfolders directly, first run:

```matlab
setup
```

## Quick start

Open MATLAB in the repository and run:

```matlab
reproduce_examples
```

This generates:

- **Figure 1:** CBF dynamics from 50 synthetic simulations per condition.
- **Figure 2:** parameter recovery plots from the saved true and fitted parameters of 100 simulated agents.
- **Figure 3:** the CBF and RBPF group comparison from saved group means and standard errors.

No human data download is needed. Figure 1 is saved in `results/`; Figures 2 and 3 are saved in `results/examples/`.

## Get the Bird Task data

The fitting and recomputation commands below use the public Bird Task data from Piray and Daw (2024). Download the two `data.mat` files from the [original study's repository](https://github.com/payampiray/stovol-learning) and save them as:

- `data/experiment1/data.mat` — Experiment 1, 223 participants.
- `data/experiment2/data.mat` — Experiment 2, 420 participants.

Keep the participants in their original order so that they match the saved parameter files in `fits/`.

## Fit models and reproduce analyses

To fit the models to the Bird Task data and analyze the resulting fits, run:

```matlab
fit_standard
analyze_all
```

`fit_standard.m` fits the standard CBF model to all 643 participants and runs parameter recovery with 100 simulated agents. It uses 10 atoms per dimension and support bounds `[1,70]`. The full run takes up to about an hour on one CPU core and can resume from compatible saved fits in `results/`.

`analyze_all.m` generates Figures 1–3 and the included statistical analyses from the completed fits. These include Table 1 (learning-rate correlations), Table 2 (response-time regressions), and Tables 7–9 (parameter distributions and continuous associations). It uses the saved RBPF parameters for the Figure 3 comparison. Run `analyze_all` again to update these outputs without refitting.

Additional fitting commands are available after running `setup`:

- `fit_sensitivity.m` fits four additional grid settings after the standard fits. Then run `analyze_all` to generate the results for Tables 4–5.
- `fit_mle_comparison.m` fits the CBF by maximum likelihood and saves the BIC evidence values used in model comparison. The full Table 3 model-selection workflow is not included.
- `retry_mle_nonconverged.m` retries maximum-likelihood fits that did not report convergence.
- `fit_all.m` runs the standard, maximum-likelihood, and grid sensitivity fits in sequence.

Saved reference results and the coverage of the remaining analyses are listed in the [release scope](docs/RELEASE_SCOPE.md).

## Citation

If you use this code, please cite the corresponding paper.

Contact: jc8951@nyu.edu

## License

This code is released under the [MIT License](LICENSE). The CBM functions in `cbm/` are distributed under their own license, the GNU GPL v3 ([cbm/license](cbm/license)).
