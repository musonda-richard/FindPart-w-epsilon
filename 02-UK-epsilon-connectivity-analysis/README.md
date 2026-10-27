# UK epsilon-connectivity analysis

This directory contains the epsilon-connectivity analyses for the UK-141 SARS-CoV-2 lineage dataset.

The analyses evaluate genetic-connectivity constraints across epsilon values using FindPart-w-epsilon. The UK analysis uses EG.5.1 as the baseline lineage.

## Directory structure

Two analysis variants are retained:

- `01-lemma-enabled/` — FindPart run with the lemma-based pruning procedure enabled.
- `02-lemma-disabled/` — FindPart run without lemma-based pruning.

Within each directory, folders are named by epsilon value:

```text
00-d0/
01-d1/
02-d2/
...
24-d24/

