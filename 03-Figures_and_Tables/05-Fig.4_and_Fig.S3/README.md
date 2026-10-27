# Figure 4 and Figure S3 — Effect of the lemma

This directory generates Figure 4 and Figure S3 for the USA-19 and UK-141
datasets.

Both analyses compare FindPart-w-epsilon with and without the lemma across
genetic distance thresholds (epsilon), using beam width w = 1.

## Figure 4

Figure 4 shows the number of maximum-likelihood estimations (MLEs) performed
with and without the lemma.

The plotted data are:

    01-elapsed_num.mle-USA/num_mle.csv
    02-elapsed_num.mle-UK/num_mle.csv

These files are collected from the corresponding epsilon-connectivity
analysis outputs:

    ../../01-USA-epsilon-connectivity-analysis/
    ../../02-UK-epsilon-connectivity-analysis/

The final output is:

    Fig.4.tiff

## Figure S3

Figure S3 shows the running time of FindPart-w-epsilon with and without the
lemma.

Running times are converted from milliseconds to minutes for plotting.

The plotted data are:

    01-elapsed_num.mle-USA/elapsed.csv
    02-elapsed_num.mle-UK/elapsed.csv

The final output is:

    Fig.S3.tiff

## Regenerating the collected data

Run:

    make collect

to reconstruct the elapsed-time and MLE-count CSV files from the upstream
USA and UK epsilon-connectivity analyses.

## Generating the figures

Run:

    make

to generate:

    Fig.4.tiff
    Fig.S3.tiff

Run:

    make clean

to remove the generated TIFF files.
