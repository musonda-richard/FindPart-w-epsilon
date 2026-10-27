# Clustering Genetically Closely Related SARS-CoV-2 Lineages that Share the Same Relative Effective Reproduction Number Using Bayesian Information Criterion–Based Model Selection

## Authors
- Richard Musonda
- Kimihito Ito
---

## Overview

This repository contains the data, source code, computational analyses, and figure and table reconstruction workflows for the study:

**Identifying SARS-CoV-2 lineages that share the same relative effective reproduction numbers**

The study extends the FindPart-w approach by incorporating a genetic-connectivity constraint, denoted by epsilon (ε), when identifying groups of SARS-CoV-2 lineages that share the same relative effective reproduction number.

The repository contains analyses of two SARS-CoV-2 datasets:

- **USA-19**, containing 19 SARS-CoV-2 lineages from the United States.
- **UK-141**, containing 141 SARS-CoV-2 lineages from the United Kingdom.

The main analyses include:

- Estimation of relative effective reproduction numbers.
- Identification of lineage partitions using FindPart-w-epsilon.
- Evaluation of different genetic-connectivity thresholds.
- Comparison of FindPart-w-epsilon with and without lemma-based pruning.
- Evaluation of computational cost across genetic-connectivity thresholds.
- Evaluation of different beam widths.
- Calculation of pairwise Pangolin lineage genetic distances.
- Reconstruction of the lineage groups and relative effective reproduction numbers reported in Tables 1 and 2.
- Comparison of the resulting relative effective reproduction number estimates with estimates from previous studies.

---

## Repository Structure

```text
00-files/
    01-USA-data/
        count_variants.csv

    02-UK-data/
        count_variants.csv

01-USA-epsilon-connectivity-analysis/
    01-lemma-enabled/
    02-lemma-disabled/

02-UK-epsilon-connectivity-analysis/
    01-lemma-enabled/
    02-lemma-disabled/

03-Figures_and_Tables/
    01-Fig.1/
    02-Fig.2/
    03-Fig.3/
    04-Fig.S1/
    05-Fig.4_and_Fig.S3/
    06-Fig.5/
    07-Fig.6_and_Fig.7/
    08-Fig.S2/
    09-Table1/
    10-Table2/
    11-Fig.S4/

FindPart-w-epsilon.jl
RelRe_Softmax_Core.jl
RelRe_Softmax.jl
lib_setpartition.jl
lib_pangolin.jl
alias.jl
calc_pangolin_distances.jl
pairwise_gen_distances.jl
lineage_notes.txt
install_packages.jl
install_packages.R
README.md
```

The main computational programs are stored in the repository root so that the different analysis workflows use the same source code.

---

## Required Software and Packages

### Julia

The computational analyses use Julia.

The repository has been tested using Julia 1.11.

The following external Julia packages are required:

- ArgParse
- CSV
- Clustering
- Combinatorics
- DataFrames
- Distributions
- NLopt

The analyses also use Julia standard-library functionality including `Dates`, `SHA`, `Statistics`, and `Base.Threads`.

Install the required external Julia packages using:

```bash
julia install_packages.jl
```

The required packages can be checked directly using:

```bash
julia -e 'using ArgParse, CSV, Clustering, Combinatorics, DataFrames, Distributions, NLopt; println("All required repository Julia packages loaded successfully.")'
```

### R

The figure and table reconstruction workflows use R.

The repository has been tested using R 4.5.

The required R packages are:

- tidyverse
- magick

The `dplyr` package used by some scripts is included in `tidyverse`.

Install the required R packages using:

```bash
R -f install_packages.R
```

### Other software

The workflows also use standard Unix/macOS command-line utilities, including:

- `bash`
- `make`
- `awk`

---

## Canonical Input Data

The two canonical lineage-count datasets are retained in:

```text
00-files/01-USA-data/count_variants.csv
00-files/02-UK-data/count_variants.csv
```

The first dataset contains the 19 lineages used in the USA analysis and is referred to as **USA-19**.

The second dataset contains the 141 lineages used in the UK analysis and is referred to as **UK-141**.

These files are used directly by the downstream computational workflows. Copies of the canonical datasets do not need to be stored within individual analysis directories.

---

## Main Programs

### FindPart-w-epsilon.jl

`FindPart-w-epsilon.jl` implements the FindPart-w-epsilon partition-search procedure.

The program searches for partitions of SARS-CoV-2 lineages while imposing a genetic-connectivity constraint controlled by epsilon.

The search can also be restricted using beam width `w`, which limits the number of candidate partitions retained during the search.

### RelRe_Softmax.jl

`RelRe_Softmax.jl` estimates relative effective reproduction numbers for a specified lineage partition.

It is used particularly in the reconstruction of Tables 1 and 2.

### RelRe_Softmax_Core.jl

`RelRe_Softmax_Core.jl` contains shared functions used during the FindPart-w-epsilon and relative effective reproduction number analyses.

### lib_setpartition.jl

`lib_setpartition.jl` contains functions used to construct, compare, refine, and aggregate lineage partitions.

### Pangolin genetic-distance programs

The following files support the calculation of genetic distances between Pangolin lineages:

```text
alias.jl
lib_pangolin.jl
calc_pangolin_distances.jl
pairwise_gen_distances.jl
lineage_notes.txt
```

`alias.jl` uses the retained Pangolin lineage notes to construct lineage aliases.

`calc_pangolin_distances.jl` calculates genetic distances between the lineages in a specified lineage-count dataset.

---

## Common FindPart-w-epsilon Parameters

The principal Makefile parameters used by the epsilon-connectivity analyses are:

```text
THREADS
FTOL_REL
BASELINE
WIDTH
EPSILON
MODEL_SEL
LEMMA_OPTION
DBSCAN_OPTION
```

### THREADS

The number of Julia threads used by the computational analysis.

Default:

```text
THREADS=1
```

The number of threads can be increased depending on the computing system.

For example:

```bash
bash run_folders.sh 16 16
```

runs the USA epsilon series through ε = 16 using 16 Julia threads.

### FTOL_REL

Relative optimization tolerance.

Default:

```text
FTOL_REL=1e-9
```

### BASELINE

Reference SARS-CoV-2 lineage.

USA-19:

```text
KP.3.1.1
```

UK-141:

```text
EG.5.1
```

### WIDTH

Beam width used by FindPart-w-epsilon.

The principal epsilon-connectivity analyses use:

```text
WIDTH=1
```

Separate beam-width experiments are provided for Figures 6 and 7.

### EPSILON

Genetic-connectivity threshold.

The epsilon value is changed automatically across the epsilon-connectivity analysis folders.

### MODEL_SEL

Model-selection criterion.

The principal analyses use:

```text
MODEL_SEL=BIC
```

### LEMMA_OPTION

Controls whether the lemma-based pruning procedure is used.

Lemma enabled:

```text
LEMMA_OPTION=lemma
```

Lemma disabled:

```text
LEMMA_OPTION=no_lemma
```

### DBSCAN_OPTION

DBSCAN is disabled in the principal FindPart-w-epsilon analyses:

```text
DBSCAN_OPTION=no_dbscan
```

---

# Section 1: USA-19 Epsilon-Connectivity Analysis

## Purpose

The USA epsilon-connectivity analysis evaluates how the genetic-connectivity threshold affects the partitions identified by FindPart-w-epsilon for the 19-lineage USA dataset.

The analysis evaluates epsilon values from:

```text
ε = 0, 1, 2, ..., 16
```

The baseline lineage is:

```text
KP.3.1.1
```

The principal analysis uses:

```text
WIDTH = 1
MODEL_SEL = BIC
FTOL_REL = 1e-9
DBSCAN_OPTION = no_dbscan
```

Two versions of the analysis are retained:

```text
01-USA-epsilon-connectivity-analysis/01-lemma-enabled/
01-USA-epsilon-connectivity-analysis/02-lemma-disabled/
```

The first uses the lemma-based pruning procedure. The second runs FindPart-w-epsilon without this pruning procedure.

---

## Step 1.1: USA analysis with the lemma enabled

Change to:

```bash
cd 01-USA-epsilon-connectivity-analysis/01-lemma-enabled
```

Create the epsilon analysis directories:

```bash
bash create_folders.sh 16
```

This creates:

```text
00-d0/
01-d1/
02-d2/
...
16-d16/
```

Each directory corresponds to one epsilon value.

Run all epsilon analyses using the default of one Julia thread:

```bash
bash run_folders.sh 16
```

Alternatively, specify the number of Julia threads as the second argument. For example:

```bash
bash run_folders.sh 16 16
```

runs all epsilon values using 16 Julia threads.

For each epsilon value, the workflow:

1. Generates `pangolin_alias.csv`.
2. Calculates `pangolin_distances.csv`.
3. Runs `FindPart-w-epsilon.jl`.
4. Evaluates candidate partitions using BIC.
5. Writes the partition-search results.

The lemma-enabled workflow uses:

```text
LEMMA_OPTION=lemma
```

The principal partition-search output is:

```text
rgs-BIC.csv
```

---

## Step 1.2: USA analysis with the lemma disabled

Change to:

```bash
cd 01-USA-epsilon-connectivity-analysis/02-lemma-disabled
```

Create the epsilon directories:

```bash
bash create_folders.sh 16
```

Run all epsilon analyses:

```bash
bash run_folders.sh 16
```

or, for example, using 16 Julia threads:

```bash
bash run_folders.sh 16 16
```

This workflow uses the same principal analysis settings as the lemma-enabled analysis except:

```text
LEMMA_OPTION=no_lemma
```

The lemma-enabled and lemma-disabled analyses can therefore be compared to evaluate the effect of lemma-based pruning on the computational search.

---

# Section 2: UK-141 Epsilon-Connectivity Analysis

## Purpose

The UK epsilon-connectivity analysis applies FindPart-w-epsilon to the 141-lineage UK dataset across different genetic-connectivity thresholds.

The analysis evaluates:

```text
ε = 0, 1, 2, ..., 24
```

The baseline lineage is:

```text
EG.5.1
```

The principal settings are:

```text
WIDTH = 1
MODEL_SEL = BIC
FTOL_REL = 1e-9
DBSCAN_OPTION = no_dbscan
```

Two analysis variants are retained:

```text
02-UK-epsilon-connectivity-analysis/01-lemma-enabled/
02-UK-epsilon-connectivity-analysis/02-lemma-disabled/
```

---

## Step 2.1: UK analysis with the lemma enabled

Change to:

```bash
cd 02-UK-epsilon-connectivity-analysis/01-lemma-enabled
```

Create the epsilon directories:

```bash
bash create_folders.sh 24
```

This creates:

```text
00-d0/
01-d1/
02-d2/
...
24-d24/
```

Run the analyses using one Julia thread:

```bash
bash run_folders.sh 24
```

Alternatively, specify the thread count. For example:

```bash
bash run_folders.sh 24 16
```

The lemma-enabled analysis uses:

```text
LEMMA_OPTION=lemma
```

---

## Step 2.2: UK analysis with the lemma disabled

Change to:

```bash
cd 02-UK-epsilon-connectivity-analysis/02-lemma-disabled
```

Create the directories:

```bash
bash create_folders.sh 24
```

Run all analyses:

```bash
bash run_folders.sh 24
```

or, for example:

```bash
bash run_folders.sh 24 16
```

This analysis uses:

```text
LEMMA_OPTION=no_lemma
```

The UK-141 calculations can be computationally intensive because of the larger number of lineages and candidate partitions.

---

# Section 3: Reproducing the Manuscript Figures and Tables

All figure and table reconstruction workflows are located under:

```text
03-Figures_and_Tables/
```

The directories correspond to:

| Directory | Manuscript output |
|---|---|
| `01-Fig.1` | Figure 1 |
| `02-Fig.2` | Figure 2 |
| `03-Fig.3` | Figure 3 |
| `04-Fig.S1` | Figure S1 |
| `05-Fig.4_and_Fig.S3` | Figure 4 and Figure S3 |
| `06-Fig.5` | Figure 5 |
| `07-Fig.6_and_Fig.7` | Figure 6 and Figure 7 |
| `08-Fig.S2` | Figure S2 |
| `09-Table1` | Table 1 |
| `10-Table2` | Table 2 |
| `11-Fig.S4` | Figure S4 |

---

## Figure 1

### Purpose

Figure 1 visualizes the SARS-CoV-2 lineage trajectories used to illustrate lineage replacement through time.

Change to:

```bash
cd 03-Figures_and_Tables/01-Fig.1
```

Run:

```bash
make
```

The workflow executes:

```text
trajectory.R
```

and generates:

```text
lineage_trajectories.tiff
```

The script uses base R and does not require additional R packages.

To remove the generated figure:

```bash
make clean
```

---

## Figure 2

### Purpose

Figure 2 combines the retained epsilon-connectivity illustration panels into the final manuscript figure.

Change to:

```bash
cd 03-Figures_and_Tables/02-Fig.2
```

The retained input panels are:

```text
e1.pdf
e2.pdf
e-infty.pdf
```

Run:

```bash
make
```

The R script:

```text
combine_epsilon.R
```

combines the retained panels and generates:

```text
Fig2.pdf
Fig2.tiff
```

The workflow requires the R package `magick`.

To remove the reconstructed outputs while retaining the source panels:

```bash
make clean
```

---

## Figure 3

Figure 3 contains the FindPart-w-epsilon algorithm.

The final figure is retained directly as:

```text
03-Figures_and_Tables/03-Fig.3/Fig3.pdf
```

Figure 3 is not regenerated as part of the repository workflow.

---

## Figure S1

### Purpose

Figure S1 summarizes pairwise Pangolin genetic distances among the SARS-CoV-2 lineages in the USA-19 and UK-141 datasets.

Change to:

```bash
cd 03-Figures_and_Tables/04-Fig.S1
```

Run:

```bash
make
```

The workflow:

1. Uses the canonical USA-19 and UK-141 lineage-count datasets.
2. Generates Pangolin lineage aliases.
3. Calculates pairwise genetic distances for each dataset.
4. Runs `Fig.S1.R` to generate the supplementary figure.

The main output is:

```text
Fig.S1.tiff
```

To remove the generated figure and temporary genetic-distance files:

```bash
make clean
```

---

## Figure 4 and Figure S3

### Purpose

Figure 4 and Figure S3 summarize computational results from the epsilon-connectivity analyses.

Change to:

```bash
cd 03-Figures_and_Tables/05-Fig.4_and_Fig.S3
```

The retained summary files include:

```text
01-elapsed_num.mle-USA/elapsed.csv
01-elapsed_num.mle-USA/num_mle.csv

02-elapsed_num.mle-UK/elapsed.csv
02-elapsed_num.mle-UK/num_mle.csv
```

These files allow the figures to be reconstructed without rerunning the complete epsilon-connectivity analyses.

To reconstruct the summaries from the retained upstream epsilon-analysis results, run:

```bash
make collect
```

The collection script is:

```text
get_elapsed_and_num.mle.sh
```

To generate Figure 4 and Figure S3, run:

```bash
make
```

The plotting scripts are:

```text
plot_Fig4.R
plot_S3.R
```

The main outputs are:

```text
Fig.4.tiff
Fig.S3.tiff
```

To remove the generated figure files:

```bash
make clean
```

---

## Figure 5

### Purpose

Figure 5 summarizes how the selected partition and model fit change with the genetic-connectivity threshold.

Change to:

```bash
cd 03-Figures_and_Tables/06-Fig.5
```

The retained summary files are:

```text
rank_by_epsilon.csv
BIC_by_epsilon_USA_UK.csv
loglik_by_epsilon.csv
```

These files contain the summary results required to reproduce Figure 5.

Run:

```bash
make
```

The plotting script:

```text
plot_Fig5.R
```

generates:

```text
Fig.5.tiff
```

The directory also contains:

```text
collect_rank.sh
collect_BIC.sh
collect_ll.sh
```

These scripts can regenerate the summary CSV files from complete upstream epsilon-analysis outputs.

However, regeneration of these summaries requires the corresponding upstream `rgs-BIC.csv` results to be available for all required epsilon values.

Therefore, the retained summary CSV files should be used for direct figure reconstruction unless the full epsilon-connectivity analyses have first been rerun.

To remove the generated figure:

```bash
make clean
```

---

## Figures 6 and 7

### Purpose

Figures 6 and 7 evaluate the effect of beam width on computational cost and BIC.

Change to:

```bash
cd 03-Figures_and_Tables/07-Fig.6_and_Fig.7
```

Separate USA-19 and UK-141 beam-width analyses are provided.

### USA-19 beam-width analysis

The USA analysis uses:

```text
epsilon = 4
baseline = KP.3.1.1
```

The evaluated finite beam widths include:

```text
w = 1
w = 10000
w = 20000
w = 30000
...
w = 200000
```

An unrestricted (`w = infinity`) result is also included.

The retained summary files include:

```text
USA/bic_by_width.csv
USA/mle_by_width.csv
```

The USA subdirectory contains scripts for creating and running the beam-width analysis folders and collecting the resulting BIC and MLE summaries.

### UK-141 beam-width analysis

The UK analysis uses:

```text
epsilon = 7
baseline = EG.5.1
```

The evaluated beam widths are:

```text
w = 1, 2, 3, ..., 23
```

The retained summary files include:

```text
UK/bic_by_width.csv
UK/mle_by_width.csv
```

### Reconstructing Figures 6 and 7

From:

```bash
cd 03-Figures_and_Tables/07-Fig.6_and_Fig.7
```

run:

```bash
make
```

The plotting scripts are:

```text
plot_Fig6.R
plot_Fig7.R
```

The retained summary CSV files allow Figures 6 and 7 to be reconstructed without repeating all beam-width searches.

The underlying computational searches can also be rerun using the `create_folders.sh` and `run_folders.sh` scripts in the USA and UK subdirectories.

The workflows default to one Julia thread. The number of threads can be overridden when rerunning the computational analyses.

To remove the generated figures:

```bash
make clean
```

---

## Figure S2

### Purpose

Figure S2 evaluates computational cost across combinations of beam width and genetic-connectivity threshold.

Change to:

```bash
cd 03-Figures_and_Tables/08-Fig.S2
```

Separate USA and UK analyses are provided.

The evaluated beam widths are:

```text
w = 1, 2, 4, 8
```

The evaluated genetic-connectivity thresholds are:

```text
epsilon = 1, 2, 4, 8, 16
```

The retained summary files are:

```text
USA/mle_runtime_by_width_epsilon.csv
UK/mle_runtime_by_width_epsilon.csv
```

These summary files contain the number of maximum likelihood estimations and recorded computational running times for the tested combinations.

Run:

```bash
make
```

The plotting script:

```text
plot_Fig.S2.R
```

generates:

```text
Fig.S2.tiff
```

The underlying computational analyses can be rerun using the `create_folders.sh`, `run_folders.sh`, and `collect.sh` scripts within the USA and UK subdirectories.

The cleaned workflows default to one Julia thread.

The number of MLE calculations is determined by the computational search, whereas elapsed running time depends additionally on the computing environment, hardware, system load, Julia version, and number of Julia threads.

Therefore, rerunning the analysis may reproduce the number of MLE calculations without reproducing the recorded elapsed times exactly.

To remove the generated figure:

```bash
make clean
```

---

## Table 1 — USA-19

### Purpose

Table 1 reports the lineage groups and relative effective reproduction numbers obtained from the selected USA-19 FindPart-w-epsilon partition.

The selected analysis uses:

```text
epsilon = 4
beam width = 1
baseline lineage = KP.3.1.1
model-selection criterion = BIC
generation time = 3.0 days
```

Change to:

```bash
cd 03-Figures_and_Tables/09-Table1
```

The selected partition is obtained from:

```text
../../01-USA-epsilon-connectivity-analysis/01-lemma-enabled/04-d4/rgs-BIC.csv
```

Run:

```bash
make
```

The workflow performs the following steps:

1. Extracts the best-BIC partition from the USA ε = 4 FindPart-w-epsilon results.
2. Re-estimates the lineage parameters for the selected partition.
3. Calculates relative effective reproduction numbers and their 95% confidence intervals.
4. Generates Pangolin pairwise genetic distances.
5. Calculates the maximum within-block genetic distance.
6. Generates the final table.

Relative effective reproduction numbers are calculated using:

```text
R_RI = exp(b1 × generation_time)
```

with:

```text
generation_time = 3.0 days
```

The main output is:

```text
Table1.csv
```

The table contains:

- Lineage membership.
- Block identifier.
- Maximum within-block Pangolin genetic distance.
- Relative effective reproduction number.
- 95% confidence interval.

The workflow defaults to one Julia thread.

A different number can be specified, for example:

```bash
THREADS=16 make
```

To remove generated intermediate files and the reconstructed table:

```bash
make clean
```

The upstream USA ε = 4 result and canonical input data are not removed.

---

## Table 2 — UK-141

### Purpose

Table 2 reports the lineage groups and relative effective reproduction numbers obtained from the selected UK-141 partition.

The selected analysis uses:

```text
epsilon = 7
beam width = 21
baseline lineage = EG.5.1
model-selection criterion = BIC
generation time = 2.1 days
```

Change to:

```bash
cd 03-Figures_and_Tables/10-Table2
```

### Selected partition

The selected partition is retained as:

```text
best-rgs.txt
```

This file contains the selected UK-141 partition obtained using:

```text
epsilon = 7
w = 21
```

The complete w = 21 beam-width search is computationally intensive.

Therefore, the selected partition is retained directly in the Table 2 directory rather than duplicating the complete search output.

The full beam-width search can be rerun using the UK beam-width workflow provided for Figures 6 and 7.

### Reconstructing Table 2

Run:

```bash
make
```

The workflow:

1. Reads the retained selected partition from `best-rgs.txt`.
2. Re-estimates the relative effective reproduction numbers and 95% confidence intervals.
3. Converts the estimated growth-rate differences using a generation time of 2.1 days.
4. Generates Pangolin pairwise genetic distances.
5. Calculates the maximum within-block genetic distance.
6. Generates the final table.

The main output is:

```text
Table2.csv
```

The table contains:

- Lineage membership.
- Block identifier.
- Maximum within-block Pangolin genetic distance.
- Relative effective reproduction number.
- 95% confidence interval.

The workflow defaults to one Julia thread.

The thread count can be changed, for example:

```bash
THREADS=16 make
```

To remove generated intermediate files and the reconstructed table:

```bash
make clean
```

The cleaning step does **not** remove:

```text
best-rgs.txt
```

because this is a retained input representing the selected partition.

---

## Figure S4

### Purpose

Figure S4 compares relative effective reproduction numbers estimated using FindPart-w-epsilon with estimates from previous studies.

Change to:

```bash
cd 03-Figures_and_Tables/11-Fig.S4
```

The figure contains separate USA-19 and UK-141 comparisons.

### USA-19 comparison

The FindPart-w-epsilon estimates are obtained from:

```text
../09-Table1/best_estimates_with_rri.csv
```

These estimates are compared with the previous-study estimates stored in:

```text
01-USA/musonda2026_USA19_relative_Re.csv
```

The comparison is performed by:

```text
01-USA/compare_musonda_vs_FindPart.R
```

The baseline lineage:

```text
KP.3.1.1
```

is excluded from the Pearson correlation.

The workflow generates:

```text
01-USA/USA19_Musonda2026_vs_FindPart_relative_Re.csv
01-USA/USA19_Pearson_correlation.csv
```

### UK-141 comparison

The FindPart-w-epsilon estimates are obtained from:

```text
../10-Table2/best_estimates_with_rri.csv
```

These estimates are compared with the previous-study estimates stored in:

```text
02-UK/kaku_2024_UK141_relative_Re.csv
```

The comparison is performed by:

```text
02-UK/compare_Kaku_vs_FindPart.R
```

The baseline lineage:

```text
EG.5.1
```

is excluded from the Pearson correlation.

The workflow generates:

```text
02-UK/UK141_Kaku_vs_FindPart_relative_Re.csv
02-UK/UK141_Pearson_correlation.csv
```

### Reconstructing Figure S4

The Table 1 and Table 2 relative effective reproduction number estimates must first be available:

```text
../09-Table1/best_estimates_with_rri.csv
../10-Table2/best_estimates_with_rri.csv
```

Then run:

```bash
make
```

The plotting script:

```text
plot_relative_Re_comparison.R
```

generates:

```text
Fig.S4.tiff
```

To remove the generated comparison datasets, correlation results, and figure:

```bash
make clean
```

The previous-study input datasets are retained.

---

# Summary of the Main Reproduction Workflow

The repository is designed so that computationally expensive searches and manuscript-output reconstruction can be performed separately.

## Step 1: Install dependencies

From the repository root:

```bash
julia install_packages.jl
R -f install_packages.R
```

## Step 2: Run the USA epsilon-connectivity analyses

Lemma enabled:

```bash
cd 01-USA-epsilon-connectivity-analysis/01-lemma-enabled
bash create_folders.sh 16
bash run_folders.sh 16
```

Lemma disabled:

```bash
cd ../02-lemma-disabled
bash create_folders.sh 16
bash run_folders.sh 16
```

## Step 3: Run the UK epsilon-connectivity analyses

Return to the repository root and run:

```bash
cd 02-UK-epsilon-connectivity-analysis/01-lemma-enabled
bash create_folders.sh 24
bash run_folders.sh 24

cd ../02-lemma-disabled
bash create_folders.sh 24
bash run_folders.sh 24
```

These full analyses can require substantial computation.

## Step 4: Reconstruct manuscript outputs

The figure and table workflows are located under:

```text
03-Figures_and_Tables/
```

For Makefile-based workflows, enter the corresponding directory and run:

```bash
make
```

For example:

```bash
cd 03-Figures_and_Tables/01-Fig.1
make
```

The important exceptions and dependencies are:

- Figure 3 is retained directly and is not regenerated.
- Figure 5 can be reconstructed directly from retained summary CSV files without rerunning all epsilon searches.
- Figures 6 and 7 can be reconstructed directly from retained beam-width summary files.
- Figure S2 can be reconstructed directly from retained computational summary files.
- Table 1 depends on the retained USA ε = 4 FindPart-w-epsilon result.
- Table 2 retains the selected `best-rgs.txt` partition so that the complete UK w = 21 search does not have to be repeated merely to reconstruct the table.
- Figure S4 depends on the relative effective reproduction number outputs generated by the Table 1 and Table 2 workflows.

---

# Retained Results Versus Generated Files

The repository intentionally retains compact results that are useful for reconstructing manuscript outputs without repeating computationally expensive searches.

Examples include:

- Figure 4 and Figure S3 computational summary CSV files.
- Figure 5 BIC, log-likelihood, and rank summaries.
- Figures 6 and 7 beam-width summary CSV files.
- Figure S2 computational summary CSV files.
- The selected UK-141 `best-rgs.txt` partition used by Table 2.

Other intermediate files are generated during the workflows and can be removed after reproduction.

This design provides two levels of reproducibility:

1. **Manuscript-output reconstruction** — regenerate figures and tables from retained analysis results.
2. **Full computational reproduction** — rerun the underlying FindPart-w-epsilon searches from the canonical lineage-count datasets.

---

# Computational Runtime

Some FindPart-w-epsilon analyses are computationally intensive.

This is particularly important for:

- The UK-141 epsilon-connectivity analyses.
- Large beam-width searches.
- The UK w = 21 analysis used to identify the selected Table 2 partition.

The computational workflows default to:

```text
THREADS=1
```

for portability.

Where supported, additional Julia threads can be specified to take advantage of systems with more CPU resources.

For example:

```bash
THREADS=16 make
```

or for the epsilon-analysis driver:

```bash
bash run_folders.sh 24 16
```

Recorded elapsed times should not be expected to reproduce exactly on another computer.

Runtime depends on factors including:

- Processor architecture.
- Available CPU resources.
- Number of Julia threads.
- System load.
- Julia version.
- Software environment.

The number of MLE calculations is determined by the computational search, whereas elapsed time also depends on the computing environment.

---

# Cleaning Generated Outputs

Most figure and table directories provide:

```bash
make clean
```

to remove regenerated outputs and temporary intermediate files.

The epsilon-connectivity run Makefiles provide:

```bash
make clean-heavy
```

for removing large regenerable computational files from an individual epsilon directory.

The cleaning commands are designed to preserve canonical input datasets, shared source code, retained summary results, and other files required for reproducibility.

Before deleting computational outputs manually, check whether the file is a retained input or summary used by another reconstruction workflow.

---

# Notes on Reproducibility

The canonical lineage-count datasets and shared source programs are stored centrally so that individual analysis directories do not require duplicate copies of the same data or code.

Pairwise Pangolin genetic-distance files and lineage-alias files are generated locally by workflows that require them.

The principal analyses use BIC for model selection.

The USA-19 principal FindPart-w-epsilon analysis uses a genetic-connectivity threshold of:

```text
ε = 4
```

The UK-141 principal FindPart-w-epsilon analysis uses:

```text
ε = 7
```

The beam-width analysis for UK-141 identified:

```text
w = 21
```

as the beam width with the minimum BIC among the evaluated widths. The selected w = 21 partition is retained for reconstruction of Table 2.

The repository retains compact computational summaries where rerunning the complete search would otherwise be unnecessarily expensive for reproducing a manuscript figure.

Individual analysis and figure/table directories also contain local README files with workflow-specific information. These local README files supplement this root README.
