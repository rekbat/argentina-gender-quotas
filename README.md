# replication materials

Token Woman or Superwoman? Effects of Parliamentary Gender Quotas in Argentine Provinces on Women's Labour Market Outcomes
(MSc Economics, WU Vienna)

## Overview
This repository contains the R code to replicate all results in the thesis, which uses a staggered two-way fixed-effects difference-in-differences design across 24 Argentine political jurisdictions, with two quota regimes (30% and 50%).

## Software requirements
- R (version used: 4.6.0)
- The script automatically installs any missing R packages on first run.
- The packages used are: haven, dplyr, tidyr, ggplot2, readr, stringr, purrr, readxl, foreign, did, ivreg, lmtest, sandwich, fixest, bacondecomp.
  
## Data
- The data archive is downloaded automatically by the script from Zenodo: [https://doi.org/10.5281/zenodo.20715643](https://doi.org/10.5281/zenodo.20715643).
- It contains: hand-collected provincial women's representation panel (1987–2025), quota adoption and implementation dates, Granara (2014) cross-validation data, Ministry of Labour aggregate data (1990–2003), and EPH household microdata (1996–2025)
- Source: INDEC, [www.indec.gob.ar](https://www.indec.gob.ar)

## How to run
- The script is self-contained. 
- Open `MA_QuotaModel.R` in RStudio and run it.
- On the first run, it automatically installs any missing R packages and downloads the data archive (~379 MB) from Zenodo, unzipping it into a `quota_data/` folder. 
   
## Contact
reka.bator@s.wu.ac.at
