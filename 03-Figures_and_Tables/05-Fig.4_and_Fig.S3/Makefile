all: Fig.4.tiff Fig.S3.tiff

01-elapsed_num.mle-USA/num_mle.csv 01-elapsed_num.mle-USA/elapsed.csv:
	bash get_elapsed_and_num.mle.sh USA

02-elapsed_num.mle-UK/num_mle.csv 02-elapsed_num.mle-UK/elapsed.csv:
	bash get_elapsed_and_num.mle.sh UK

Fig.4.tiff: plot_Fig4.R 01-elapsed_num.mle-USA/num_mle.csv 02-elapsed_num.mle-UK/num_mle.csv
	R -f plot_Fig4.R

Fig.S3.tiff: plot_S3.R 01-elapsed_num.mle-USA/elapsed.csv 02-elapsed_num.mle-UK/elapsed.csv
	R -f plot_S3.R

collect:
	bash get_elapsed_and_num.mle.sh USA
	bash get_elapsed_and_num.mle.sh UK

clean:
	rm -f Fig.4.tiff Fig.S3.tiff

.PHONY: all collect clean
