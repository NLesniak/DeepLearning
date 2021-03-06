REFS = data/references
FIGS = results/figures
TABLES = results/tables
PROC = data/process
FINAL = submission/
CODE = code/learning


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

$(PROC)/combined_all_imp_features_results_XGBoost.csv\
$(PROC)/combined_all_hp_results_XGBoost.csv\
$(PROC)/combined_best_hp_results_XGBoost.csv	:	data/baxter.0.03.subsample.shared\
														data/metadata.tsv\
														$(CODE)/generateAUCs.R\
														$(CODE)/model_pipeline.R\
														$(CODE)/model_interpret.R\
														$(CODE)/main.R\
														$(CODE)/model_selection.R\
														XGBoost.pbs
			qsub XGBoost.pbs

$(PROC)/combined_all_imp_features_results_Random_Forest.csv\
$(PROC)/combined_all_hp_results_Random_Forest.csv\
$(PROC)/combined_best_hp_results_Random_Forest.csv	:	data/baxter.0.03.subsample.shared\
														data/metadata.tsv\
														$(CODE)/generateAUCs.R\
														$(CODE)/model_pipeline.R\
														$(CODE)/model_interpret.R\
														$(CODE)/main.R\
														$(CODE)/model_selection.R\
														Random_Forest.pbs
			qsub Random_Forest.pbs



$(PROC)/combined_all_imp_features_results_Decision_Tree.csv\
$(PROC)/combined_all_hp_results_Decision_Tree.csv\
$(PROC)/combined_best_hp_results_Decision_Tree.csv	:	data/baxter.0.03.subsample.shared\
														data/metadata.tsv\
														$(CODE)/generateAUCs.R\
														$(CODE)/model_pipeline.R\
														$(CODE)/model_interpret.R\
														$(CODE)/main.R\
														$(CODE)/model_selection.R\
														Decision_Tree.pbs
			qsub Decision_Tree.pbs



$(PROC)/combined_all_imp_features_results_RBF_SVM.csv\
$(PROC)/combined_all_hp_results_RBF_SVM.csv\
$(PROC)/combined_best_hp_results_RBF_SVM.csv	:	data/baxter.0.03.subsample.shared\
														data/metadata.tsv\
														$(CODE)/generateAUCs.R\
														$(CODE)/model_pipeline.R\
														$(CODE)/model_interpret.R\
														$(CODE)/main.R\
														$(CODE)/model_selection.R\
														RBF_SVM.pbs
			qsub RBF_SVM.pbs

$(PROC)/combined_all_imp_features_results_L2_Logistic_Regression.csv\
$(PROC)/combined_all_hp_results_L2_Logistic_Regression.csv\
$(PROC)/combined_best_hp_results_L2_Logistic_Regression.csv	:	data/baxter.0.03.subsample.shared\
														data/metadata.tsv\
														$(CODE)/generateAUCs.R\
														$(CODE)/model_pipeline.R\
														$(CODE)/model_interpret.R\
														$(CODE)/main.R\
														$(CODE)/model_selection.R\
														L2_Logistic_Regression.pbs
			qsub L2_Logistic_Regression.pbs


$(PROC)/combined_all_imp_features_results_L1_Linear_SVM.csv\
$(PROC)/combined_all_hp_results_L1_Linear_SVM.csv\
$(PROC)/combined_best_hp_results_L1_Linear_SVM.csv	:	data/baxter.0.03.subsample.shared\
														data/metadata.tsv\
														$(CODE)/generateAUCs.R\
														$(CODE)/model_pipeline.R\
														$(CODE)/model_interpret.R\
														$(CODE)/main.R\
														$(CODE)/model_selection.R\
														L1_Linear_SVM.pbs
			qsub L1_Linear_SVM.pbs

$(PROC)/combined_all_imp_features_results_L2_Linear_SVM.csv\
$(PROC)/combined_all_hp_results_L2_Linear_SVM.csv\
$(PROC)/combined_best_hp_results_L2_Linear_SVM.csv	:	data/baxter.0.03.subsample.shared\
														data/metadata.tsv\
														$(CODE)/generateAUCs.R\
														$(CODE)/model_pipeline.R\
														$(CODE)/model_interpret.R\
														$(CODE)/main.R\
														$(CODE)/model_selection.R\
														code/cat_csv_files.sh\
														L2_Linear_SVM.pbs
			qsub L2_Linear_SVM.pbs
			bash code/test_sleep.sh
			bash code/cat_csv_files.sh

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
						$(PROC)/combined_best_hp_results_XGBoost.csv\
						$(PROC)/combined_best_hp_results_Random_Forest.csv\
						$(PROC)/combined_best_hp_results_Decision_Tree.csv\
						$(PROC)/combined_best_hp_results_RBF_SVM.csv\
						$(PROC)/combined_best_hp_results_L2_Logistic_Regression.csv\
						$(PROC)/combined_best_hp_results_L1_Linear_SVM.csv\
						$(PROC)/combined_best_hp_results_L2_Linear_SVM.csv
	Rscript $(CODE)/Figure1.R

# Figure 2 shows the hyper-parameter tuning of all the models tested.
$(FIGS)/Figure_2.pdf :	$(CODE)/functions.R\
						$(CODE)/Figure2.R\
						$(PROC)/combined_all_hp_results_XGBoost.csv\
						$(PROC)/combined_all_hp_results_Random_Forest.csv\
						$(PROC)/combined_all_hp_results_Decision_Tree.csv\
						$(PROC)/combined_all_hp_results_RBF_SVM.csv\
						$(PROC)/combined_all_hp_results_L2_Logistic_Regression.csv\
						$(PROC)/combined_all_hp_results_L1_Linear_SVM.csv\
						$(PROC)/combined_all_hp_results_L2_Linear_SVM.csv
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
