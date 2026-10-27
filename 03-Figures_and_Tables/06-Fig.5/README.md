# Figure 5

This directory contains the files used to reproduce **Figure 5**.

Figure 5 shows the BIC, maximum log-likelihood, and rank of the partitions obtained by FindPart-\(w\)-\(\epsilon\) across genetic distance thresholds for the USA-19 and UK-141 datasets, using beam width \(w=1\).

## Reproducing the figure

The plotting data are retained in:

- `BIC_by_epsilon_USA_UK.csv`
- `loglik_by_epsilon.csv`
- `rank_by_epsilon.csv`

From this directory, run:

```bash
make
```

This generates `Fig.5.tiff`.

To remove the generated figure, run:

```bash
make clean
```

## Regenerating the summary data

The scripts `collect_BIC.sh`, `collect_ll.sh`, and `collect_rank.sh` reconstruct the three summary CSV files from `rgs-BIC.csv` files produced by the upstream USA and UK epsilon-connectivity analyses.

The repository retains the summary CSV files so that Figure 5 can be reproduced directly without rerunning all upstream analyses.

To reconstruct the summary CSV files from scratch, first rerun the required upstream epsilon-connectivity analyses to generate their `rgs-BIC.csv` outputs, and then run the corresponding collection scripts.
