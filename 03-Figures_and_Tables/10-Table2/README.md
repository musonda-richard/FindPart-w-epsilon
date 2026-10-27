# Table 2 — UK-141

This directory reproduces Table 2 of the manuscript from the selected
UK-141 FindPart-w-epsilon partition.

## Analysis settings

- Dataset: UK-141
- Baseline lineage: EG.5.1
- Genetic connectivity threshold: epsilon = 7
- Selected beam width: w = 21
- Model-selection criterion: BIC
- Relative reproduction number generation time: 2.1 days
- Default Julia threads: 1

## Upstream inputs

Canonical lineage-count data:

    ../../00-files/02-UK-data/count_variants.csv

Relative effective reproduction number estimation is performed using:

    ../../RelRe_Softmax.jl

Pairwise Pangolin genetic distances are generated locally during the
workflow from the canonical UK-141 dataset using the shared lineage-alias
and genetic-distance scripts in the repository root:

    ../../alias.jl
    ../../calc_pangolin_distances.jl
    ../../lib_pangolin.jl
    ../../lineage_notes.txt

## Selected partition

The file:

    best-rgs.txt

contains the selected partition from the UK-141 analysis with epsilon = 7
and beam width w = 21.

The full w = 21 beam-width search is computationally intensive and its
complete search output is not duplicated in this directory. The search can
be rerun using the UK beam-width workflow provided for Figures 6 and 7.

`best-rgs.txt` is therefore retained as an input to the Table 2
reconstruction workflow and is not removed by `make clean`.

## Workflow

Running:

    make

performs the following steps:

1. Re-estimate the relative effective reproduction numbers and 95%
   confidence intervals for the retained selected partition.
2. Convert growth-rate differences to relative effective reproduction
   numbers using:

       R_RI = exp(b1 * generation_time)

3. Generate pairwise Pangolin genetic distances from the canonical UK-141
   lineage-count dataset.
4. Calculate the maximum within-block Pangolin genetic distance.
5. Generate `Table2.csv`.

The workflow defaults to one Julia thread for portability. The number of
threads can be changed when required, for example:

    THREADS=16 make

## Main output

    Table2.csv

The table reports:

- SARS-CoV-2 lineage membership for each block
- Block identifier
- Maximum within-block Pangolin genetic distance
- Estimated relative effective reproduction number
- 95% confidence interval

## Generated intermediate files

The workflow generates intermediate files including:

    best_estimates.csv
    best_loglikelihood.csv
    best_blocks.csv
    best_estimates_with_rri.csv
    pangolin_alias.csv
    pangolin_distances.csv

These files can be regenerated from the retained inputs and source code.

## Cleaning generated files

To remove generated intermediate files and the reconstructed table:

    make clean

This does not remove:

    best-rgs.txt

The retained selected partition, canonical lineage-count data, and shared
repository source files therefore remain available for reconstruction.

## Software requirements

The workflow requires Julia and R.

The R scripts use `dplyr`, which is included in the `tidyverse` package.
Required R and Julia packages can be installed using the repository-level
installation scripts:

    R -f ../../install_packages.R
    julia ../../install_packages.jl
