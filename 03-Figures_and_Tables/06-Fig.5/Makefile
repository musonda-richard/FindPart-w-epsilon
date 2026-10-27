all: Fig.5.tiff

Fig.5.tiff: plot_Fig5.R rank_by_epsilon.csv BIC_by_epsilon_USA_UK.csv loglik_by_epsilon.csv
	R -f plot_Fig5.R

clean:
	rm -f Fig.5.tiff

.PHONY: all clean
