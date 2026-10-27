.PHONY: all copyfiles clean

all: pairwise_gen_distances.csv

copyfiles:
	cp ../../../00-files/02-UK-data/count_variants.csv .
	cp ../../../lib_pangolin.jl .
	cp ../../../lib_setpartition.jl .
	cp ../../../alias.jl .
	cp ../../../lineage_notes.txt .
	cp ../../../pairwise_gen_distances.jl .
	cp ../../../calc_pangolin_distances.jl .

pangolin_alias.csv: copyfiles
	julia alias.jl > pangolin_alias.csv

pairwise_gen_distances.csv: copyfiles pangolin_alias.csv
	julia pairwise_gen_distances.jl count_variants.csv

clean:
	rm -f pangolin_alias.csv pairwise_gen_distances.csv count_variants.csv
	rm -f lib_pangolin.jl lib_setpartition.jl alias.jl lineage_notes.txt
	rm -f pairwise_gen_distances.jl calc_pangolin_distances.jl
