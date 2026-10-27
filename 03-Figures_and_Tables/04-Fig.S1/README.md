# Figure S1

This directory contains the workflow used to reproduce **Figure S1**.

Running `make` first calculates pairwise genetic distances for the USA-19 and UK-141 datasets from the canonical data and Julia source files in the repository. The resulting genetic distances are then used by `Fig.S1.R` to generate the two-panel histogram.

## Reproducing the figure

```bash
make
```

This generates `Fig.S1.tiff`.

## Cleaning generated files

```bash
make clean
```

This removes the generated figure, pairwise genetic-distance files, and temporary copies of repository source and data files.

## Software requirements

Julia and R are required. The figure itself is generated using base R.
