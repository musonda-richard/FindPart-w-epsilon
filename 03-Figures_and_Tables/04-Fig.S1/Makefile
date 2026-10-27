.PHONY: all usa uk clean

all: Fig.S1.tiff

usa:
	$(MAKE) -C 01-USA-pairwise-distances pairwise_gen_distances.csv

uk:
	$(MAKE) -C 02-UK-pairwise-distances pairwise_gen_distances.csv

Fig.S1.tiff: usa uk Fig.S1.R
	R -f Fig.S1.R

clean:
	$(MAKE) -C 01-USA-pairwise-distances clean
	$(MAKE) -C 02-UK-pairwise-distances clean
	rm -f Fig.S1.tiff
