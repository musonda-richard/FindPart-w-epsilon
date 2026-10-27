all: Fig.S2.tiff

Fig.S2.tiff: plot_Fig.S2.R USA/mle_runtime_by_width_epsilon.csv UK/mle_runtime_by_width_epsilon.csv
	R -f plot_Fig.S2.R

clean:
	rm -f Fig.S2.tiff
