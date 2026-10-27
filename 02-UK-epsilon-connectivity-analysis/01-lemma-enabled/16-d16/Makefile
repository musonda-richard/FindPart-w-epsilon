ROOT := ../../..
UK_DATA := $(ROOT)/00-files/02-UK-data/count_variants.csv
ALIAS := $(ROOT)/alias.jl
CALC_DIST := $(ROOT)/calc_pangolin_distances.jl
FINDPART := $(ROOT)/FindPart-w-epsilon.jl
RELRE_CORE := $(ROOT)/RelRe_Softmax_Core.jl
SETPART := $(ROOT)/lib_setpartition.jl
LIB_PANGOLIN := $(ROOT)/lib_pangolin.jl
LINEAGE_NOTES := $(ROOT)/lineage_notes.txt

THREADS ?= 1
FTOL_REL ?= 1e-9
BASELINE ?= EG.5.1
WIDTH ?= 1
EPSILON ?= 1
MODEL_SEL ?= BIC
LEMMA_OPTION ?= lemma
DBSCAN_OPTION ?= no_dbscan

all: rgs-$(MODEL_SEL).csv

pangolin_alias.csv: $(ALIAS) $(LINEAGE_NOTES)
	julia "$(ALIAS)" > "$@"

pangolin_distances.csv: pangolin_alias.csv $(UK_DATA) $(CALC_DIST) $(LIB_PANGOLIN)
	julia "$(CALC_DIST)" "$(UK_DATA)"

rgs-$(MODEL_SEL).csv: pangolin_distances.csv $(UK_DATA) $(FINDPART) $(RELRE_CORE) $(SETPART)
	JULIA_NUM_THREADS=$(THREADS) julia "$(FINDPART)" "$(UK_DATA)" $(BASELINE) $(FTOL_REL) $(WIDTH) $(EPSILON) $(MODEL_SEL) $(LEMMA_OPTION) $(DBSCAN_OPTION)
	mv rgs-score.csv "$@"

best-rgs.txt: rgs-$(MODEL_SEL).csv
	awk -F',' 'NR==2 {gsub(/-/," ",$$1); print $$1; exit}' "$<" > "$@"

clean-heavy:
	rm -f rgs-score.csv rgs-AIC.csv rgs-BIC.csv
	rm -f RelRe_time_taken.csv rgs_no_chance.csv
	rm -f pangolin_alias.csv pangolin_distances.csv
	rm -f dbscan_result_epsilon*.csv dbscan_result*
	rm -f *.log nohup*

.PHONY: all clean-heavy
