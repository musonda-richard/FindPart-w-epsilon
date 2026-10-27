# Figure 1

This directory contains the R script used to reproduce **Figure 1**.

## Files

- `trajectory.R` — generates the lineage relative-frequency trajectories shown in Figure 1.
- `Makefile` — runs the figure-generation script and provides a cleaning target.

## Reproducing the figure

From this directory, run:

```bash
make
```

This creates:

```text
lineage_trajectories.tiff
```

The figure is generated at 6 × 5 inches and 600 dpi.

## Cleaning generated output

To remove the generated figure:

```bash
make clean
```

## Software requirements

The figure is generated using base R and does not require additional R packages.
