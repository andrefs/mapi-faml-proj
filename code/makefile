
relatedness_full.tsv: WORD.csv
	csvquote WORD.csv | tail -n +2 |  awk 'BEGIN {FS=","; OFS="\t"} {print $$5,$$6,$$4,$$7}' | sed 's/https:\/\/en.wikipedia.org\/wiki\//http:\/\/dbpedia.org\/resource\//g' | csvquote -u | sed 's/^"//' | sed 's/"\t\|\t"/\t/g' | sed 's/$$//' > relatedness_full.tsv

DBpediaVectors200_20Shuffle.txt.gz:
	curl http://data.dws.informatik.uni-mannheim.de/rdf2vec/models/DBpedia/2016-04/GlobalVectors/11_pageRankSplit/DBpediaVecotrs200_20Shuffle.txt | gzip > DBpediaVectors200_20Shuffle.txt.gz


entities.txt: relatedness_full.tsv
	#cat relatedness_full.tsv | cut -f1,2 | sed 's/\t/\n/' | sort | uniq -c | sort -nr > entities.txt
	cat relatedness_full.tsv | cut -f1,2 | sed 's/\t/\n/' | sed 's/^/</' | sed 's/$$/>/' | sort | uniq > entities.txt


embeddings.txt: DBpediaVectors200_20Shuffle.txt.gz entities.txt
	pv DBpediaVectors200_20Shuffle.txt.gz | gunzip | grep -f entities.txt -F | sed 's/^<//' | sed 's/> / /' > embeddings.txt


relatedness.tsv: embeddings.txt relatedness_full.tsv
	./filter_relatedness > relatedness.tsv

relatedness_train.tsv: relatedness.tsv
	grep 'Train$$' relatedness.tsv > relatedness_train.tsv

relatedness_test.tsv: relatedness.tsv
	grep 'Test$$' relatedness.tsv > relatedness_test.tsv
