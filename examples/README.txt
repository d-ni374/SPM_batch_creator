The examples consist of publicly accessible datasets to facilitate reproduction of models, outcomes, and possible errors:
(1) SPM12_Face uses data and analysis presented in the SPM12 manual (chapter 32);
  - contains first level analysis only
  - .mat files containing multiple conditions were written to test the respective option for the first level analysis (option "Multiple Conditions")
  - test of first level "factorial design"
  - use of parametric modulators
  - dataset is not BIDS-compliant
(2) ds000001 dataset available on https://openneuro.org/datasets/ds000001/versions/1.0.0;
  - BIDS-compliant dataset
  - this dataset was pre-processed with bidspm
  - subjects 02-09 were processed - some of them have missing data
  - only one-sample t-test on second levels
  - covariates considered in the second level model
(3) HCP_motor uses the data of HCP's motor task and is available via https://db.humanconnectome.org (registration required):
  - 3Tesla dataset for 100 unrelated subjects was analyzed
  - the preprocessed data from the HCP database were used
  - only one-sample t-test on second levels
  - dataset is not BIDS-compliant -> events files were created manually
(4) POLEX dataset available on https://openneuro.org/datasets/ds005375/versions/1.0.0
  (a) original dataset:
  - BIDS-compliant dataset
  - pre-processed with bidspm
  - all main second level options tested
  (b) modified dataset:
  - dataset is not BIDS-compliant
  - pre-processed with own pre-processing pipeline
  - only one-sample t-test on second levels
(5) ds000224 dataset available on https://openneuro.org/datasets/ds000224/versions/00001
  - BIDS-compliant dataset
  - pre-processed with bidspm
  - multiple sessions
  - selection of one task among several
  - use of parametric modulators
  - covariates considered in the second level model

Available files for all examples:
- model.json files (created using the user interface)
- the spm batch files that were obtained running SPM_batch_creator: FirstLevelBatch_.m and SecondLevelBatch_.m
- SPM.mat files which were obtained after job execution
- design matrix as .pdf (low quality) [can also be inspected using "Review" in SPM -> select SPM.mat]

NOTE: Most of the contrasts and models used for the examples have no practical sense and were only chosen to demonstrate the functionality
of the software and the underlying principles.