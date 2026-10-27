ROOT := ../..
USA_DATA := $(ROOT)/00-files/01-USA-data/count_variants.csv
USA_D4 := $(ROOT)/01-USA-epsilon-connectivity-analysis/01-lemma-enabled/04-d4
RGS_SRC := $(USA_D4)/rgs-BIC.csv
RELRE := $(ROOT)/RelRe_Softmax.jl
ALIAS := $(ROOT)/alias.jl
CALC_DIST := $(ROOT)/calc_pangolin_distances.jl

FTOL_REL ?= 1e-9
BASELINE ?= KP.3.1.1
MODEL_SEL ?= BIC
GENERATION_TIME ?= 3.0
THREADS ?= 1

all: Table1.csv

best-rgs.txt: $(RGS_SRC)
	awk -F',' 'NR==2 {gsub(/-/," ",$$1); print $$1}' "$<" > "$@"

best_estimates.csv: best-rgs.txt $(USA_DATA) $(RELRE)
	JULIA_NUM_THREADS=$(THREADS) julia "$(RELRE)" -b $(BASELINE) -i "$(USA_DATA)" -d 1 --ftol_rel $(FTOL_REL) -u -k $(MODEL_SEL) -r $$(cat best-rgs.txt) -o best -c

best_blocks.csv: best_estimates.csv
	@test -f "$@"

best_estimates_with_rri.csv: best_estimates.csv rri_conversions.R
	GENERATION_TIME=$(GENERATION_TIME) R -f rri_conversions.R

pangolin_alias.csv: $(ALIAS) $(ROOT)/lineage_notes.txt
	julia "$(ALIAS)" > pangolin_alias.csv

pangolin_distances.csv: pangolin_alias.csv $(USA_DATA) $(CALC_DIST) $(ROOT)/lib_pangolin.jl
	julia "$(CALC_DIST)" "$(USA_DATA)"

Table1.csv: best_estimates_with_rri.csv best_blocks.csv pangolin_distances.csv Table1.R
	PANGOLIN_DISTANCES="pangolin_distances.csv" R -f Table1.R

clean:
	rm -f best-rgs.txt
	rm -f best_estimates.csv
	rm -f best_loglikelihood.csv
	rm -f best_blocks.csv
	rm -f best_estimates_with_rri.csv
	rm -f Table1.csv
	rm -f loglikelihood.csv
	rm -f pangolin_alias.csv
	rm -f pangolin_distances.csv

.PHONY: all clean
