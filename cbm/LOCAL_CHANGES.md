# Local change

These functions are copied from CBM (Piray et al., 2019), which is distributed
under the GNU GPL v3 ([license](license)). One file was modified in November 2026
for this release.

`cbm_lap.m`: in the failed-optimization prior fallback, use `prior.precision`
instead of `A`. The original `A` variable has already been reassigned to a cell
array of subject Hessians, so attempting `A_n^-1` raises a cell-operand error.
The correction restores the intended Gaussian-prior precision matrix.

The release's `fit_subjects` additionally refuses to aggregate any saved fit with
optimization flag 0, including resumed files. A prior fallback is not treated as
a fitted subject. Other vendor functions are unchanged.
