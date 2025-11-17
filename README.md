This archive contains the Matlab Code for the paper "Testing for Interactions in Multivariate Data" by Will Penny, Tom Sambrook and Louis Renoult
from the School of Psychology, University of East Anglia.

The empirical data for the Reward Learning experiment, which is too big for github, can be downloaded from here and should be placed in the data directory:
https://drive.google.com/file/d/1BoGYtLbkyINQr9-SXxaBYMFYy9JR8Q-j/view?usp=sharing

The empirical data for the Declarative Memory experiment, which is too big for github, can be downloaded from here and should be placed in the data directory:
https://drive.google.com/file/d/1DJU7aV9yrrcltVOAn4iS-01qG6KuVAi-/view?usp=sharing

Once you've downloaded the software to your machine, run set_mlc_path.m to place all the subdirectory files on your search path.

The main script is run_analyses.m. Change the parameters near the top of the script to make it run decoding (requires Matlab's stats toolbox), or Bayesian MANOVAs,
or to apply if to different data sets. The main algorithm is in /toolbox/mlm_nw.m

Will Penny, November 2025.
