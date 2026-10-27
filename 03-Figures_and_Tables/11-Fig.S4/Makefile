all: Fig.S4.tiff

01-USA/USA19_Musonda2026_vs_FindPart_relative_Re.csv \
01-USA/USA19_Pearson_correlation.csv: \
01-USA/compare_musonda_vs_FindPart.R \
01-USA/musonda2026_USA19_relative_Re.csv \
../09-Table1/best_estimates_with_rri.csv
	cd 01-USA && R -f compare_musonda_vs_FindPart.R

02-UK/UK141_Kaku_vs_FindPart_relative_Re.csv \
02-UK/UK141_Pearson_correlation.csv: \
02-UK/compare_Kaku_vs_FindPart.R \
02-UK/kaku_2024_UK141_relative_Re.csv \
../10-Table2/best_estimates_with_rri.csv
	cd 02-UK && R -f compare_Kaku_vs_FindPart.R

Fig.S4.tiff: \
plot_relative_Re_comparison.R \
01-USA/USA19_Musonda2026_vs_FindPart_relative_Re.csv \
02-UK/UK141_Kaku_vs_FindPart_relative_Re.csv
	R -f plot_relative_Re_comparison.R

clean:
	rm -f \
	01-USA/USA19_Musonda2026_vs_FindPart_relative_Re.csv \
	01-USA/USA19_Pearson_correlation.csv \
	02-UK/UK141_Kaku_vs_FindPart_relative_Re.csv \
	02-UK/UK141_Pearson_correlation.csv \
	Fig.S4.tiff

.PHONY: all clean
