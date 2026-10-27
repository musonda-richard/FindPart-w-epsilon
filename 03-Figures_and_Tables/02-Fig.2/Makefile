all: Fig2.pdf Fig2.tiff

Fig2.pdf Fig2.tiff &: combine_epsilon.R e1.pdf e2.pdf e-infty.pdf
	R -f combine_epsilon.R

clean:
	rm -f Fig2.pdf Fig2.tiff
