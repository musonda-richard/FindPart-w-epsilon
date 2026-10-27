# Table 1 — USA-19

This directory reproduces Table 1 of the manuscript from the selected
USA-19 FindPart-w-epsilon partition.

## Analysis settings

- Dataset: USA-19
- Baseline lineage: KP.3.1.1
- Genetic connectivity threshold: epsilon = 4
- Model-selection criterion: BIC
- Relative reproduction number generation time: 3.0 days
- Default Julia threads: 1

## Upstream inputs

Canonical lineage-count data:

    ../../00-files/01-USA-data/count_variants.csv

The selected epsilon = 4 partition is obtained from:

    ../../01-USA-epsilon-connectivity-analysis/01-lemma-enabled/04-d4/rgs-BIC.csv

Relative effective reproduction number estimation is performed using:

    ../../RelRe_Softmax.jl

Pairwise Pangolin genetic distances are generated locally during the
workflow from the canonical USA-19 dataset using the shared lineage-alias
and genetic-distance scripts in the repository root:

    ../../alias.jl
    ../../calc_pangolin_distances.jl
    ../../lib_pangolin.jl
    ../../lineage_notes.txt

## Workflow

Running:

    make clean
    make

performs the following steps:

1. Extract the best BIC partition from the epsilon = 4 FindPart results.
2. Re-estimate the relative effective reproduction numbers and 95% confidence intervals for the selected partition.
3. Convert growth-rate differences to relative effective reproduction numbers using:

       R_RI = exp(b1 * generation_time)

4. Generate pairwise Pangolin genetic distances and calculate the maximum within-block genetic distance.
5. Generate `Table1.csv`.

The workflow defaults to one Julia thread for portability. The number of
threads can be changed when required, for example:

    THREADS=16 make

## Main output

    Table1.csv

The table reports:

- SARS-CoV-2 lineage membership for each block
- Block identifier
- Maximum within-block Pangolin genetic distance
- Estimated relative effective reproduction number
- 95% confidence interval

## Cleaning generated files

To remove generated intermediate files and the reconstructed table:

    make clean

The retained upstream `rgs-BIC.csv`, canonical lineage-count data, and
shared repository source files are not removed by this command.

## Software requirements

The workflow requires Julia and R.

The R scripts use `dplyr`, which is included in the `tidyverse` package.
Required R and Julia packages can be installed using the repository-level
installation scripts:

    R -f ../../install_packages.R
    julia ../../install_packages.jl
