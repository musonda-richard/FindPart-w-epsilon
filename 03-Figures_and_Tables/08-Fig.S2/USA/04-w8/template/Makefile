THREADS ?= 1
FTOL_REL=1e-9
BASELINE=KP.3.1.1
WIDTH=8
EPSILON=1
MODEL_SEL ?= BIC

LEMMA_OPTION ?= lemma
DBSCAN_OPTION ?= no_dbscan

ROOT=../../../../..
COUNT=$(ROOT)/00-files/01-USA-data/count_variants.csv
ALIAS=$(ROOT)/alias.jl
CALC_DIST=$(ROOT)/calc_pangolin_distances.jl
FINDPART=$(ROOT)/FindPart-w-epsilon.jl
RELRE_CORE=$(ROOT)/RelRe_Softmax_Core.jl
SET_PARTITION=$(ROOT)/lib_setpartition.jl

all: rgs-$(MODEL_SEL).csv

pangolin_alias.csv: $(ALIAS) $(ROOT)/lineage_notes.txt
	julia $(ALIAS) > pangolin_alias.csv

pangolin_distances.csv: pangolin_alias.csv $(COUNT) $(CALC_DIST) $(ROOT)/lib_pangolin.jl
	julia $(CALC_DIST) $(COUNT)

rgs-$(MODEL_SEL).csv: $(COUNT) pangolin_distances.csv $(RELRE_CORE) $(FINDPART) $(SET_PARTITION)
	time julia --threads=$(THREADS) $(FINDPART) $(COUNT) $(BASELINE) $(FTOL_REL) $(WIDTH) $(EPSILON) $(MODEL_SEL) $(LEMMA_OPTION) $(DBSCAN_OPTION)
	mv rgs-score.csv rgs-$(MODEL_SEL).csv

best-rgs.txt: rgs-$(MODEL_SEL).csv
	head -n 2 rgs-$(MODEL_SEL).csv | tail -n 1 | cut -d, -f 1 | tr '-' ' ' > best-rgs.txt

clean:
	rm -f rgs-score.csv
	rm -f rgs-AIC.csv
	rm -f rgs-BIC.csv
	rm -f best-rgs.txt
	rm -f estimates.csv
	rm -f loglikelihood.csv
	rm -f elapsed.csv
	rm -f finest_elapsed.csv
	rm -f rgs_no_chance.csv
	rm -f RelRe_time_taken.csv
	rm -f pangolin_alias.csv
	rm -f pangolin_distances.csv
	rm -f dbscan_result_epsilon*.csv
	rm -f mle_by_rank*
	rm -f dbscan_result*
	rm -f bloc*
	find . -maxdepth 1 -type f -name '*.log' -delete
