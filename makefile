
1_original_datasets/WORD.zip:
	curl "https://www.research.ibm.com/haifa/dept/vst/files/IBM_Debater_(R)_WORD-LREC-2018.v0.zip" > 1_original_datasets/WORD.zip

1_original_datasets/WORD.csv:
	unzip -p 1_original_datasets/WORD.zip WORD.csv > 1_original_datasets/WORD.csv

1_original_datasets/DBpediaVectors200_20Shuffle.txt.gz:
	curl http://data.dws.informatik.uni-mannheim.de/rdf2vec/models/DBpedia/2016-04/GlobalVectors/11_pageRankSplit/DBpediaVecotrs200_20Shuffle.txt | gzip > 1_original_datasets/DBpediaVectors200_20Shuffle.txt.gz



2_clean_datasets/relatedness_full.tsv: 1_original_datasets/WORD.csv
	csvquote 1_original_datasets/WORD.csv | tail -n +2 |  awk 'BEGIN {FS=","; OFS="\t"} {print $$5,$$6,$$4,$$7}' | sed 's/https:\/\/en.wikipedia.org\/wiki\//http:\/\/dbpedia.org\/resource\//g' | csvquote -u | sed 's/^"//' | sed 's/"\t\|\t"/\t/g' | sed 's/$$//' > 2_clean_datasets/relatedness_full.tsv



2_clean_datasets/entities.txt: 2_clean_datasets/relatedness_full.tsv
	#cat relatedness_full.tsv | cut -f1,2 | sed 's/\t/\n/' | sort | uniq -c | sort -nr > entities.txt
	cat 2_clean_datasets/relatedness_full.tsv | cut -f1,2 | sed 's/\t/\n/' | sed 's/^/</' | sed 's/$$/>/' | sort | uniq > 2_clean_datasets/entities.txt


2_clean_datasets/embeddings.txt: 1_original_datasets/DBpediaVectors200_20Shuffle.txt.gz 2_clean_datasets/entities.txt
	pv 1_original_datasets/DBpediaVectors200_20Shuffle.txt.gz | gunzip | grep -f 2_clean_datasets/entities.txt -F | sed 's/^<//' | sed 's/> / /' > 2_clean_datasets/embeddings.txt


2_clean_datasets/relatedness.tsv: 2_clean_datasets/embeddings.txt 2_clean_datasets/relatedness_full.tsv
	./code/filter_relatedness > 2_clean_datasets/relatedness.tsv

2_clean_datasets/relatedness_train.tsv: 2_clean_datasets/relatedness.tsv
	grep 'Train$$' 2_clean_datasets/relatedness.tsv > 2_clean_datasets/relatedness_train.tsv

2_clean_datasets/relatedness_test.tsv: 2_clean_datasets/relatedness.tsv
	grep 'Test$$' 2_clean_datasets/relatedness.tsv > 2_clean_datasets/relatedness_test.tsv


## Make pairs symmetrical

2_clean_datasets/relatedness_sym.tsv: 2_clean_datasets/relatedness.tsv
	./code/sym_relatedness > 2_clean_datasets/relatedness_sym.tsv

2_clean_datasets/relatedness_sym_train.tsv: 2_clean_datasets/relatedness_sym.tsv
	grep 'Train$$' 2_clean_datasets/relatedness_sym.tsv > 2_clean_datasets/relatedness_sym_train.tsv

2_clean_datasets/relatedness_sym_test.tsv: 2_clean_datasets/relatedness_sym.tsv
	grep 'Test$$' 2_clean_datasets/relatedness_sym.tsv > 2_clean_datasets/relatedness_sym_test.tsv



## Merged datasets
2_clean_datasets/merged_ds: 2_clean_datasets/relatedness.tsv 2_clean_datasets/embeddings.txt
	code/merge_datasets > 2_clean_datasets/merged_ds

2_clean_datasets/ds_train: 2_clean_datasets/merged_ds
	grep 'Train$$' 2_clean_datasets/merged_ds > 2_clean_datasets/ds_train

2_clean_datasets/ds_test: 2_clean_datasets/merged_ds
	grep 'Test$$' 2_clean_datasets/merged_ds > 2_clean_datasets/ds_test

2_clean_datasets/ds_train_embs: 2_clean_datasets/ds_train
	cut -f 3-403 2_clean_datasets/ds_train > 2_clean_datasets/ds_train_embs

2_clean_datasets/ds_train_ents: 2_clean_datasets/ds_train
	cut -f 1,2 2_clean_datasets/ds_train > 2_clean_datasets/ds_train_ents

2_clean_datasets/ds_test_embs: 2_clean_datasets/ds_test
	cut -f 4-403 2_clean_datasets/ds_test > 2_clean_datasets/ds_test_embs

2_clean_datasets/ds_test_target: 2_clean_datasets/ds_test
	cut -f 3 2_clean_datasets/ds_test > 2_clean_datasets/ds_test_target

2_clean_datasets/ds_test_ents: 2_clean_datasets/ds_test
	cut -f 1-3 2_clean_datasets/ds_test > 2_clean_datasets/ds_test_ents

## Symmetrical merged datasets

2_clean_datasets/merged_sym: 2_clean_datasets/relatedness_sym.tsv 2_clean_datasets/embeddings.txt
	code/merge_datasets 2_clean_datasets/relatedness_sym.tsv > 2_clean_datasets/merged_sym


2_clean_datasets/ds_train_sym: 2_clean_datasets/merged_ds
	grep 'Train$$' 2_clean_datasets/merged_ds > 2_clean_datasets/ds_train_sym

2_clean_datasets/ds_test_sym: 2_clean_datasets/merged_ds
	grep 'Test$$' 2_clean_datasets/merged_ds > 2_clean_datasets/ds_test_sym

2_clean_datasets/ds_train_sym_embs: 2_clean_datasets/ds_train_sym
	cut -f 3-403 2_clean_datasets/ds_train_sym > 2_clean_datasets/ds_train_sym_embs

2_clean_datasets/ds_train_sym_ents: 2_clean_datasets/ds_train_sym
	cut -f 1,2 2_clean_datasets/ds_train_sym > 2_clean_datasets/ds_train_sym_ents

2_clean_datasets/ds_test_sym_embs: 2_clean_datasets/ds_test_sym
	cut -f 4-403 2_clean_datasets/ds_test_sym > 2_clean_datasets/ds_test_sym_embs

2_clean_datasets/ds_test_sym_target: 2_clean_datasets/ds_test_sym
	cut -f 3 2_clean_datasets/ds_test_sym > 2_clean_datasets/ds_test_sym_target

2_clean_datasets/ds_test_sym_ents: 2_clean_datasets/ds_test_sym
	cut -f 1-3 2_clean_datasets/ds_test_sym > 2_clean_datasets/ds_test_sym_ents

