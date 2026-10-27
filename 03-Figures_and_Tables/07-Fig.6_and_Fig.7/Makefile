all: Fig6.tiff Fig7.tiff

Fig6.tiff: plot_Fig6.R 01-USA/mle_by_width.csv 02-UK/mle_by_width.csv
	R -f plot_Fig6.R

Fig7.tiff: plot_Fig7.R 01-USA/bic_by_width.csv 02-UK/bic_by_width.csv
	R -f plot_Fig7.R

clean:
	rm -f Fig6.tiff Fig7.tiff
