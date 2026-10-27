# Figure S2

This directory contains the scripts and summary data used to reproduce Figure S2.

Figure S2 shows the relationship between the number of maximum-likelihood estimations (MLEs) and running time for FindPart-w-epsilon applied to the USA-19 and UK-141 datasets.

The analysis considers:

- Beam widths: w = 1, 2, 4, 8
- Genetic-distance thresholds: epsilon = 1, 2, 4, 8, 16
- USA-19 baseline lineage: KP.3.1.1
- UK-141 baseline lineage: EG.5.1
- Model-selection criterion: BIC

## Files

- `plot_Fig.S2.R`: generates Figure S2.
- `Fig.S2.tiff`: generated 600-dpi TIFF output (created by `make`).
- `USA/mle_runtime_by_width_epsilon.csv`: summarized USA-19 computational results.
- `UK/mle_runtime_by_width_epsilon.csv`: summarized UK-141 computational results.
- `USA/collect.sh` and `UK/collect.sh`: reconstruct the summary CSV files from completed computational runs.
- `01-w1`, `02-w2`, `03-w4`, and `04-w8`: scripts and Makefile templates for the four beam widths.

The Julia source files and input datasets are shared from the repository root rather than duplicated in this directory.

## Reproducing the computational runs

For each beam-width directory, create the five epsilon-specific run directories:

    ./create_folders.sh

This creates runs for:

    epsilon = 1, 2, 4, 8, 16

Run the analyses sequentially using:

    ./run_folders.sh

The default is one Julia thread. The number of threads can be overridden without modifying the Makefiles:

    THREADS=N ./run_folders.sh

where `N` is the desired number of Julia threads.

After all four beam widths have completed, return to the corresponding dataset directory and reconstruct the summary CSV:

    ./collect.sh

The collector requires all 20 combinations of beam width and epsilon for that dataset to be complete.

## Reproducing Figure S2

From the `08-Fig.S2` directory, run:

    make

To regenerate the figure from a clean state:

    make clean
    make

The output is:

    Fig.S2.tiff

The figure is generated as an uncompressed 600-dpi TIFF.

## Runtime reproducibility

The supplied summary CSV files preserve the benchmark results used to construct Figure S2.

The number of MLE calculations is determined by the computational analysis, whereas elapsed running time also depends on the computing environment, hardware, system load, and number of Julia threads. Therefore, rerunning the analyses on another system may reproduce the number of MLE calculations without reproducing the recorded elapsed times exactly.

The cleaned workflow defaults to one Julia thread for portability. The number of threads can be specified using the `THREADS` option when rerunning the computational analyses.`
