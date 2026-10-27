ROOT := ../..
UK_DATA := $(ROOT)/00-files/02-UK-data/count_variants.csv
RELRE := $(ROOT)/RelRe_Softmax.jl
ALIAS := $(ROOT)/alias.jl
CALC_DIST := $(ROOT)/calc_pangolin_distances.jl

FTOL_REL ?= 1e-9
BASELINE ?= EG.5.1
MODEL_SEL ?= BIC
GENERATION_TIME ?= 2.1
THREADS ?= 1

all: Table2.csv

best_estimates.csv: best-rgs.txt $(UK_DATA) $(RELRE)
	JULIA_NUM_THREADS=$(THREADS) julia "$(RELRE)" -b $(BASELINE) -i "$(UK_DATA)" -d 1 --ftol_rel $(FTOL_REL) -u -k $(MODEL_SEL) -r $$(cat best-rgs.txt) -o best -c

best_blocks.csv: best_estimates.csv
	@test -f "$@"

best_estimates_with_rri.csv: best_estimates.csv rri_conversions.R
	GENERATION_TIME=$(GENERATION_TIME) R -f rri_conversions.R

pangolin_alias.csv: $(ALIAS) $(ROOT)/lineage_notes.txt
	julia "$(ALIAS)" > pangolin_alias.csv

pangolin_distances.csv: pangolin_alias.csv $(UK_DATA) $(CALC_DIST) $(ROOT)/lib_pangolin.jl
	julia "$(CALC_DIST)" "$(UK_DATA)"

Table2.csv: best_estimates_with_rri.csv best_blocks.csv pangolin_distances.csv Table2.R
	PANGOLIN_DISTANCES="pangolin_distances.csv" R -f Table2.R

clean:
	rm -f best_estimates.csv
	rm -f best_loglikelihood.csv
	rm -f best_blocks.csv
	rm -f best_estimates_with_rri.csv
	rm -f Table2.csv
	rm -f loglikelihood.csv
	rm -f pangolin_alias.csv
	rm -f pangolin_distances.csv

.PHONY: all clean
