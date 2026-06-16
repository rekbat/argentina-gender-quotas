# replication materials

Token Woman or Superwoman? Effects of Parliamentary Gender Quotas in Argentine Provinces on Women's Labour Market Outcomes

MSc Economics, WU Vienna · Supervisor: Dr. Simon Heß

## Overview
This repository contains the R code to replicate all results in the thesis, which 
uses a staggered two-way fixed-effects difference-in-differences design across 24 
Argentine jurisdictions, with two quota regimes (30% and 50%).

## Software requirements
- R (version used: 4.6.0)
- Required packages:
  haven, dplyr, tidyr, ggplot2, readr, stringr, purrr, readxl, foreign,
  did, ivreg, lmtest, sandwich, fixest, bacondecomp

  Install with:
```r
  install.packages(c("haven","dplyr","tidyr","ggplot2","readr","stringr",
                     "purrr","readxl","foreign","did","ivreg","lmtest",
                     "sandwich","fixest","bacondecomp"))
```

## Data
The analysis uses three data sources. Place all data files in a `data/` folder in the repository root before running.

### Included in this repository / data archive
- `women_representation.xlsx` — hand-collected provincial women's representation 
  panel, 1987–2025 (sources documented in thesis Section 3.3)
- `LowQuota_adopt_impl.xlsx`, `HighQuota_adopt_implement.xlsx` — quota adoption 
  and implementation dates
- `Base de datos_WomensRepresentation.xls` — Granara (2014) cross-validation data

### EPH and Ministry of Labour microdata
The EPH household microdata (1996–2025) and Ministry of Labour aggregate data are 
provided in the data archive at 10.5281/zenodo.20712961.
Source: INDEC, www.indec.gob.ar

## How to run
1. Clone or download this repository.
2. Download the data archive and place all files in a `data/` folder in the repository root.
3. Open `MA_QuotaModel.R`, set the working directory to the repository root, and run the script top to bottom. Section comments mark the stages.

## Contact
reka.bator@s.wu.ac.at
