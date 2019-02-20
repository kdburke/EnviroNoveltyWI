# EnviroNoveltyWI
Assess agricultural land use, forest composition, and climatic causes of environmental novelty in Wisconsin over the past century

Files included here are associated with "Land-use and climatic causes of environmental novelty in Wisconsin since 1890," by Williams JW, Burke KD, Crossley MS, Grant DA, and Radeloff VC.

corresponding author: jww@geography.wisc.edu

This repository includes the relevant spatial files and information associated with our publication, and the custom R scripts used to create the input county level agriculture means. The 'analog_fast' directory contains custom Matlab scripts used to calculate the dissimilarity scores used throughout our manuscript. All relevant input files are housed in the input folder, and information about individual analyses (and run codes) are in the 'param' folder. The output files that result from these scripts are all contained in the 'output' folder. 

The text files created by our scripts do not contain relevant header information. See below for the associated column headers.

For bdis files:

"TarID", "TarCTY", "RefID", RefCTY", "TarLat", "TarLon", "RefLat", "RefLon", "Dissim", "Distance", "Azimuth"

Where "tar" refers to target, "ref" to reference, "CTY" to county, and "Dissim" to the calculated dissimilarity value of the closest analog.

for clim_diag files:

"TarID", "TarCTY", "RefID", "RefCTY", "TarLat",	"TarLon", "RefLat", "RefLon", "Dissim", "PPT_DJF_Diff", "PPT_MAM_Diff", "PPT_JJA_Diff", "PPT_SON_DIFF", "TMEAN_DJF_Diff", "TMEAN_MAM_Diff", "TMEAN_JJA_Diff", "TMEAN_SON_DIFF", "CORN_Diff", "WHEAT_Diff", "OAT_Diff", "BARLEY_DIFF", "HAY_Diff", "SOYBEAN_Diff", "HORSE_Diff", "CATTLE_Diff", "SWINE_DIFF", "SHEEP_Diff", "POP_Diff", "ASH_Diff", "BASSWOOD_Diff", "BEECH_Diff", "BIRCH_Diff", "CEDARJUNIPER_Diff", "ELM_Diff", "FIR_Diff", "HEMLOCK_Diff", "IRONWOOD_Diff", "MAPLE_Diff", " OAK_Diff", "PINE_Diff", "POPLAR_Diff", "SPRUCE_Diff", "TAMARACK_Diff", "PPT_DJF_std", "PPT_MAM_std", "PPT_JJA_std", "PPT_SON_std", "TMEAN_DJF_std", "TMEAN_MAM_std", "TMEAN_JJA_std", "TMEAN_SON_std", "CORN_std", "WHEAT_std", "OAT_std", "BARLEY_std", "HAY_std", "SOYBEAN_std", "HORSE_std", "CATTLE_std", "SWINE_std", "SHEEP_std","POP_std", "ASH_std", "BASSWOOD_std", "BEECH_std", "BIRCH_std", "CEDARJUNIPER_std", "ELM_std", "FIR_std", "HEMLOCK_std", "IRONWOOD_std", "MAPLE_std", " OAK_std", "PINE_std", "POPLAR_std", "SPRUCE_std", "TAMARACK_std", "PPT_DJF_Indiv", "PPT_MAM_Indiv", "PPT_JJA_Indiv", "PPT_SON_Indiv", "TMEAN_DJF_Indiv", "TMEAN_MAM_Indiv", "TMEAN_JJA_Indiv", "TMEAN_SON_Indiv", "CORN_Indiv", "WHEAT_Indiv", "OAT_Indiv", "BARLEY_Indiv", "HAY_Indiv", "SOYBEAN_Indiv", "HORSE_Indiv", "CATTLE_Indiv", "SWINE_Indiv", "SHEEP_Indiv","POP_Indiv", "ASH_Indiv", "BASSWOOD_Indiv", "BEECH_Indiv", "BIRCH_Indiv", "CEDARJUNIPER_Indiv", "ELM_Indiv", "FIR_Indiv", "HEMLOCK_Indiv", "IRONWOOD_Indiv", "MAPLE_Indiv", " OAK_Indiv", "PINE_Indiv", "POPLAR_Indiv", "SPRUCE_Indiv", "TAMARACK_Indiv"

Where we archive the difference between the target and reference for each variable, the standard deviation for each variable, and the individual contribution to novelty for each variable. The individual contribution is the value summed across all variables. 