# Figure 2

This directory contains the files used to reproduce **Figure 2**.

## Files

- `e1.pdf` — input panel for ε = 1.
- `e2.pdf` — input panel for ε = 2.
- `e-infty.pdf` — input panel for ε = ∞.
- `combine_epsilon.R` — combines the three input panels into the final figure.
- `Makefile` — reproduces and cleans the generated figure files.

## Reproducing the figure

From this directory, run:

```bash
make
```

This generates:

```text
Fig2.pdf
Fig2.tiff
```

The panels are arranged vertically in the order ε = ∞, ε = 2, and ε = 1.

## Software requirements

The R script requires the `magick` package.

The required R packages for the repository can be installed using the repository-level `install_packages.R` script.

## Cleaning generated output

To remove the generated figure files, run:

```bash
make clean
```
