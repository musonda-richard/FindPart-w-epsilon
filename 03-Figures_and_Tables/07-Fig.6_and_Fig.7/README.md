# Figures 6 and 7

This directory contains the scripts used to generate Figures 6 and 7.

## USA-19

```bash
cd 01-USA
./create_folders.sh
./run_folders.sh
./collect_bic.sh
./collect_mle.sh
cd ..
```

The analysis evaluates beam widths \(w=1, 10,000, 20,000, \ldots, 200,000, \infty\) with \(\epsilon=4\).

## UK-141

```bash
cd 02-UK
./create_folders.sh 1 23
./run_folders.sh 1 23
./collect_bic.sh
./collect_mle.sh
cd ..
```

The analysis evaluates beam widths \(w=1,\ldots,23\) with \(\epsilon=7\).

## Generate Figures 6 and 7

From this directory, run:

```bash
make
```

This generates `Fig6.tiff` and `Fig7.tiff`.

The analyses use one Julia thread by default. To use multiple threads, set `THREADS` when running the analysis, for example:

```bash
THREADS=16 ./run_folders.sh
```

For the UK analysis:

```bash
THREADS=16 ./run_folders.sh 1 23
```
