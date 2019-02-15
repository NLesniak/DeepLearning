REFS = data/references
FIGS = results/figures
TABLES = results/tables
PROC = data/process
FINAL = submission/
CODE = code/learning

# utility function to print various variables. For example, running the
# following at the command line:
#
#	make print-BAM
#
# will generate:
#	BAM=data/raw_june/V1V3_0001.bam data/raw_june/V1V3_0002.bam ...
print-%:
	@echo '$*=$($*)'

################################################################################
#
# Part 1: Retrieve the subsampled shared file and metadata files that Marc Sze
# published in https://github.com/SchlossLab/Sze_CRCMetaAnalysis_mBio_2018
#
#	Copy from Github
#
################################################################################

data/baxter.0.03.subsample.shared\
data/metadata.tsv	:	code/learning/load_datasets.batch
	bash code/learning/load_datasets.batch

################################################################################
#
# Part 2: Model analysis in R
#
#	Run scripts to perform all the models on the dataset and generate AUC values
#
################################################################################


OUT_NO=$(shell seq 0 99)

L1_ALL_OUT_FILE=$(addprefix data/temp/all_hp_results_L1_Linear_SVM_,$(OUT_NO))
L1_ALL_FILE=$(addsuffix .csv,$(L1_ALL_OUT_FILE))


L2_ALL_OUT_FILE=$(addprefix data/temp/all_hp_results_L2_Logistic_Regression_,$(OUT_NO))
L2_ALL_FILE=$(addsuffix .csv,$(L2_ALL_OUT_FILE))



$(L1_ALL_FILE)	$(L2_ALL_FILE)	:	input.in.intermediate;

.INTERMEDIATE:	input.in.intermediate
input.in.intermediate:	data/baxter.0.03.subsample.shared\
					data/metadata.tsv\
					$(CODE)/generateAUCs.R\
					$(CODE)/model_pipeline.R\
					$(CODE)/model_interpret.R\
					$(CODE)/main.R\
					$(CODE)/model_selection.R
	qsub L2_Logistic_Regression.pbs	qsub L1_Linear_SVM.pbs


$(PROC)/combined_all_hp_results_L1_Linear_SVM.csv\
$(PROC)/combined_all_hp_results_L2_Logistic_Regression.csv
	:						code/cat_csv_files_test.sh\
							$(L1_ALL_FILE)\
							$(L2_ALL_FILE)
		bash code/cat_csv_files_test.sh



################################################################################
#
# Part 3: Figure and table generation
#
#	Run scripts to generate figures and tables
#
################################################################################

# Figure 1 shows the generalization performance of all the models tested.
$(FIGS)/Figure_1.pdf :	$(CODE)/functions.R\
						$(CODE)/Figure1.R\
						$(PROC)/combined_best_hp_results_L2_Logistic_Regression.tsv\
						$(PROC)/combined_best_hp_results_L1_Linear_SVM.tsv\
						$(PROC)/combined_best_hp_results_L2_Linear_SVM.tsv\
						$(PROC)/combined_best_hp_results_RBF_SVM.tsv\
						$(PROC)/combined_best_hp_results_Decision_Tree.tsv\
						$(PROC)/combined_best_hp_results_Random_Forest.tsv\
						$(PROC)/combined_best_hp_results_XGBoost.tsv
	Rscript $(CODE)/Figure1.R

# Figure 2 shows the hyper-parameter tuning of all the models tested.
$(FIGS)/Figure_2.pdf :	$(CODE)/functions.R\
						$(CODE)/Figure2.R\
						$(PROC)/combined_all_hp_results_L2_Logistic_Regression.tsv\
						$(PROC)/combined_all_hp_results_L1_Linear_SVM.tsv\
						$(PROC)/combined_all_hp_results_L2_Linear_SVM.tsv\
						$(PROC)/combined_all_hp_results_RBF_SVM.tsv\
						$(PROC)/combined_all_hp_results_Decision_Tree.tsv\
						$(PROC)/combined_all_hp_results_Random_Forest.tsv\
						$(PROC)/combined_all_hp_results_XGBoost.tsv
	Rscript $(CODE)/Figure2.R

# Table 1 is a summary of the properties of all the models tested.
#$(TABLES)/Table1.pdf :	$(PROC)/model_parameters.txt\#
#						$(TABLES)/Table1.Rmd\#
#						$(TABLES)/header.tex#
#	R -e "rmarkdown::render('$(TABLES)/Table1.Rmd', clean=TRUE)"
#	rm $(TABLES)/Table1.tex









################################################################################
#
# Part 4: Pull it all together
#
# Render the manuscript
#
################################################################################


#$(FINAL)/manuscript.% : 			\ #include data files that are needed for paper don't leave this line with a : \
#						$(FINAL)/mbio.csl\#
#						$(FINAL)/references.bib\#
#						$(FINAL)/manuscript.Rmd#
#	R -e 'render("$(FINAL)/manuscript.Rmd", clean=FALSE)'
#	mv $(FINAL)/manuscript.knit.md submission/manuscript.md
#	rm $(FINAL)/manuscript.utf8.md


#write.paper : $(TABLES)/table_1.pdf $(TABLES)/table_2.pdf\ #customize to include
#				$(FIGS)/figure_1.pdf $(FIGS)/figure_2.pdf\	# appropriate tables and
#				$(FIGS)/figure_3.pdf $(FIGS)/figure_4.pdf\	# figures
#				$(FINAL)/manuscript.Rmd $(FINAL)/manuscript.md\#
#				$(FINAL)/manuscript.tex $(FINAL)/manuscript.pdf
