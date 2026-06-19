#packages
required_packages <- c(
  "haven", "dplyr", "tidyr", "ggplot2", "readr", "stringr",
  "purrr", "readxl", "foreign", "did", "ivreg", "lmtest",
  "sandwich", "fixest", "bacondecomp"
)
options(repos = c(CRAN = "https://cloud.r-project.org"))

#binaries on Windows/macOS, source on Linux.
package_type <- if (.Platform$OS.type == "windows" ||
                    Sys.info()[["sysname"]] == "Darwin") {
  "binary"
} else {
  "source"
}

#dependency packages that may fail to get pulled correctly
# on older R/macOS binary repositories.
extra_packages <- c(
  "Rcpp", "RcppArmadillo", "bigmemory", "BMisc", "DRDID",
  "fastglm", "dreamerr", "stringmagic"
)
all_packages <- unique(c(extra_packages, required_packages))
install_if_missing_or_unloadable <- function(pkgs) {
  for (pkg in pkgs) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      message("Installing package: ", pkg)
      install.packages(
        pkg,
        dependencies = c("Depends", "Imports", "LinkingTo"),
        type = package_type
      )
    }
  }
}
#first pass
install_if_missing_or_unloadable(all_packages)
#second pass
install_if_missing_or_unloadable(all_packages)
#final verification
failed_packages <- all_packages[
  !vapply(all_packages, requireNamespace, logical(1), quietly = TRUE)
]
if (length(failed_packages) > 0) {
  stop(
    "The following packages are still not loadable: ",
    paste(failed_packages, collapse = ", "),
    "\n\nThis is not a script-path problem. It is a package installation problem.\n",
    "On macOS/Windows, try updating R if old CRAN binaries are incompatible.\n",
    "On Linux, system build tools/libraries may be required."
  )
}
suppressPackageStartupMessages(
  invisible(lapply(required_packages, library, character.only = TRUE))
)
#download and unzip data automatically
options(timeout = max(1800, getOption("timeout")))  #30 minutes for roughly 379MB
data_url <- "https://zenodo.org/records/20715643/files/quota_data.zip?download=1"
zip_file <- "quota_data.zip"
data_dir <- "quota_data"
required_data_files <- c(
  file.path(data_dir, "LowQuota_adopt_impl.xlsx"),
  file.path(data_dir, "HighQuota_adopt_implement.xlsx"),
  file.path(data_dir, "women_representation.xlsx"),
  file.path(data_dir, "Base de datos_WomensRepresentation.xls"),
  file.path(data_dir, "UnemploymentRate_UrbanAgglomeration_Women_1990-2003.xls"),
  file.path(data_dir, "EmploymentRate_UrbanAgglomeration_Women_1990-2003.xls"),
  file.path(data_dir, "female_LFPR_1990-2003.xls"),
  file.path(data_dir, "female_underemploymentrate_1990-2003.xls"),
  file.path(data_dir, "female_overemp_1990-2003.xls"),
  #EPH microdata
  file.path(data_dir, "EH_ind_1996_2.DBF"),
  file.path(data_dir, "EH_ind_1997.DBF"),
  file.path(data_dir, "EH_ind_1998_2.DBF"),
  file.path(data_dir, "EH_ind_1999.DBF"),
  file.path(data_dir, "EH_ind_2000.DBF"),
  file.path(data_dir, "EH_ind_2001.DBF"),
  file.path(data_dir, "EH_ind_2002.DBF"),
  file.path(data_dir, "EH_ind_2003.dta"),
  file.path(data_dir, "EH_ind_2004_2.dta"),
  file.path(data_dir, "EH_ind_2005_2.dta"),
  file.path(data_dir, "EH_ind_2006_2.dta"),
  file.path(data_dir, "EH_ind_2007_2.dta"),
  file.path(data_dir, "EH_ind_2008_2.dta"),
  file.path(data_dir, "EH_ind_2009_2.dta"),
  file.path(data_dir, "EH_ind_2010_2.dta"),
  file.path(data_dir, "EH_ind_2011_2.dta"),
  file.path(data_dir, "EH_ind_2012_2.dta"),
  file.path(data_dir, "EH_ind_2013_2.dta"),
  file.path(data_dir, "EH_ind_2014_2.dta"),
  file.path(data_dir, "EH_ind_2015_2.dta"),
  file.path(data_dir, "EH_ind_2016_2.xls"),
  file.path(data_dir, "EH_ind_2017_2.xls"),
  file.path(data_dir, "EH_ind_2018_2.xls"),
  file.path(data_dir, "EH_ind_2019_2.xls"),
  file.path(data_dir, "EH_ind_2020_1.xlsx"),
  file.path(data_dir, "EH_ind_2020_2.xlsx"),
  file.path(data_dir, "EH_ind_2020_3.xlsx"),
  file.path(data_dir, "EH_ind_2020_4.xlsx"),
  file.path(data_dir, "EH_ind_2021_2.xlsx"),
  file.path(data_dir, "EH_ind_2022_2.xlsx"),
  file.path(data_dir, "EH_ind_2023_1.xlsx"),
  file.path(data_dir, "EH_ind_2023_2.xlsx"),
  file.path(data_dir, "EH_ind_2024_1.xlsx"),
  file.path(data_dir, "EH_ind_2024_2.xlsx"),
  file.path(data_dir, "EH_ind_2024_3.xlsx"),
  file.path(data_dir, "EH_ind_2024_4.xlsx"),
  file.path(data_dir, "EH_ind_2025_2.xlsx")
)
if (!all(file.exists(required_data_files))) {
  message("Data folder is missing or incomplete.")
  if (!file.exists(zip_file)) {
    message("Downloading quota_data.zip from Zenodo (379 MB, this may take a while).")
    download.file(url = data_url, destfile = zip_file, mode = "wb", quiet = FALSE)
  } else {
    message("Using existing quota_data.zip.")
  }
  message("Checking ZIP integrity.")
  zip_check <- tryCatch(unzip(zip_file, list = TRUE), error = function(e) NULL)
  if (is.null(zip_check)) {
    stop("quota_data.zip is corrupt or incomplete. Delete it and run the script again.")
  }
  message("Unzipping data.")
  unzip(zip_file, overwrite = TRUE)
  if (!all(file.exists(required_data_files))) {
    message("Files found under quota_data:")
    print(list.files(data_dir, recursive = TRUE))
    stop(
      "Data folder still incomplete after unzip. Missing:\n",
      paste(required_data_files[!file.exists(required_data_files)], collapse = "\n")
    )
  }
}
message("Data folder verified.")

#data 
#quota and representation data
path_lowquota   <- read_excel("quota_data/LowQuota_adopt_impl.xlsx")
path_highquota  <- read_excel("quota_data/HighQuota_adopt_implement.xlsx")
path_femrep     <- read_excel("quota_data/women_representation.xlsx")
path_granararaw <- read_excel("quota_data/Base de datos_WomensRepresentation.xls")
                              
#ministry of labor aggregate data for low quota (1990–2003) 
path_unem_9003     <- read_excel("quota_data/UnemploymentRate_UrbanAgglomeration_Women_1990-2003.xls", skip = 2)
path_emp_9003      <- read_excel("quota_data/EmploymentRate_UrbanAgglomeration_Women_1990-2003.xls",   skip = 2)
path_LFP_9003      <- read_excel("quota_data/female_LFPR_1990-2003.xls",   skip = 2)
path_underemp_9003 <- read_excel("quota_data/female_underemploymentrate_1990-2003.xls",   skip = 2)
path_overemp_9003  <- read_excel("quota_data/female_overemp_1990-2003.xls",   skip = 2)
                        
#EPH individual-level microdata for high quota (1996–2025)
#2nd quarter for all years
#alternative quarters for 2020 and 2024 for data quality issues
#alternative quarter for 2023 for sensitivity check
path_EH_1996 <- read.dbf("quota_data/EH_ind_1996_2.DBF", as.is = TRUE)
path_EH_1997 <- read.dbf("quota_data/EH_ind_1997.DBF",     as.is = TRUE)
path_EH_1998 <- read.dbf("quota_data/EH_ind_1998_2.DBF",   as.is = TRUE)
path_EH_1999 <- read.dbf("quota_data/EH_ind_1999.DBF",     as.is = TRUE)
path_EH_2000 <- read.dbf("quota_data/EH_ind_2000.DBF",     as.is = TRUE)
path_EH_2001 <- read.dbf("quota_data/EH_ind_2001.DBF",     as.is = TRUE)
path_EH_2002 <- read.dbf("quota_data/EH_ind_2002.DBF",     as.is = TRUE)
path_EH_2003 <- read_dta("quota_data/EH_ind_2003.dta")
path_EH_2004 <- read_dta("quota_data/EH_ind_2004_2.dta")
path_EH_2005 <- read_dta("quota_data/EH_ind_2005_2.dta")
path_EH_2006 <- read_dta("quota_data/EH_ind_2006_2.dta")
path_EH_2007 <- read_dta("quota_data/EH_ind_2007_2.dta")
path_EH_2008 <- read_dta("quota_data/EH_ind_2008_2.dta")
path_EH_2009 <- read_dta("quota_data/EH_ind_2009_2.dta")
path_EH_2010 <- read_dta("quota_data/EH_ind_2010_2.dta")
path_EH_2011 <- read_dta("quota_data/EH_ind_2011_2.dta")
path_EH_2012 <- read_dta("quota_data/EH_ind_2012_2.dta")
path_EH_2013 <- read_dta("quota_data/EH_ind_2013_2.dta")
path_EH_2014 <- read_dta("quota_data/EH_ind_2014_2.dta")
path_EH_2015 <- read_dta("quota_data/EH_ind_2015_2.dta")
path_EH_2016 <- read_excel("quota_data/EH_ind_2016_2.xls")
path_EH_2017 <- read_excel("quota_data/EH_ind_2017_2.xls")
path_EH_2018 <- read_excel("quota_data/EH_ind_2018_2.xls")
path_EH_2019 <- read_excel("quota_data/EH_ind_2019_2.xls")
path_EH_2020_1 <- read_excel("quota_data/EH_ind_2020_1.xlsx")
path_EH_2020 <- read_excel("quota_data/EH_ind_2020_2.xlsx")
path_EH_2020_3 <- read_excel("quota_data/EH_ind_2020_3.xlsx")
path_EH_2020_4 <- read_excel("quota_data/EH_ind_2020_4.xlsx")
path_EH_2021 <- read_excel("quota_data/EH_ind_2021_2.xlsx")
path_EH_2022 <- read_excel("quota_data/EH_ind_2022_2.xlsx")
path_EH_2023 <- read_excel("quota_data/EH_ind_2023_2.xlsx")
path_EH_2023_1 <- read_excel("quota_data/EH_ind_2023_1.xlsx")
path_EH_2024 <- read_excel("quota_data/EH_ind_2024_2.xlsx")
path_EH_2024_3 <- read_excel("quota_data/EH_ind_2024_3.xlsx")
path_EH_2024_1 <- read_excel("quota_data/EH_ind_2024_1.xlsx")
path_EH_2024_4 <- read_excel("quota_data/EH_ind_2024_4.xlsx")
path_EH_2025 <- read_excel("quota_data/EH_ind_2025_2.xlsx")
                        
#eph file lists for all cleaning functions in high quota (early, 1996-2002)
eph_files_early <- list(
  list(df = path_EH_1996, year = 1996),
  list(df = path_EH_1997, year = 1997),
  list(df = path_EH_1998, year = 1998),
  list(df = path_EH_1999, year = 1999),
  list(df = path_EH_2000, year = 2000),
  list(df = path_EH_2001, year = 2001),
  list(df = path_EH_2002, year = 2002)
)

#eph file lists for all cleaning functions in high quota (late, 2003-2025)
eph_files <- list(
  list(df = path_EH_2003, year = 2003, quarter = 2),
  list(df = path_EH_2004, year = 2004, quarter = 2),
  list(df = path_EH_2005, year = 2005, quarter = 2),
  list(df = path_EH_2006, year = 2006, quarter = 2),
  list(df = path_EH_2007, year = 2007, quarter = 2),
  list(df = path_EH_2008, year = 2008, quarter = 2),
  list(df = path_EH_2009, year = 2009, quarter = 2),
  list(df = path_EH_2010, year = 2010, quarter = 2),
  list(df = path_EH_2011, year = 2011, quarter = 2),
  list(df = path_EH_2012, year = 2012, quarter = 2),
  list(df = path_EH_2013, year = 2013, quarter = 2),
  list(df = path_EH_2014, year = 2014, quarter = 2),
  list(df = path_EH_2015, year = 2015, quarter = 2),
  list(df = path_EH_2016, year = 2016, quarter = 2),
  list(df = path_EH_2017, year = 2017, quarter = 2),
  list(df = path_EH_2018, year = 2018, quarter = 2),
  list(df = path_EH_2019, year = 2019, quarter = 2),
  list(df = path_EH_2020_1, year = 2020, quarter = 1),
  list(df = path_EH_2021, year = 2021, quarter = 2),
  list(df = path_EH_2022, year = 2022, quarter = 2),
  list(df = path_EH_2023, year = 2023, quarter = 2),
  list(df = path_EH_2024_1, year = 2024, quarter = 1),
  list(df = path_EH_2025, year = 2025, quarter = 2)
)

#urban agglomeration to province mapping 
#uses agglomeration and province codes provided by INDEC
aglo_to_province <- tibble(
  aglomerado = c(2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 13, 14, 15, 17, 18, 19, 20, 22, 23, 25, 26, 27, 29, 30, 31, 32, 33, 34, 36, 38, 91, 93),
  provincia_cod = c(6, 6, 82, 82, 30, 54, 22, 26, 50, 18, 14, 30, 34, 58, 86, 38, 78, 10, 66, 46, 74, 70, 90, 42, 94, 2, 6, 6, 14, 82, 26, 62)
)

province_mapping <- tibble(
  provincia_cod = c(2, 6, 10, 14, 18, 22, 26, 30, 34, 38, 42, 46, 50, 54, 58, 62, 66, 70, 74, 78, 82, 86, 90, 94),
  province = c("CABA", "Buenos Aires", "Catamarca", "Cordoba", "Corrientes", "Chaco", "Chubut", "Entre Rios", "Formosa", "Jujuy", "La Pampa", "La Rioja", "Mendoza", "Misiones", "Neuquen", "Rio Negro", "Salta", "San Juan", "San Luis", "Santa Cruz", "Santa Fe", "Santiago del Estero", "Tucuman", "Tierra del Fuego")
)

#clean women's representation data 
femrep_long <- path_femrep %>%
  mutate(across(-Province, as.character)) %>%
  pivot_longer(
    cols      = -Province,
    names_to  = "year",
    values_to = "womens_rep"
  ) %>%
  mutate(
    year       = as.integer(year),
    womens_rep = ifelse(womens_rep == "na", NA_character_, womens_rep),
    womens_rep = as.numeric(womens_rep)
  )

#quota implementation and quota adoption treatment variable for low quota
low_quota <- path_lowquota %>%
  select(province, year, 
         low_quota_adopt     = quota_adopt,
         low_quota_implement = quota_implement)

#quota implementation and quota adoption treatment variable for high quota 
high_quota <- path_highquota %>%
  select(province, year, 
         high_quota_adopt     = quota_adopt,
         high_quota_implement = quota_implement)

#merge low and high quota treatment and women's representation data into one province-year panel 
treatment_panel <- low_quota %>%
  left_join(high_quota, by = c("province", "year")) %>%
  left_join(femrep_long, by = c("province" = "Province", "year")) %>%
  mutate(year = as.integer(year))

#data analysis for women's representational data (outcome variable)
#show all provinces with missing years in 1987-2025
treatment_panel %>%
  filter(
    year >= 1987, year <= 2025
  ) %>%
  group_by(province) %>%
  summarise(
    n_total   = n(),
    n_missing = sum(is.na(womens_rep)),
    missing_years = paste(
      year[is.na(womens_rep)], collapse = ", "
    )
  ) %>%
  filter(n_missing > 0) %>%
  arrange(desc(n_missing))
#I am missing 18 values in total from 8 different provinces, all of them are missing the earliest years of the data set (1987 and 1988)
#4 of these missing values come from the province Tierra del Fuego which only became a province in 1990, so the first available data are from 1991

#analysis of missing values
treatment_panel %>%
  filter(year >= 1987, is.na(womens_rep)) %>%
  left_join(
    treatment_panel %>%
      filter(low_quota_implement == 1 | high_quota_implement == 1) %>%
      group_by(province) %>%
      summarise(first_treat_year = min(year), .groups = "drop"),
    by = "province"
  ) %>%
  mutate(pre_treatment = is.na(first_treat_year) | year < first_treat_year) %>%
  select(province, year, first_treat_year, pre_treatment) %>%
  arrange(province, year) %>%
  print(n = Inf)
#all missing values are from before the first year of treatment 

#analysis of low quota treatment data
#first year of low quota adoption by province
treatment_panel %>%
  group_by(province) %>%
  filter(low_quota_adopt == 1) %>%
  summarise(first_low_adopt = min(year)) %>%
  arrange(first_low_adopt) %>%
  print(n = 24)
#first year of low quota implementation by province
treatment_panel %>%
  group_by(province) %>%
  filter(low_quota_implement == 1) %>%
  summarise(first_low_impl = min(year)) %>%
  arrange(first_low_impl) %>%
  print(n = 24)
#Entre Rios and Jujuy implement the low quota in 2011 only 
#Santiago del Estero never implemented a low quota

#analysis of high quota treatment data
#first year of high quota adoption by province
treatment_panel %>%
  group_by(province) %>%
  filter(high_quota_adopt == 1) %>%
  summarise(first_high_adopt = min(year)) %>%
  arrange(first_high_adopt) %>%
  print(n = 24)
#first year of high quota implementation by province
treatment_panel %>%
  group_by(province) %>%
  filter(high_quota_implement == 1) %>%
  summarise(first_high_impl = min(year)) %>%
  arrange(first_high_impl) %>%
  print(n = 24)
#Santiago del Estero is the first province with a high quota implemented (in 2002)
#most provinces implement between 2017 and 2023
#Tierra del Fuego and Tucuman never implemented a high quota

#descriptive analysis of women's representation data (low quota)
#restrict to 1987-2001 (all provinces except San Luis, Entre Rios and Jujuy have implemented a low quota by that time; and in 2002 the first province, Santiago del Estero, already introduced a high gender quota which could bias results)
treatment_panel %>%
  filter(
    !is.na(womens_rep),
    year >= 1987,
    year <= 2001
  ) %>%
  group_by(province) %>%
  summarise(
    mean_rep = mean(womens_rep, na.rm = TRUE),
    sd_rep   = sd(womens_rep,   na.rm = TRUE),
    min_rep  = min(womens_rep,  na.rm = TRUE),
    max_rep  = max(womens_rep,  na.rm = TRUE),
    ever_low = max(low_quota_implement)
  ) %>%
  arrange(ever_low, mean_rep) %>%
  print(n = 24)
#within this time period, 20 provinces implemented a low quota 
#10 provinces reached the 30% threshold
#strong increase in women's representation in the provincial parliaments of all provinces 

#descriptive analysis of women's representation data (high quota)
treatment_panel %>%
  filter(
    !is.na(womens_rep),
    year >= 1987,
    year <= 2025
  ) %>%
  group_by(province) %>%
  summarise(
    mean_rep = mean(womens_rep, na.rm = TRUE),
    sd_rep   = sd(womens_rep,   na.rm = TRUE),
    min_rep  = min(womens_rep,  na.rm = TRUE),
    max_rep  = max(womens_rep,  na.rm = TRUE),
    ever_high = max(high_quota_implement)
  ) %>%
  arrange(ever_high, mean_rep) %>%
  print(n = 24)
#within this time period, 22 provinces implemented a high quota 
#8 provinces reached the 50% threshold
#strong increase in women's representation in the provincial parliaments of all provinces 

#low quota pre-treatment data 
low_quota_pretreatment <- treatment_panel %>%
  group_by(province) %>%
  summarise(
    treatment_year = ifelse(any(low_quota_implement == 1),
                            min(year[low_quota_implement == 1]),
                            NA_real_),
    pretreatment_obs = sum(year < treatment_year & !is.na(womens_rep)),
    .groups = "drop"
  )
#provinces with limited low quota pre-treatment data (< 5 years)
low_quota_pretreatment %>%
  filter(pretreatment_obs < 5, pretreatment_obs > 0) %>%
  select(province, treatment_year, pretreatment_obs) %>%
  print()
#Corrientes and La Rioja have only 4 low quota pre-treatment observations

#high quota pre-treatment data
high_quota_pretreatment <- treatment_panel %>%
  group_by(province) %>%
  summarise(
    treatment_year = ifelse(any(high_quota_implement == 1),
                            min(year[high_quota_implement == 1]),
                            NA_real_),
    pretreatment_obs = sum(year < treatment_year & !is.na(womens_rep)),
    .groups = "drop"
  )
#Provinces with limited high quota pre-treatment data (< 5 years)
high_quota_pretreatment %>%
  filter(pretreatment_obs < 5, pretreatment_obs > 0) %>%
  select(province, treatment_year, pretreatment_obs) %>%
  print(n=Inf)
#for the high quota all provinces have at least 5 pre-treatment observations

#event-time plots for low and high quota implementation (event-time window: -4 to +4)
#CABA excluded
#low quota: event-time quota implementation data
event_time_data_low <- treatment_panel %>%
  filter(province != "CABA", !is.na(womens_rep)) %>%
  group_by(province) %>%
  mutate(
    treat_year_low = ifelse(any(low_quota_implement == 1),
                            min(year[low_quota_implement == 1]),
                            NA_integer_),
    event_time_low = year - treat_year_low
  ) %>%
  ungroup() %>%
  filter(!is.na(treat_year_low),
         event_time_low >= -4, event_time_low <= 4)
event_summary_low <- event_time_data_low %>%
  group_by(event_time_low) %>%
  summarise(
    mean_rep = mean(womens_rep, na.rm = TRUE),
    se_rep   = sd(womens_rep, na.rm = TRUE) / sqrt(n()),
    .groups  = "drop"
  )
#high quota: event-time quota implementation data
event_time_data_high <- treatment_panel %>%
  filter(province != "CABA", !is.na(womens_rep)) %>%
  group_by(province) %>%
  mutate(
    treat_year_high = ifelse(any(high_quota_implement == 1),
                             min(year[high_quota_implement == 1]),
                             NA_integer_),
    event_time_high = year - treat_year_high
  ) %>%
  ungroup() %>%
  filter(!is.na(treat_year_high),
         event_time_high >= -4, event_time_high <= 4)
event_summary_high <- event_time_data_high %>%
  group_by(event_time_high) %>%
  summarise(
    mean_rep = mean(womens_rep, na.rm = TRUE),
    se_rep   = sd(womens_rep, na.rm = TRUE) / sqrt(n()),
    .groups  = "drop"
  )
#joint y-axis range across both plots (includes 95% CI bands)
y_range <- range(c(
  event_summary_low$mean_rep  - 1.96 * event_summary_low$se_rep,
  event_summary_low$mean_rep  + 1.96 * event_summary_low$se_rep,
  event_summary_high$mean_rep - 1.96 * event_summary_high$se_rep,
  event_summary_high$mean_rep + 1.96 * event_summary_high$se_rep
), na.rm = TRUE)
#low quota implementation event-time plot
plot_event_low <- ggplot(event_summary_low, aes(x = event_time_low, y = mean_rep)) +
  geom_ribbon(aes(ymin = mean_rep - 1.96 * se_rep,
                  ymax = mean_rep + 1.96 * se_rep),
              fill = "#2166ac", alpha = 0.2) +
  geom_line(linewidth = 0.9, colour = "#2166ac") +
  geom_point(size = 2, colour = "#2166ac") +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey40") +
  annotate("text", x = 0.2, y = y_range[1] + 2, label = "Low Quota\nimplementation",
           hjust = 0, size = 3, colour = "grey40") +
  scale_x_continuous(breaks = seq(-4, 4, by = 2)) +
  coord_cartesian(ylim = y_range) +
  labs(
    title    = "Low Quota: Women's Representation in Provincial Chambers of Deputies",
    subtitle = "Event-time average across treated provinces",
    x        = "Years relative to quota implementation",
    y        = "Average Women's Share of Seats (%)",
    caption  = "Note: Shaded area shows 95% confidence interval. Treated provinces only. CABA excluded."
  ) +
  theme_minimal(base_size = 11) +
  theme(
    legend.position  = "bottom",
    panel.grid.minor = element_blank(),
    plot.title       = element_text(face = "bold", size = 12),
    plot.subtitle    = element_text(size = 10, colour = "grey40"),
    plot.caption     = element_text(size = 8, colour = "grey50")
  )
ggsave("plot_event_low.pdf", plot_event_low, width = 8, height = 5)

#high quota implementation event-time plot
plot_event_high <- ggplot(event_summary_high, aes(x = event_time_high, y = mean_rep)) +
  geom_ribbon(aes(ymin = mean_rep - 1.96 * se_rep,
                  ymax = mean_rep + 1.96 * se_rep),
              fill = "#2166ac", alpha = 0.2) +
  geom_line(linewidth = 0.9, colour = "#2166ac") +
  geom_point(size = 2, colour = "#2166ac") +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey40") +
  annotate("text", x = 0.2, y = y_range[1] + 2, label = "High Quota\nimplementation",
           hjust = 0, size = 3, colour = "grey40") +
  scale_x_continuous(breaks = seq(-4, 4, by = 2)) +
  coord_cartesian(ylim = y_range) +
  labs(
    title    = "High Quota: Women's Representation in Provincial Chambers of Deputies",
    subtitle = "Event-time average across treated provinces",
    x        = "Years relative to quota implementation",
    y        = "Average Women's Share of Seats (%)",
    caption  = "Note: Shaded area shows 95% confidence interval. Treated provinces only. CABA excluded."
  ) +
  theme_minimal(base_size = 11) +
  theme(
    legend.position  = "bottom",
    panel.grid.minor = element_blank(),
    plot.title       = element_text(face = "bold", size = 12),
    plot.subtitle    = element_text(size = 10, colour = "grey40"),
    plot.caption     = element_text(size = 8, colour = "grey50")
  )
ggsave("plot_event_high.pdf", plot_event_high, width = 8, height = 5)

#event-time plots for low and high quota adoption (event-time window: -4 to +4)
#CABA excluded
#low quota: event-time quota adoption data
event_time_data_low_adopt <- treatment_panel %>%
  filter(province != "CABA", !is.na(womens_rep)) %>%
  group_by(province) %>%
  mutate(
    treat_year_low_adopt = ifelse(any(low_quota_adopt == 1),
                                  min(year[low_quota_adopt == 1]),
                                  NA_integer_),
    event_time_low_adopt = year - treat_year_low_adopt
  ) %>%
  ungroup() %>%
  filter(!is.na(treat_year_low_adopt),
         event_time_low_adopt >= -4, event_time_low_adopt <= 4)

event_summary_low_adopt <- event_time_data_low_adopt %>%
  group_by(event_time_low_adopt) %>%
  summarise(
    mean_rep = mean(womens_rep, na.rm = TRUE),
    se_rep   = sd(womens_rep, na.rm = TRUE) / sqrt(n()),
    .groups  = "drop"
  )
#high quota: event-time quota adoption data
event_time_data_high_adopt <- treatment_panel %>%
  filter(province != "CABA", !is.na(womens_rep)) %>%
  group_by(province) %>%
  mutate(
    treat_year_high_adopt = ifelse(any(high_quota_adopt == 1),
                                   min(year[high_quota_adopt == 1]),
                                   NA_integer_),
    event_time_high_adopt = year - treat_year_high_adopt
  ) %>%
  ungroup() %>%
  filter(!is.na(treat_year_high_adopt),
         event_time_high_adopt >= -4, event_time_high_adopt <= 4)

event_summary_high_adopt <- event_time_data_high_adopt %>%
  group_by(event_time_high_adopt) %>%
  summarise(
    mean_rep = mean(womens_rep, na.rm = TRUE),
    se_rep   = sd(womens_rep, na.rm = TRUE) / sqrt(n()),
    .groups  = "drop"
  )
#joint y-axis range across both plots (includes 95% CI bands)
y_lim_adopt <- c(10, 45)
adopt_check <- range(c(
  event_summary_low_adopt$mean_rep  - 1.96 * event_summary_low_adopt$se_rep,
  event_summary_low_adopt$mean_rep  + 1.96 * event_summary_low_adopt$se_rep,
  event_summary_high_adopt$mean_rep - 1.96 * event_summary_high_adopt$se_rep,
  event_summary_high_adopt$mean_rep + 1.96 * event_summary_high_adopt$se_rep
), na.rm = TRUE)
if (adopt_check[1] < y_lim_adopt[1] || adopt_check[2] > y_lim_adopt[2]) {
  warning("Data exceeds y_lim_adopt; actual range is ",
          round(adopt_check[1], 1), " to ", round(adopt_check[2], 1))
}

#low quota adoption event-time plot
plot_event_low_adopt <- ggplot(event_summary_low_adopt,
                               aes(x = event_time_low_adopt, y = mean_rep)) +
  geom_ribbon(aes(ymin = mean_rep - 1.96*se_rep,
                  ymax = mean_rep + 1.96*se_rep),
              fill = "#2166ac", alpha = 0.2) +
  geom_line(linewidth = 0.9, colour = "#2166ac") +
  geom_point(size = 2, colour = "#2166ac") +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey40") +
  annotate("text", x = 0.2, y = y_lim_adopt[1] + 2, label = "Low Quota\nadoption",
           hjust = 0, size = 3, colour = "grey40") +
  scale_x_continuous(breaks = seq(-4, 4, by = 2)) +
  coord_cartesian(ylim = y_lim_adopt) +
  labs(
    title    = "Low Quota: Women's Representation in Provincial Chambers of Deputies",
    subtitle = "Event-time average across treated provinces (centred on adoption)",
    x        = "Years relative to quota adoption",
    y        = "Average Women's Share of Seats (%)",
    caption  = "Note: Shaded area shows 95% confidence interval. Treated provinces only. CABA excluded."
  ) +
  theme_minimal(base_size = 11) +
  theme(
    legend.position  = "bottom",
    panel.grid.minor = element_blank(),
    plot.title       = element_text(face = "bold", size = 12),
    plot.subtitle    = element_text(size = 10, colour = "grey40"),
    plot.caption     = element_text(size = 8, colour = "grey50")
  )
ggsave("plot_event_low_adopt.pdf", plot_event_low_adopt, width = 8, height = 5)

#high quota adoption event-time plot
plot_event_high_adopt <- ggplot(event_summary_high_adopt,
                                aes(x = event_time_high_adopt, y = mean_rep)) +
  geom_ribbon(aes(ymin = mean_rep - 1.96*se_rep,
                  ymax = mean_rep + 1.96*se_rep),
              fill = "#2166ac", alpha = 0.2) +
  geom_line(linewidth = 0.9, colour = "#2166ac") +
  geom_point(size = 2, colour = "#2166ac") +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey40") +
  annotate("text", x = 0.2, y = y_lim_adopt[1] + 2, label = "High Quota\nadoption",
           hjust = 0, size = 3, colour = "grey40") +
  scale_x_continuous(breaks = seq(-4, 4, by = 2)) +
  coord_cartesian(ylim = y_lim_adopt) +
  labs(
    title    = "High Quota: Women's Representation in Provincial Chambers of Deputies",
    subtitle = "Event-time average across treated provinces (centred on adoption)",
    x        = "Years relative to quota adoption",
    y        = "Average Women's Share of Seats (%)",
    caption  = "Note: Shaded area shows 95% confidence interval. Treated provinces only. CABA excluded."
  ) +
  theme_minimal(base_size = 11) +
  theme(
    legend.position  = "bottom",
    panel.grid.minor = element_blank(),
    plot.title       = element_text(face = "bold", size = 12),
    plot.subtitle    = element_text(size = 10, colour = "grey40"),
    plot.caption     = element_text(size = 8, colour = "grey50")
  )
ggsave("plot_event_high_adopt.pdf", plot_event_high_adopt, width = 8, height = 5)

#Santiago del Estero data quality check for women's representation 
santiago_data <- treatment_panel %>%
  filter(province == "Santiago del Estero",
         year >= 1987, year <= 2025) %>%
  select(province, year, womens_rep, low_quota_implement, high_quota_implement) %>%
  arrange(year)
print(santiago_data, n = Inf)
#never implements a low quota, implements high quota in 2002
#there is a sudden jump in the year 1998 from 8% to 24% of women in parliament

#first-step: effect of low quota implementation on women's representation (1987-2025)
#baseline specification (CABA excluded)
fs_low_baseline_data <- treatment_panel %>%
  filter(
    !province %in% c("CABA"),  
    !is.na(womens_rep),
    !is.na(low_quota_implement)
  )
fs_low_baseline <- feols(
  womens_rep ~ low_quota_implement | province + year,
  data    = fs_low_baseline_data,
  cluster = ~province
)
summary(fs_low_baseline)
print(confint(fs_low_baseline))
#with the implementation of a low quota, women's representation increases by 2.28 pp, not statistically significant

#Santiago del Estero and CABA excluded
fs_low_excl_sgo_data <- treatment_panel %>%
  filter(
    !province %in% c("Santiago del Estero", "CABA"),
    !is.na(womens_rep),
    !is.na(low_quota_implement)
  )
fs_low_excl_sgo <- feols(
  womens_rep ~ low_quota_implement | province + year,
  data    = fs_low_excl_sgo_data,
  cluster = ~province
)
summary(fs_low_excl_sgo)
print(confint(fs_low_excl_sgo))
#women's representation increases by 5.19 pp, this is statistically significant at the 5% level

#Corrientes and La Rioja excluded (fewer than 5 pre-treatment observations)
fs_low_baseline_data <- treatment_panel %>%
  filter(
    !province %in% c("CABA", "Corrientes", "La Rioja"),  
    !is.na(womens_rep),
    !is.na(low_quota_implement)
  )
fs_low_baseline_Cor_Rio <- feols(
  womens_rep ~ low_quota_implement | province + year,
  data    = fs_low_baseline_data,
  cluster = ~province
)
summary(fs_low_baseline_Cor_Rio)
print(confint(fs_low_baseline_Cor_Rio))
#with the implementation of a low quota, women's representation increases by 2.75 pp, not statistically significant

#Santiago del Estero, Corrientes and La Rioja excluded 
fs_low_baseline_data <- treatment_panel %>%
  filter(
    !province %in% c("CABA", "Corrientes", "La Rioja", "Santiago del Estero"),  
    !is.na(womens_rep),
    !is.na(low_quota_implement)
  )
fs_low_baseline_Cor_Rio_Sgo <- feols(
  womens_rep ~ low_quota_implement | province + year,
  data    = fs_low_baseline_data,
  cluster = ~province
)
summary(fs_low_baseline_Cor_Rio_Sgo)
print(confint(fs_low_baseline_Cor_Rio_Sgo))
#with the implementation of a low quota, women's representation increases by 6.10 pp, statistically significant at the 5% level

#all provinces included
fs_low_all_data <- treatment_panel %>%
  filter(
    !is.na(womens_rep),
    !is.na(low_quota_implement)
  )
fs_low_all <- feols(
  womens_rep ~ low_quota_implement | province + year,
  data    = fs_low_all_data,
  cluster = ~province
)
summary(fs_low_all)
print(confint(fs_low_all))
#with the implementation of a low quota, women's representation increases by 2.48 pp, not statistically significant 

#first step: effect of high quota implementation on women's representation (1987-2025)
#baseline (CABA excluded)
fs_high_baseline_data <- treatment_panel %>%
  filter(
    !province %in% c("CABA"),  
    !is.na(womens_rep),
    !is.na(high_quota_implement)
  )
fs_high_baseline <- feols(
  womens_rep ~ high_quota_implement | province + year,
  data    = fs_high_baseline_data,
  cluster = ~province
)
summary(fs_high_baseline)
print(confint(fs_high_baseline))
#with the implementation of a high quota, women's representation increases by 10.60 pp, statistically significant at the 0.1% level

#Santiago del Estero and CABA excluded
fs_high_excl_sgo_data <- treatment_panel %>%
  filter(
    !province %in% c("Santiago del Estero", "CABA"),
    !is.na(womens_rep),
    !is.na(high_quota_implement)
  )
fs_high_excl_sgo <- feols(
  womens_rep ~ high_quota_implement | province + year,
  data    = fs_high_excl_sgo_data,
  cluster = ~province
)
summary(fs_high_excl_sgo)
print(confint(fs_high_excl_sgo))
#women's representation increases by 8.88 pp, statistically significant at the 0.1% level

#all provinces included
fs_high_all_data <- treatment_panel %>%
  filter(
    !is.na(womens_rep),
    !is.na(high_quota_implement)
  )
fs_high_all <- feols(
  womens_rep ~ high_quota_implement | province + year,
  data    = fs_high_all_data,
  cluster = ~province
)
summary(fs_high_all)
print(confint(fs_high_all))
#with the implementation of a high quota, women's representation increases by 10.46 pp, statistically significant at the 0.1% level

#second-step: effect of low quota implementation on women's labour market outcome variables (1990-2003)
#outcome variables: female unemployment rate, employment rate, labour force participation rate, underemployment rate, overemployment rate
#data source: Ministry of Labor aggregate data
clean_ministry <- function(df, value_name, use_octubre_fallback = FALSE) {
  aglo_col <- names(df)[2]
  if (!use_octubre_fallback) {
    #use may data only 
    df %>%
      rename(
        aglomerado_name = `Aglomerado urbano`,
        aglomerado      = !!sym(aglo_col)
      ) %>%
      filter(!is.na(aglomerado)) %>%
      select(aglomerado_name, aglomerado, matches("^[0-9]{4}$")) %>%
      pivot_longer(
        cols      = -c(aglomerado_name, aglomerado),
        names_to  = "year",
        values_to = value_name
      ) %>%
      mutate(
        year          = as.integer(year),
        aglomerado    = as.integer(aglomerado),
        !!value_name := suppressWarnings(as.numeric(!!sym(value_name)))
      ) %>%
      filter(!is.na(!!sym(value_name)), !is.na(aglomerado))
  } else {
    all_cols <- names(df)[3:length(names(df))]
    col_to_year_wave <- tibble(
      col_name = all_cols,
      position = 1:length(all_cols)
    ) %>%
      mutate(
        is_mayo = str_detect(col_name, "^[0-9]{4}$"),
        year = NA_integer_
      )
    current_year <- NA_integer_
    for (i in 1:nrow(col_to_year_wave)) {
      if (col_to_year_wave$is_mayo[i]) {
        current_year <- as.integer(col_to_year_wave$col_name[i])
        col_to_year_wave$year[i] <- current_year
      } else {
        col_to_year_wave$year[i] <- current_year
      }
    }
    col_to_year_wave <- col_to_year_wave %>%
      mutate(wave = ifelse(is_mayo, "Mayo", "Octubre"))
    df_long <- df %>%
      rename(
        aglomerado_name = `Aglomerado urbano`,
        aglomerado      = !!sym(aglo_col)
      ) %>%
      filter(!is.na(aglomerado)) %>%
      select(aglomerado_name, aglomerado, all_of(all_cols)) %>%
      pivot_longer(
        cols      = all_of(all_cols),
        names_to  = "col_name",
        values_to = value_name
      ) %>%
      mutate(
        aglomerado = as.integer(aglomerado),
        !!value_name := suppressWarnings(as.numeric(!!sym(value_name)))
      ) %>%
      filter(!is.na(aglomerado)) %>%
      left_join(col_to_year_wave %>% select(col_name, year, wave), by = "col_name") %>%
      filter(!is.na(year))
    #use october data only if may data is NA
    df_long %>%
      group_by(aglomerado, aglomerado_name, year) %>%
      arrange(wave != "Mayo") %>%  
      filter(!is.na(!!sym(value_name))) %>%  
      slice_head(n = 1) %>%  
      ungroup() %>%
      select(aglomerado_name, aglomerado, year, !!value_name)
  }
}
#outcome variables
ministry_unemp    <- clean_ministry(path_unem_9003, "unemp_rate")
ministry_emp      <- clean_ministry(path_emp_9003, "emp_rate")
ministry_lfp      <- clean_ministry(path_LFP_9003, "lfp_rate")
ministry_underemp <- clean_ministry(path_underemp_9003, "underemp_rate", use_octubre_fallback = TRUE)
ministry_overemp  <- clean_ministry(path_overemp_9003, "overemp_rate", use_octubre_fallback = TRUE)

#check coverage of all agglomerations
ministry_unemp %>%
  group_by(aglomerado, aglomerado_name) %>%
  summarise(
    min_year = min(year),
    max_year = max(year),
    n_years  = n(),
    .groups  = "drop"
  ) %>%
  arrange(min_year, n_years) %>%
  print(n = 35)
#27 agglomerations have at least 13 years of data
#3 agglomerations have only 8 years of data
#3 agglomerations have only 1 year of data 

#exclusion of Rio Negro in the second step of the low quota specification
aglo_to_province %>%
  filter(provincia_cod == 62)
#Viedma y Carmen de Patagones (93) is the only urban agglomeration for the province Rio Negro (62) and it has only one entry in 2003, so it has to be excluded in the second step of the low quota specification due to missing data

#use only urban aglomerations with at least 13 years of data
#use only one urban agglomeration per province
consistent_aglos <- c(4, 6, 7, 8, 9, 10, 12, 13, 15, 17,
                      18, 19, 20, 22, 23, 25, 26, 27, 29, 30,
                      31, 32, 33)

#province-year panel construction
build_province_panel <- function(ministry_df, value_name, consistent_aglos) {
  ministry_df %>%
    filter(aglomerado %in% consistent_aglos) %>%
    left_join(aglo_to_province, by = "aglomerado") %>%
    left_join(province_mapping, by = "provincia_cod") %>%
    filter(!is.na(province)) %>%
    group_by(province, year) %>%
    summarise(
      !!value_name := mean(!!sym(value_name), na.rm = TRUE),
      n_aglos = n(),
      .groups = "drop"
    )
}
panel_unemp    <- build_province_panel(ministry_unemp, "unemp_rate", consistent_aglos)
panel_emp      <- build_province_panel(ministry_emp, "emp_rate", consistent_aglos)
panel_lfp      <- build_province_panel(ministry_lfp, "lfp_rate", consistent_aglos)
panel_underemp <- build_province_panel(ministry_underemp, "underemp_rate", consistent_aglos)
panel_overemp  <- build_province_panel(ministry_overemp, "overemp_rate", consistent_aglos)

#all outcomes into one panel
second_stage_low <- panel_unemp %>%
  left_join(panel_emp %>% select(province, year, emp_rate), by = c("province", "year")) %>%
  left_join(panel_lfp %>% select(province, year, lfp_rate), by = c("province", "year")) %>%
  left_join(panel_underemp %>% select(province, year, underemp_rate), by = c("province", "year")) %>%
  left_join(panel_overemp %>% select(province, year, overemp_rate), by = c("province", "year")) %>%
  left_join(
    treatment_panel %>% select(province, year, low_quota_implement, low_quota_adopt, womens_rep),
    by = c("province", "year")
  )

#urban agglomerations of Buenos Aires Province: female unemployment rate in Conurbano vs. Bahia Blanca vs. Gran La Plata (1990-2003)
ministry_unemp %>%
  filter(aglomerado %in% c(2, 3, 33)) %>%
  select(aglomerado_name, year, unemp_rate) %>%
  pivot_wider(names_from = aglomerado_name, values_from = unemp_rate) %>%
  print(n = 14)
#large differences across 3 agglomerations

#verify province-agglomerate matching
ministry_unemp %>%
  filter(aglomerado %in% consistent_aglos) %>%
  left_join(aglo_to_province, by = "aglomerado") %>%
  left_join(province_mapping, by = "provincia_cod") %>%
  filter(!is.na(province)) %>%
  distinct(province, aglomerado, aglomerado_name) %>%
  arrange(province) %>%
  print(n = 25)

#expected years for the low quota analysis
low_quota_years <- 1990:2003

#count observations per province and identify missing years
ministry_unemp %>%
  filter(aglomerado %in% consistent_aglos) %>%
  left_join(aglo_to_province, by = "aglomerado") %>%
  left_join(province_mapping, by = "provincia_cod") %>%
  filter(!is.na(province)) %>%
  group_by(province) %>%
  summarise(
    n_obs           = n_distinct(year),
    expected        = length(low_quota_years),
    n_missing       = expected - n_obs,
    missing_years   = paste(setdiff(low_quota_years, unique(year)), collapse = ", "),
    .groups = "drop"
  ) %>%
  arrange(desc(n_missing), province) %>%
  print(n = 25)
#23 provinces included 
#6 provinces have 13 years of data, 17 provinces have 14 years of data 

#event-time plot for low quota labour market outcomes (event-time window: -4 to +4)
#Rio Negro excluded
#low quota: event-time labour market outcome data
event_time_data_low <- second_stage_low %>%
  filter(!province %in% c("Rio Negro")) %>%
  group_by(province) %>%
  mutate(
    treat_year_low = ifelse(any(low_quota_implement == 1),
                            min(year[low_quota_implement == 1]),
                            NA_integer_),
    event_time_low = year - treat_year_low
  ) %>%
  ungroup() %>%
  filter(!is.na(treat_year_low),
         event_time_low >= -4, event_time_low <= 4)
event_summary_low <- event_time_data_low %>%
  group_by(event_time_low) %>%
  summarise(
    across(
      c(unemp_rate, emp_rate, lfp_rate, underemp_rate, overemp_rate),
      list(mean = ~mean(.x, na.rm = TRUE),
           se   = ~sd(.x, na.rm = TRUE) / sqrt(sum(!is.na(.x))))
    ),
    .groups = "drop"
  ) %>%
  pivot_longer(
    cols      = -event_time_low,
    names_to  = c("outcome", ".value"),
    names_sep = "_(?=[^_]+$)"
  ) %>%
  mutate(outcome = factor(outcome,
                          levels = c("unemp_rate", "emp_rate", "lfp_rate", "underemp_rate", "overemp_rate"),
                          labels = c("Unemployment Rate", "Employment Rate", "LFP Rate",
                                     "Underemployment Rate", "Overemployment Rate")
  ))
#fixed y-axis span of 15 points, each panel centred on its own data
common_span <- 10
span_needed <- event_summary_low %>%
  group_by(outcome) %>%
  summarise(
    lo = min(mean - 1.96 * se, na.rm = TRUE),
    hi = max(mean + 1.96 * se, na.rm = TRUE),
    .groups = "drop"
  )
if (max(span_needed$hi - span_needed$lo) > common_span) {
  warning("A panel's data range exceeds common_span = ", common_span,
          "; data will clip. Largest range needed: ",
          round(max(span_needed$hi - span_needed$lo), 2))
}
limit_points <- span_needed %>%
  mutate(
    mid    = (lo + hi) / 2,
    ymin_b = mid - common_span / 2,
    ymax_b = mid + common_span / 2
  ) %>%
  select(outcome, ymin_b, ymax_b) %>%
  tidyr::pivot_longer(c(ymin_b, ymax_b), values_to = "mean") %>%
  mutate(event_time_low = 0)
plot_event_low_all <- ggplot(event_summary_low, aes(x = event_time_low, y = mean)) +
  geom_ribbon(aes(ymin = mean - 1.96*se,
                  ymax = mean + 1.96*se),
              fill = "#2166ac", alpha = 0.2) +
  geom_line(linewidth = 0.9, colour = "#2166ac") +
  geom_point(size = 2, colour = "#2166ac") +
  geom_blank(data = limit_points, aes(x = event_time_low, y = mean)) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey40") +
  scale_x_continuous(breaks = seq(-4, 4, by = 2)) +
  facet_wrap(~outcome, scales = "free_y", ncol = 2) +
  labs(
    title    = "Women's Labour Market Outcomes Around Low Quota Implementation",
    subtitle = "Event-time average across treated provinces",
    x        = "Years relative to quota implementation",
    y        = "Rate (%)",
    caption  = "Note: Shaded area shows 95% confidence interval. Treated provinces only. Rio Negro excluded."
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    plot.title       = element_text(face = "bold", size = 12),
    plot.subtitle    = element_text(size = 10, colour = "grey40"),
    plot.caption     = element_text(size = 8, colour = "grey50")
  )
ggsave("plot_event_low_all.pdf", plot_event_low_all, width = 10, height = 10)

#second step: effect of low quota implementation on women's labour market outcome variables (1990-2003)
#TWFE OLS reduced form
#province and year FE, SEs clustered at province level

#female unemployment rate
twfe_low_unemp <- feols(
  unemp_rate ~ low_quota_implement | province + year,
  data    = second_stage_low %>%
    filter(!is.na(unemp_rate), year >= 1990, year <= 2003,
           !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(twfe_low_unemp)
#with the implementation of a low quota, female unemployment rate increases by 0.37 pp, not statistically significant 

#employment rate
twfe_low_emp <- feols(
  emp_rate ~ low_quota_implement | province + year,
  data    = second_stage_low %>%
    filter(!is.na(emp_rate), year >= 1990, year <= 2003,
           !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(twfe_low_emp)
#with the implementation of a low quota, female employment rate increases by 0.85 pp, not statistically significant 

#labour force participation rate
twfe_low_lfp <- feols(
  lfp_rate ~ low_quota_implement | province + year,
  data    = second_stage_low %>%
    filter(!is.na(lfp_rate), year >= 1990, year <= 2003,
           !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(twfe_low_lfp)
#with the implementation of a low quota, female labour force participation rate increases by 1.14 pp, statistically significant at the 10% level

#underemployment rate
twfe_low_underemp <- feols(
  underemp_rate ~ low_quota_implement | province + year,
  data    = second_stage_low %>%
    filter(!is.na(underemp_rate), year >= 1990, year <= 2003,
           !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(twfe_low_underemp)
#with the implementation of a low quota, female underemployment rate increases by 0.73 pp, not statistically significant 

#overemployment rate
twfe_low_overemp <- feols(
  overemp_rate ~ low_quota_implement | province + year,
  data    = second_stage_low %>%
    filter(!is.na(overemp_rate), year >= 1990, year <= 2003,
           !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(twfe_low_overemp)
#with the implementation of a low quota, female overemployment rate decreases by 0.54 pp, not statistically significant 

#second-step: effect of high quota implementation on women's labour market outcome variables (1996-2025)
#outcome variables: female unemployment rate, female employment rate, female labour force participation rate, housewife rate, female overemployment rate, female underemployment rate
#data source: EPH individual-level microdata

#EPH cleaning function for early waves (1996-2002)
#key differences from 2003-2025 panels:
#gender: h13 instead of ch04 (2=female)
#age: computed from h11 (birth date in YYYY-MM-DD format) and ano4
#agglomerate: agloreal instead of aglomerado
#housewife: p11 with 4=ama de casa (housewife) instead of cat_inac
#hours worked: p15t (total hours including overtime) instead of intensi
#underemployment: p15t < 35 hours (broad definition, consistent with 2003-2015 intensi=1 OR intensi=2)
#overemployment: p15t > 45 hours (consistent with 2003-2015 intensi=4)
clean_eph_early <- function(df) {
  df %>%
    rename_with(tolower) %>%
    select(-aglomerado) %>%
    rename(aglomerado = agloreal) %>%
    mutate(
      ch04       = as.integer(h13), #gender
      birth_year = as.integer(format(as.Date(h11), "%Y")), #date of birth
      ch06       = as.integer(ano4) - birth_year,
      ano4       = as.integer(ano4), #year
      aglomerado = as.integer(aglomerado), #agglomerate
      pondera    = as.numeric(pondera), #weighting
      estado     = as.integer(estado), #1=employed, 2=unemployed, 3=economically inactive, 0=unknown                     
      p11        = suppressWarnings(as.integer(p11)), #1=retired or pensioner, 2=person living on investment income, 3=student, 4=housewife                    
      #5=child under 6, 6=disabled, 8=other                           
      p15t       = as.numeric(p15t), #total working hours + overtime in the reference week 
      p16        = suppressWarnings(as.integer(p16)), #would like to work longer hours: 1=yes; 2=no              
      #housewife (ama de casa): inactive (estado=3) and identifies as housewife (p11=4)
      housewife = case_when(
        estado == 3 & p11 == 4 ~ 1,  #inactive and housewife
        estado == 3 & p11 != 4 ~ 0,  #inactive but not housewife
        estado != 3            ~ 0,  #employed or unemployed
        TRUE                   ~ NA_real_
      ),
      #narrow underemployment (demanding only, consistent with 2003-2015)
      #works < 35 hours and wants more hours (p16=1)
      underemp = case_when(
        estado == 1 & !is.na(p15t) & p15t < 35 & p16 == 1 ~ 1,
        estado == 1 & !is.na(p15t) & !is.na(p16) & (p15t >= 35 | p16 != 1) ~ 0,
        TRUE ~ NA_real_
      ),
      #overemployment: works > 45 hours
      overemp = case_when(
        estado == 1 & !is.na(p15t) & p15t > 45 ~ 1,
        estado == 1 & !is.na(p15t) & p15t <= 45 ~ 0,
        TRUE ~ NA_real_
      )
    ) %>%
    filter(
      ch04 == 2, #female
      ch06 >= 14, #age 
      estado != 0 #excludes unknown
    ) %>%
    filter(!is.na(aglomerado), !is.na(pondera)) %>%
    dplyr::select(ano4, aglomerado, pondera,
                  estado, housewife, underemp, overemp)
}
#run cleaning function on early waves
eph_panel_early <- suppressWarnings(
  bind_rows(lapply(eph_files_early, function(x) clean_eph_early(x$df)))
)
path_EH_1996 %>%
  rename_with(tolower) %>%
  mutate(
    birth_year = as.integer(format(as.Date(h11), "%Y")),
    age        = 1996L - birth_year
  ) %>%
  filter(h13 == 2, age >= 14) 

#early panel (1996-2002) 
eph_panel_early %>%
  group_by(ano4) %>%
  summarise(
    n = n(),
    #employment status rates
    pct_employed = round(mean(estado == 1, na.rm = TRUE) * 100, 1),
    pct_unemployed = round(mean(estado == 2, na.rm = TRUE) * 100, 1),
    pct_inactive = round(mean(estado == 3, na.rm = TRUE) * 100, 1),
    #lfp rate = (employed + unemployed) / total female population
    lfp_rate = round(mean(estado %in% c(1, 2), na.rm = TRUE) * 100, 1),
    pct_housewife = round(mean(housewife, na.rm = TRUE) * 100, 1),
    pct_underemp = round(mean(underemp, na.rm = TRUE) * 100, 1),
    pct_overemp = round(mean(overemp, na.rm = TRUE) * 100, 1),
    .groups = "drop"
  ) 
  
#EPH cleaning function for late panels (2003-2025)
clean_eph_with_quarter <- function(df, year, quarter = 2) {
  df %>%
    mutate(across(where(is.labelled), as.numeric)) %>%
    rename_with(tolower) %>%
    filter(
      ch04 == 2, #gender: 2=female
      ch06 >= 14, #age
      estado != 0 #status of activity; 0=individual interview not conducted 
    ) %>%
    mutate(
      ano4         = as.integer(year),
      quarter      = quarter,
      aglomerado   = as.integer(aglomerado),
      pondera      = as.numeric(pondera),
      estado       = as.integer(estado),
      cat_inac  = suppressWarnings(as.integer(cat_inac)),
      housewife = case_when(
        estado == 3 & cat_inac == 4 ~ 1, #inactive and housewife
        estado == 3 & cat_inac != 4 ~ 0, #inactive but not housewife
        estado != 3                 ~ 0, #employed or unemployed
        TRUE                        ~ NA_real_
      ),
      #underemployment harmonization (2003-2025): 
      #2003-2015: 1 = underemployment (job-seeking), 2 = underemployment (not job-seeking), 3 = full-time employment, 4 = overemployment, 5 = employed but did not work during the week, 9 = NA
      #2016+:     1 = underemployed due to insufficient hours, 2 = fully employed, 3 = overemployed, 4 = employed but did not work during the week, 9 = NA
      #after harmonisation:
      #2003-2015: intensi (1 & 2) = broad underemployment (1=underemployment (job-seeking) + 2=underemployment (not job-seeking))
      #2016+:     intensi=1 = broad underemployment (all underemployed)
      intensi = suppressWarnings(as.integer(intensi)),
      underemp = case_when(
        ano4 <= 2015 & estado == 1 & intensi %in% c(1, 2) ~ 1, #employed and (1=underemployment (job-seeking) + 2=underemployment (not job-seeking))
        ano4 <= 2015 & estado == 1 & !is.na(intensi) & !intensi %in% c(1, 2) ~ 0, #employed, but not underemployed
        ano4 >= 2016 & estado == 1 & intensi == 1 ~ 1, #employed and underemployed
        ano4 >= 2016 & estado == 1 & !is.na(intensi) & intensi != 1 ~ 0, #employed, but not underemployed
        TRUE ~ NA_real_
      ),
      #overemployment (harmonized 2003-2025):
      #2003-2015: intensi=4 = overemployment 
      #2016+:     intensi=3 = overemployment 
      overemp = case_when(
        ano4 <= 2015 & estado == 1 & intensi == 4 ~ 1, #employed and overemployed
        ano4 <= 2015 & estado == 1 & !is.na(intensi) & intensi != 4 ~ 0, #employed, but not overemployed
        ano4 >= 2016 & estado == 1 & intensi == 3 ~ 1, #employed and overemployed
        ano4 >= 2016 & estado == 1 & !is.na(intensi) & intensi != 3 ~ 0, #employed, but not overemployed
        TRUE ~ NA_real_
      )
    ) %>%
    filter(!is.na(aglomerado), !is.na(pondera)) %>%
    dplyr::select(ano4, aglomerado, pondera, estado, housewife,
                  underemp, overemp)
}
#rebuild panel
eph_panel <- bind_rows(lapply(eph_files, function(x) {
  clean_eph_with_quarter(x$df, x$year, x$quarter)
}))


#2020 Q1 vs Q2 vs Q3 vs Q4
#Q1 2020
eph_2020_q1 <- path_EH_2020_1 %>%
  rename_with(tolower) %>%
  filter(ch04 == 2, ch06 >= 14) %>%
  mutate(
    estado = as.integer(estado),
    pondera = as.numeric(pondera),
    cat_inac = suppressWarnings(as.integer(cat_inac)),
    housewife = case_when(
      estado == 3 & cat_inac == 4 ~ 1,
      estado == 3 & cat_inac != 4 ~ 0,
      estado != 3 ~ 0,
      TRUE ~ NA_real_
    ),
    intensi_num = suppressWarnings(as.integer(intensi)),
    underemp = case_when(
      estado == 1 & intensi_num == 1 ~ 1,
      estado == 1 & !is.na(intensi_num) & intensi_num != 1 ~ 0,
      TRUE ~ NA_real_
    ),
    overemp = case_when(
      estado == 1 & intensi_num == 3 ~ 1,
      estado == 1 & !is.na(intensi_num) & intensi_num != 3 ~ 0,
      TRUE ~ NA_real_
    )
  ) %>%
  summarise(
    trimester = "Q1",
    n = n(),
    emp_rate = sum(pondera[estado == 1], na.rm = TRUE) / 
      sum(pondera[estado %in% c(1,2,3)], na.rm = TRUE) * 100,
    unemp_rate = sum(pondera[estado == 2], na.rm = TRUE) / 
      sum(pondera[estado %in% c(1,2)], na.rm = TRUE) * 100,
    lfp_rate = sum(pondera[estado %in% c(1,2)], na.rm = TRUE) / 
      sum(pondera[estado %in% c(1,2,3)], na.rm = TRUE) * 100,
    housewife_rate = sum(pondera[housewife == 1], na.rm = TRUE) /
      sum(pondera, na.rm = TRUE) * 100,
    underemp_rate = sum(pondera[underemp == 1], na.rm = TRUE) /
      sum(pondera[estado == 1], na.rm = TRUE) * 100,
    overemp_rate  = sum(pondera[overemp == 1], na.rm = TRUE) /
      sum(pondera[estado == 1], na.rm = TRUE) * 100
  )
#Q2 2020
eph_2020_q2 <- path_EH_2020 %>%
  rename_with(tolower) %>%
  filter(ch04 == 2, ch06 >= 14) %>%
  mutate(
    estado = as.integer(estado),
    pondera = as.numeric(pondera),
    cat_inac = suppressWarnings(as.integer(cat_inac)),
    housewife = case_when(
      estado == 3 & cat_inac == 4 ~ 1,
      estado == 3 & cat_inac != 4 ~ 0,
      estado != 3 ~ 0,
      TRUE ~ NA_real_
    ),
    intensi_num = suppressWarnings(as.integer(intensi)),
    underemp = case_when(
      estado == 1 & intensi_num == 1 ~ 1,
      estado == 1 & !is.na(intensi_num) & intensi_num != 1 ~ 0,
      TRUE ~ NA_real_
    ),
    overemp = case_when(
      estado == 1 & intensi_num == 3 ~ 1,
      estado == 1 & !is.na(intensi_num) & intensi_num != 3 ~ 0,
      TRUE ~ NA_real_
    )
  ) %>%
  summarise(
    trimester = "Q2",
    n = n(),
    emp_rate = sum(pondera[estado == 1], na.rm = TRUE) / 
      sum(pondera[estado %in% c(1,2,3)], na.rm = TRUE) * 100,
    unemp_rate = sum(pondera[estado == 2], na.rm = TRUE) / 
      sum(pondera[estado %in% c(1,2)], na.rm = TRUE) * 100,
    lfp_rate = sum(pondera[estado %in% c(1,2)], na.rm = TRUE) / 
      sum(pondera[estado %in% c(1,2,3)], na.rm = TRUE) * 100,
    housewife_rate = sum(pondera[housewife == 1], na.rm = TRUE) /
      sum(pondera, na.rm = TRUE) * 100,
    underemp_rate = sum(pondera[underemp == 1], na.rm = TRUE) /
      sum(pondera[estado == 1], na.rm = TRUE) * 100,
    overemp_rate  = sum(pondera[overemp == 1], na.rm = TRUE) /
      sum(pondera[estado == 1], na.rm = TRUE) * 100
  )
#Q3 2020
eph_2020_q3 <- path_EH_2020_3 %>%
  rename_with(tolower) %>%
  filter(ch04 == 2, ch06 >= 14) %>%
  mutate(
    estado = as.integer(estado),
    pondera = as.numeric(pondera),
    cat_inac = suppressWarnings(as.integer(cat_inac)),
    housewife = case_when(
      estado == 3 & cat_inac == 4 ~ 1,
      estado == 3 & cat_inac != 4 ~ 0,
      estado != 3 ~ 0,
      TRUE ~ NA_real_
    ),
    intensi_num = suppressWarnings(as.integer(intensi)),
    underemp = case_when(
      estado == 1 & intensi_num == 1 ~ 1,
      estado == 1 & !is.na(intensi_num) & intensi_num != 1 ~ 0,
      TRUE ~ NA_real_
    ),
    overemp = case_when(
      estado == 1 & intensi_num == 3 ~ 1,
      estado == 1 & !is.na(intensi_num) & intensi_num != 3 ~ 0,
      TRUE ~ NA_real_
    )
  ) %>%
  summarise(
    trimester = "Q3",
    n = n(),
    emp_rate = sum(pondera[estado == 1], na.rm = TRUE) / 
      sum(pondera[estado %in% c(1,2,3)], na.rm = TRUE) * 100,
    unemp_rate = sum(pondera[estado == 2], na.rm = TRUE) / 
      sum(pondera[estado %in% c(1,2)], na.rm = TRUE) * 100,
    lfp_rate = sum(pondera[estado %in% c(1,2)], na.rm = TRUE) / 
      sum(pondera[estado %in% c(1,2,3)], na.rm = TRUE) * 100,
    housewife_rate = sum(pondera[housewife == 1], na.rm = TRUE) /
      sum(pondera, na.rm = TRUE) * 100,
    underemp_rate = sum(pondera[underemp == 1], na.rm = TRUE) /
      sum(pondera[estado == 1], na.rm = TRUE) * 100,
    overemp_rate  = sum(pondera[overemp == 1], na.rm = TRUE) /
      sum(pondera[estado == 1], na.rm = TRUE) * 100
  )
#Q4 2020
eph_2020_q4 <- path_EH_2020_4 %>%
  rename_with(tolower) %>%
  filter(ch04 == 2, ch06 >= 14) %>%
  mutate(
    estado = as.integer(estado),
    pondera = as.numeric(pondera),
    cat_inac = suppressWarnings(as.integer(cat_inac)),
    housewife = case_when(
      estado == 3 & cat_inac == 4 ~ 1,
      estado == 3 & cat_inac != 4 ~ 0,
      estado != 3 ~ 0,
      TRUE ~ NA_real_
    ),
    intensi_num = suppressWarnings(as.integer(intensi)),
    underemp = case_when(
      estado == 1 & intensi_num == 1 ~ 1,
      estado == 1 & !is.na(intensi_num) & intensi_num != 1 ~ 0,
      TRUE ~ NA_real_
    ),
    overemp = case_when(
      estado == 1 & intensi_num == 3 ~ 1,
      estado == 1 & !is.na(intensi_num) & intensi_num != 3 ~ 0,
      TRUE ~ NA_real_
    )
  ) %>%
  summarise(
    trimester = "Q4",
    n = n(),
    emp_rate = sum(pondera[estado == 1], na.rm = TRUE) / 
      sum(pondera[estado %in% c(1,2,3)], na.rm = TRUE) * 100,
    unemp_rate = sum(pondera[estado == 2], na.rm = TRUE) / 
      sum(pondera[estado %in% c(1,2)], na.rm = TRUE) * 100,
    lfp_rate = sum(pondera[estado %in% c(1,2)], na.rm = TRUE) / 
      sum(pondera[estado %in% c(1,2,3)], na.rm = TRUE) * 100,
    housewife_rate = sum(pondera[housewife == 1], na.rm = TRUE) /
      sum(pondera, na.rm = TRUE) * 100,
    underemp_rate = sum(pondera[underemp == 1], na.rm = TRUE) /
      sum(pondera[estado == 1], na.rm = TRUE) * 100,
    overemp_rate  = sum(pondera[overemp == 1], na.rm = TRUE) /
      sum(pondera[estado == 1], na.rm = TRUE) * 100
  )
#compare all 2020 quarters
seasonality_2020 <- bind_rows(eph_2020_q1, eph_2020_q2, eph_2020_q3, eph_2020_q4)
print(seasonality_2020)
#there are large differences in sample size: Q2 has the fewest observations (15,706), Q1 the most (21,719)
#there are large differences for all variables across the four quarters
#Q2 employment rate drops from 44.1% in Q1 to 35.7% in Q2
#Q2 housewife rate jumps from 13.7% in Q1 to 19.8% in Q2
#Q3 and Q4 show partial recovery closer to Q1 data

#compare to 2019 Q2 baseline
eph_2019_q2 <- path_EH_2019 %>%
  rename_with(tolower) %>%
  filter(ch04 == 2, ch06 >= 14) %>%
  mutate(
    estado = as.integer(estado),
    pondera = as.numeric(pondera),
    cat_inac = suppressWarnings(as.integer(cat_inac)),
    housewife = case_when(
      estado == 3 & cat_inac == 4 ~ 1,
      estado == 3 & cat_inac != 4 ~ 0,
      estado != 3 ~ 0,
      TRUE ~ NA_real_
    ),
    intensi_num = suppressWarnings(as.integer(intensi)),
    underemp = case_when(
      estado == 1 & intensi_num == 1 ~ 1,
      estado == 1 & !is.na(intensi_num) & intensi_num != 1 ~ 0,
      TRUE ~ NA_real_
    ),
    overemp = case_when(
      estado == 1 & intensi_num == 3 ~ 1,
      estado == 1 & !is.na(intensi_num) & intensi_num != 3 ~ 0,
      TRUE ~ NA_real_
    )
  ) %>%
  summarise(
    year = "2019 Q2",
    n = n(),
    emp_rate = sum(pondera[estado == 1], na.rm = TRUE) / 
      sum(pondera[estado %in% c(1,2,3)], na.rm = TRUE) * 100,
    unemp_rate = sum(pondera[estado == 2], na.rm = TRUE) / 
      sum(pondera[estado %in% c(1,2)], na.rm = TRUE) * 100,
    lfp_rate = sum(pondera[estado %in% c(1,2)], na.rm = TRUE) / 
      sum(pondera[estado %in% c(1,2,3)], na.rm = TRUE) * 100,
    housewife_rate = sum(pondera[housewife == 1], na.rm = TRUE) /
      sum(pondera, na.rm = TRUE) * 100,
    underemp_rate = sum(pondera[underemp == 1], na.rm = TRUE) /
      sum(pondera[estado == 1], na.rm = TRUE) * 100,
    overemp_rate  = sum(pondera[overemp == 1], na.rm = TRUE) /
      sum(pondera[estado == 1], na.rm = TRUE) * 100
  )
#comparison table
comparison_2020 <- seasonality_2020 %>%
  mutate(year = paste("2020", trimester)) %>%
  select(year, n, emp_rate, unemp_rate, lfp_rate, housewife_rate, underemp_rate, overemp_rate) %>%
  bind_rows(eph_2019_q2, .) %>%
  mutate(across(c(emp_rate, unemp_rate, lfp_rate, housewife_rate, underemp_rate, overemp_rate), 
                ~round(.x, 2)))
print(comparison_2020)
#Q1 2020 is closest to the rates for Q2 2019 for all variables
#employment rate: 44.1% (Q1 2020) vs. 44.4% (Q2 2019) 
#housewife rate: 13.6% (Q1 2020) vs 12.9% (2019)
#using Q1 2020 instead of Q2 2020 avoids COVID-19 measurement shock and maintains data quality

#check intensi variable across 2024 quarters
#Q1 2024
eph_2024_q1_raw <- path_EH_2024_1 %>% rename_with(tolower)
class(eph_2024_q1_raw$intensi) #stored numeric
print(table(eph_2024_q1_raw$intensi, useNA = "always"))
#entries for all possible answers

#Q2 2024
eph_2024_q2_raw <- path_EH_2024 %>% rename_with(tolower)
class(eph_2024_q2_raw$intensi) #stored logical
print(table(eph_2024_q2_raw$intensi, useNA = "always"))
#only entry TRUE, they all become 1, so every entry is misclassified as underemployed

#Q3 2024
eph_2024_q3_raw <- path_EH_2024_3 %>% rename_with(tolower)
class(eph_2024_q3_raw$intensi) #stored logical
print(table(eph_2024_q3_raw$intensi, useNA = "always"))
#only entry TRUE, they all become 1, so every entry is misclassified as underemployed

#Q4 2024
eph_2024_q4_raw <- path_EH_2024_4 %>% rename_with(tolower)
class(eph_2024_q4_raw$intensi) #stored numeric
print(table(eph_2024_q4_raw$intensi, useNA = "always"))
#entries for all possible answers
#very few intensi=4 entries (employed but did not work during the week)  
#use Q1 2024 

#seasonality check: 2023 Q1 vs Q2 for all high-quota outcome variables
compute_eph_rates <- function(df, quarter_label) {
  df %>%
    rename_with(tolower) %>%
    filter(ch04 == 2, ch06 >= 14) %>%
    mutate(
      pondera     = as.numeric(pondera),
      estado      = as.integer(estado),
      intensi_num = suppressWarnings(as.integer(intensi)),
      cat_inac    = suppressWarnings(as.integer(cat_inac))
    ) %>%
    summarise(
      trimester      = quarter_label,
      # Status rates: denominator = working-age female population
      emp_rate       = sum(pondera[estado == 1], na.rm = TRUE) /
        sum(pondera, na.rm = TRUE) * 100,
      unemp_rate     = sum(pondera[estado == 2], na.rm = TRUE) /
        sum(pondera[estado %in% c(1, 2)], na.rm = TRUE) * 100,
      lfp_rate       = sum(pondera[estado %in% c(1, 2)], na.rm = TRUE) /
        sum(pondera, na.rm = TRUE) * 100,
      housewife_rate = sum(pondera[estado == 3 & cat_inac == 4], na.rm = TRUE) /
        sum(pondera, na.rm = TRUE) * 100,
      # Intensity rates: denominator = employed women
      underemp_rate  = sum(pondera[estado == 1 & intensi_num == 1], na.rm = TRUE) /
        sum(pondera[estado == 1], na.rm = TRUE) * 100,
      overemp_rate   = sum(pondera[estado == 1 & intensi_num == 3], na.rm = TRUE) /
        sum(pondera[estado == 1], na.rm = TRUE) * 100
    )
}
eph_2023_q1 <- compute_eph_rates(path_EH_2023_1, "Q1")
eph_2023_q2 <- compute_eph_rates(path_EH_2023,   "Q2")
seasonality_check_2023 <- bind_rows(eph_2023_q1, eph_2023_q2) %>%
  mutate(
    diff_emp       = emp_rate       - lag(emp_rate),
    diff_unemp     = unemp_rate     - lag(unemp_rate),
    diff_lfp       = lfp_rate       - lag(lfp_rate),
    diff_housewife = housewife_rate - lag(housewife_rate),
    diff_underemp  = underemp_rate  - lag(underemp_rate),
    diff_overemp   = overemp_rate   - lag(overemp_rate)
  )
print(seasonality_check_2023)
#small differences between Q1 and Q2 across all variables

#combine early and late panels
eph_panel_full <- bind_rows(
  eph_panel_early,
  eph_panel %>% dplyr::select(ano4, aglomerado, pondera,
                              estado, housewife, 
                              underemp, overemp)
)

#agglomeration to province-year level 
#full panel (1996-2025): unemp_rate, emp_rate, lfp_rate, housewife_rate, underemp_rate, overemp_rate
eph_panel_prov_full <- eph_panel_full %>%
  filter(!aglomerado %in% c(38, 91)) %>%
  left_join(aglo_to_province, by = "aglomerado") %>%
  filter(!is.na(provincia_cod)) %>%
  left_join(province_mapping, by = "provincia_cod") %>%
  filter(!is.na(province)) %>%
  group_by(province, ano4) %>%
  summarise(
    unemp_rate     = sum(pondera[estado == 2], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2)], na.rm = TRUE) * 100,
    emp_rate       = sum(pondera[estado == 1], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2, 3)], na.rm = TRUE) * 100,
    lfp_rate       = sum(pondera[estado %in% c(1, 2)], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2, 3)], na.rm = TRUE) * 100,
    housewife_rate = sum(pondera[housewife == 1], na.rm = TRUE) /
      sum(pondera, na.rm = TRUE) * 100,
    underemp_rate  = sum(pondera[underemp == 1], na.rm = TRUE) /
      sum(pondera[estado == 1], na.rm = TRUE) * 100,
    overemp_rate   = sum(pondera[overemp == 1], na.rm = TRUE) /
      sum(pondera[estado == 1], na.rm = TRUE) * 100,
    unemp_pop_rate = sum(pondera[estado == 2], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2, 3)], na.rm = TRUE) * 100,
    .groups        = "drop"
  ) %>%
  rename(year = ano4)
eph_panel_full %>%
  filter(!aglomerado %in% c(38, 91)) %>%
  left_join(aglo_to_province, by = "aglomerado") %>%
  filter(!is.na(provincia_cod)) %>%
  left_join(province_mapping, by = "provincia_cod") %>%
  filter(!is.na(province)) %>%
  distinct(province, aglomerado) %>%
  add_count(province, name = "n_aglos") %>%
  filter(n_aglos > 1) %>%
  arrange(province) %>%
  dplyr::select(province, aglomerado) %>%
  print()
#4 provinces are matched with multiple urban agglomerations (Buenos Aires Province with 4, Cordoba with 2, Entre Rios with 2 and Santa Fe with 2)

second_stage_high <- treatment_panel %>%
  filter(year >= 1996) %>%
  left_join(eph_panel_prov_full, by = c("province", "year")) %>%
  filter(!is.na(province))

# Define expected years for the high quota analysis
high_quota_years <- 1996:2025

# Count observations and identify missing years per province
second_stage_high %>%
  group_by(province) %>%
  summarise(
    n_obs         = sum(!is.na(unemp_rate)),
    expected      = length(high_quota_years),
    n_missing     = expected - n_obs,
    missing_years = paste(
      setdiff(high_quota_years, year[!is.na(unemp_rate)]),
      collapse = ", "
    ),
    .groups = "drop"
  ) %>%
  arrange(desc(n_missing), province) %>%
  print(n = 25)
#Rio Negro is the only province with missing data (1996-2006)

#absolute trends analysis for labour market outcome variables (1996-2025): population-adjusted labor market transitions
#raw changes in numbers of women aged 14+ in each labor market state over time
absolute_trends <- second_stage_high %>%
  filter(!is.na(housewife_rate), !is.na(unemp_rate), !is.na(emp_rate), !is.na(lfp_rate)) %>%
  arrange(province, year) %>%
  group_by(year) %>%
  summarise(
    mean_housewife_rate = mean(housewife_rate, na.rm = TRUE),
    mean_unemp_rate = mean(unemp_rate, na.rm = TRUE),
    mean_emp_rate = mean(emp_rate, na.rm = TRUE),
    mean_lfp_rate = mean(lfp_rate, na.rm = TRUE),
    mean_underemp_rate = mean(underemp_rate, na.rm = TRUE),
    mean_overemp_rate = mean(overemp_rate, na.rm = TRUE),
    #unemployed/population rate
    mean_unemp_pop_rate = mean((unemp_rate * lfp_rate) / 100, na.rm = TRUE),
    n_provinces = n(),
    .groups = "drop"
  ) %>%
  mutate(
    #changes from 1996 baseline
    housewife_change = mean_housewife_rate - first(mean_housewife_rate),
    unemp_change = mean_unemp_rate - first(mean_unemp_rate),
    emp_change = mean_emp_rate - first(mean_emp_rate),
    lfp_change = mean_lfp_rate - first(mean_lfp_rate),
    unemp_pop_change = mean_unemp_pop_rate - first(mean_unemp_pop_rate),
  )
trends_table <- absolute_trends %>%
  select(
    year,
    housewife = mean_housewife_rate,
    unemp     = mean_unemp_rate,
    emp       = mean_emp_rate,
    lfp       = mean_lfp_rate,
    unemp_pop = mean_unemp_pop_rate
  ) %>%
  mutate(across(-year, ~ round(., 1)))
print(trends_table, n=Inf)
trends_long <- absolute_trends %>%
  select(year, mean_housewife_rate, mean_emp_rate, mean_unemp_rate, 
         mean_lfp_rate, mean_unemp_pop_rate) %>%
  pivot_longer(cols = -year, names_to = "variable", values_to = "rate") %>%
  mutate(
    variable = case_when(
      variable == "mean_housewife_rate" ~ "Housewife Rate",
      variable == "mean_emp_rate" ~ "Employment Rate",
      variable == "mean_unemp_rate" ~ "Unemployment Rate",
      variable == "mean_lfp_rate" ~ "LFP Rate",
      variable == "mean_unemp_pop_rate" ~ "Unemployed/Population"
    )
  )
#plot all trends
ggplot(trends_long, aes(x = year, y = rate, color = variable)) +
  geom_line(linewidth = 1) +
  geom_point(size = 2) +
  geom_vline(xintercept = 2002, linetype = "dashed", colour = "grey40") +
  annotate("text", x = 2002.2, y = max(trends_long$rate, na.rm = TRUE),
           label = "Peak of Argentine\n Economic Crisis (2002)",
           hjust = 0, size = 3, colour = "grey40") +
  scale_colour_manual(values = c(
    "Housewife Rate"        = "#d73027",
    "Employment Rate"       = "#e6a817",
    "LFP Rate"              = "#1a9641",
    "Unemployment Rate"     = "#c994c7",
    "Unemployed/Population" = "#2166ac"
  )) +
  scale_x_continuous(breaks = seq(1996, 2025, by = 4)) +
  labs(
    title    = "Labour Market Trends for Women (1996–2025)",
    subtitle = "Average rates across Argentine provinces",
    x        = "Year",
    y        = "Rate (%)",
    colour   = "Outcome"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    plot.title       = element_text(face = "bold", size = 12),
    plot.subtitle    = element_text(size = 10, colour = "grey40"),
    plot.caption     = element_text(size = 8, colour = "grey50"),
    legend.position  = "bottom"
  )
ggsave("absolute_trends_all.pdf", width = 12, height = 7, dpi = 300)

#event-time plot for high quota labour market outcomes (event-time window: -4 to +4)
event_time_data_high <- second_stage_high %>%
  group_by(province) %>%
  mutate(
    treat_year_high = ifelse(any(high_quota_implement == 1),
                             min(year[high_quota_implement == 1]),
                             NA_integer_),
    event_time_high = year - treat_year_high
  ) %>%
  ungroup() %>%
  filter(!is.na(treat_year_high),
         event_time_high >= -4, event_time_high <= 4)
event_summary_high <- event_time_data_high %>%
  group_by(event_time_high) %>%
  summarise(
    across(
      c(unemp_rate, emp_rate, lfp_rate, housewife_rate, underemp_rate, overemp_rate),
      list(mean = ~mean(.x, na.rm = TRUE),
           se   = ~sd(.x, na.rm = TRUE) / sqrt(sum(!is.na(.x))))
    ),
    .groups = "drop"
  ) %>%
  pivot_longer(
    cols      = -event_time_high,
    names_to  = c("outcome", ".value"),
    names_sep = "_(?=[^_]+$)"
  ) %>%
  mutate(outcome = factor(outcome,
                          levels = c("unemp_rate", "emp_rate", "lfp_rate",
                                     "housewife_rate", "underemp_rate", "overemp_rate"),
                          labels = c("Unemployment Rate", "Employment Rate", "LFP Rate",
                                     "Housewife Rate", "Underemployment Rate", "Overemployment Rate")
  ))
#equal y-axis span across panels, each centred on its own data (include CI bands)
span_needed <- event_summary_high %>%
  group_by(outcome) %>%
  summarise(
    lo = min(mean - 1.96 * se, na.rm = TRUE),
    hi = max(mean + 1.96 * se, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(range = hi - lo)
common_span <- 15
limit_points <- span_needed %>%
  mutate(
    mid   = (lo + hi) / 2,
    ymin_b = mid - common_span / 2,
    ymax_b = mid - common_span / 2 + common_span   
  ) %>%
  select(outcome, ymin_b, ymax_b) %>%
  tidyr::pivot_longer(c(ymin_b, ymax_b), values_to = "mean") %>%
  mutate(event_time_high = 0)   
plot_event_high_all <- ggplot(event_summary_high, aes(x = event_time_high, y = mean)) +
  geom_ribbon(aes(ymin = mean - 1.96*se,
                  ymax = mean + 1.96*se),
              fill = "#2166ac", alpha = 0.2) +
  geom_line(linewidth = 0.9, colour = "#2166ac") +
  geom_point(size = 2, colour = "#2166ac") +
  geom_blank(data = limit_points, aes(x = event_time_high, y = mean)) +
  geom_vline(xintercept = 0, linetype = "dashed", colour = "grey40") +
  scale_x_continuous(breaks = seq(-4, 4, by = 2)) +
  facet_wrap(~outcome, scales = "free_y", ncol = 2) +
  labs(
    title    = "Women's Labour Market Outcomes Around High Quota Implementation",
    subtitle = "Event-time average across treated provinces",
    x        = "Years relative to quota implementation",
    y        = "Rate (%)",
    caption  = "Note: Shaded area shows 95% confidence interval. Treated provinces only."
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    plot.title       = element_text(face = "bold", size = 12),
    plot.subtitle    = element_text(size = 10, colour = "grey40"),
    plot.caption     = element_text(size = 8, colour = "grey50")
  )
ggsave("plot_event_high_all.pdf", plot_event_high_all, width = 10, height = 12)

#analysis of structural break in 2002 
second_stage_high %>%
  filter(year >= 1996, year <= 2025) %>%
  group_by(year) %>%
  summarise(
    n_provinces    = n_distinct(province),
    mean_unemp     = mean(unemp_rate,     na.rm = TRUE),
    mean_emp       = mean(emp_rate,       na.rm = TRUE),
    mean_lfp       = mean(lfp_rate,       na.rm = TRUE),
    mean_housewife = mean(housewife_rate, na.rm = TRUE),
    mean_underemp  = mean(underemp_rate,  na.rm = TRUE),
    mean_overemp   = mean(overemp_rate,   na.rm = TRUE),
    .groups        = "drop"
  ) %>%
  print(n = 30)
#all outcome variables (except overemployment rate) show a large jump from 2002 to 2003

#hypothesis 1: end of economic crisis (1998-2002)
#crisis recovery should affect all provinces similarly
province_jumps <- eph_panel_prov_full %>%
  filter(year %in% c(2002, 2003)) %>%
  select(province, year, unemp_rate) %>%
  pivot_wider(
    names_from  = year,
    values_from = unemp_rate,
    names_prefix = "year_"
  ) %>%
  mutate(jump_2003 = year_2003 - year_2002)
print(province_jumps %>% arrange(desc(jump_2003)), n = 30)
province_jumps %>%
  summarise(
    mean_jump = mean(jump_2003, na.rm = TRUE),
    sd_jump   = sd(jump_2003,   na.rm = TRUE),
    min_jump  = min(jump_2003,  na.rm = TRUE),
    max_jump  = max(jump_2003,  na.rm = TRUE),
    range     = max_jump - min_jump
  ) %>%
  print()
#no uniform crisis recovery pattern
#largest increase in unemployment rate for Mendoza, largest decrease in unemployment rate in Neuquén

#robustness check: restrict panel to post-2003 and re-estimate high quota specification 
data_post <- second_stage_high %>% filter(year >= 2003)
#unemployment rate
model_post_unemp <- feols(
  unemp_rate ~ high_quota_implement | province + year,
  data    = data_post,
  cluster = ~province
)
summary(model_post_unemp)
#with the implementation of a high quota, female unemployment rate increases by 0.69 pp, not statistically significant 

#employment rate
model_post_emp <- feols(
  emp_rate ~ high_quota_implement | province + year,
  data    = data_post,
  cluster = ~province
)
summary(model_post_emp)
#with the implementation of a high quota, female employment rate increases by 0.43 pp, not statistically significant 

#labour force participation rate
model_post_lfp <- feols(
  lfp_rate ~ high_quota_implement | province + year,
  data    = data_post,
  cluster = ~province
)
summary(model_post_lfp)
#with the implementation of a high quota, female labour force participation rate increases by 0.73 pp, not statistically significant 

#housewife rate
model_post_housewife <- feols(
  housewife_rate ~ high_quota_implement | province + year,
  data    = data_post,
  cluster = ~province
)
summary(model_post_housewife)
#with the implementation of a high quota, housewife rate decreases by 1.32 pp, statistically significant at the 5% level

#underemployment rate
model_post_underemp <- feols(
  underemp_rate ~ high_quota_implement | province + year,
  data    = data_post,
  cluster = ~province
)
summary(model_post_underemp)
#with the implementation of a high quota, underemployment rate increases by 0.65 pp, not statistically significant

#overemployment rate
model_post_overemp <- feols(
  overemp_rate ~ high_quota_implement | province + year,
  data    = data_post,
  cluster = ~province
)
summary(model_post_overemp)
#with the implementation of a high quota, female overemployment rate decreases by 0.68 pp, not statistically significant 

#year FE check: treatment timing vs. mean unemployment by year
second_stage_high %>%
  filter(!is.na(unemp_rate)) %>%
  group_by(year) %>%
  summarise(
    n_total    = n(),
    n_treated  = sum(high_quota_implement == 1, na.rm = TRUE),
    mean_unemp = mean(unemp_rate, na.rm = TRUE),
    .groups    = "drop"
  ) %>%
  print(n = 30)
#treatment intensity rises as mean unemployment falls
#should be absorbed by year FE and the clustering of treatment in 2019-2025

#hypothesis 2: questionnaire and sample redesign 
#if the 2003 break reflects measurement changes, it should not differ between provinces treated and not yet treated by 2003
#compare 2003 jump between early and late adopters
quota_timing <- treatment_panel %>%
  filter(!is.na(high_quota_implement)) %>%
  group_by(province) %>%
  summarise(
    first_high_quota = ifelse(any(high_quota_implement == 1),
                              min(year[high_quota_implement == 1]),
                              NA_integer_),
    treated_by_2003  = !is.na(first_high_quota) & first_high_quota <= 2003,
    .groups          = "drop"
  )
province_jumps_treatment <- province_jumps %>%
  left_join(quota_timing, by = "province")
province_jumps_treatment %>%
  group_by(treated_by_2003) %>%
  summarise(
    n         = n(),
    mean_jump = mean(jump_2003, na.rm = TRUE),
    sd_jump   = sd(jump_2003,   na.rm = TRUE),
    .groups   = "drop"
  ) %>%
  print()
#by 2003, 2 provinces have implemented a high quota, 22 have not, the mean jump is similar across the two groups 

#second step: effect of high quota implementation on women's labour market outcome variables (1996-2025)
#TWFE OLS reduced form
#province and year FE, SEs clustered at province level
second_stage_high %>%
  summarise(
    n           = n(),
    n_provinces = n_distinct(province),
    years       = paste(min(year), max(year), sep = "-"),
    n_unemp     = sum(!is.na(unemp_rate)),
    n_emp       = sum(!is.na(emp_rate)),
    n_lfp       = sum(!is.na(lfp_rate)),
    n_housewife = sum(!is.na(housewife_rate)),
    n_underemp  = sum(!is.na(underemp_rate)),
    n_overemp   = sum(!is.na(overemp_rate))
  )
#identify missing observations
missing_obs <- second_stage_high %>%
  filter(is.na(emp_rate) | is.na(underemp_rate)) %>%
  dplyr::count(province, year) %>%
  arrange(province, year)
print(missing_obs, n = Inf)
#720 total observations (24 provinces × 30 years)
#11 missing observations; all from Rio Negro (1996-2006) 

#all provinces
#female unemployment rate
twfe_high_unemp_rn1 <- feols(
  unemp_rate ~ high_quota_implement | province + year,
  data    = second_stage_high %>% filter(!is.na(unemp_rate)),
  cluster = ~province
)
summary(twfe_high_unemp_rn1)
#with the implementation of a high quota, female unemployment rate increases by 1.13 pp, not statistically significant 

#female employment rate
twfe_high_emp_rn1 <- feols(
  emp_rate ~ high_quota_implement | province + year,
  data    = second_stage_high %>% filter(!is.na(emp_rate)),
  cluster = ~province
)
summary(twfe_high_emp_rn1)
#with the implementation of a high quota, female employment rate increases by 0.70 pp, not statistically significant 

#female lfp rate
twfe_high_lfp_rn1 <- feols(
  lfp_rate ~ high_quota_implement | province + year,
  data    = second_stage_high %>% filter(!is.na(lfp_rate)),
  cluster = ~province
)
summary(twfe_high_lfp_rn1)
#with the implementation of a high quota, female lfp rate increases by 1.27 pp, not statistically significant 

#housewife rate
twfe_high_housewife_rn1 <- feols(
  housewife_rate ~ high_quota_implement | province + year,
  data    = second_stage_high %>% filter(!is.na(housewife_rate)),
  cluster = ~province
)
summary(twfe_high_housewife_rn1)
#with the implementation of a high quota, housewife rate decreases by 1.09 pp, statistically significant at the 5% level

#female underemployment rate
twfe_high_underemp_rn1 <- feols(
  underemp_rate ~ high_quota_implement | province + year,
  data    = second_stage_high %>% filter(!is.na(underemp_rate)),
  cluster = ~province
)
summary(twfe_high_underemp_rn1)
#with the implementation of a high quota, female underemployment rate increases by 1.39 pp, not statistically significant 

#female overemployment rate
twfe_high_overemp_rn1 <- feols(
  overemp_rate ~ high_quota_implement | province + year,
  data    = second_stage_high %>% filter(!is.na(overemp_rate)),
  cluster = ~province
)
summary(twfe_high_overemp_rn1)
#with the implementation of a high quota, female overemployment rate decreases by 0.77 pp, not statistically significant 

#robustness check: exclude Rio Negro
#female unemployment rate
twfe_high_unemp_rn2 <- feols(
  unemp_rate ~ high_quota_implement | province + year,
  data    = second_stage_high %>%
    filter(!is.na(unemp_rate), !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(twfe_high_unemp_rn2)
#with the implementation of a high quota, female unemployment rate increases by 0.89 pp, not statistically significant 

#female employment rate
twfe_high_emp_rn2 <- feols(
  emp_rate ~ high_quota_implement | province + year,
  data    = second_stage_high %>%
    filter(!is.na(emp_rate), !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(twfe_high_emp_rn2)
#with the implementation of a high quota, female employment rate increases by 0.42 pp, not statistically significant 

#female lfp rate
twfe_high_lfp_rn2 <- feols(
  lfp_rate ~ high_quota_implement | province + year,
  data    = second_stage_high %>%
    filter(!is.na(lfp_rate), !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(twfe_high_lfp_rn2)
#with the implementation of a high quota, female lfp rate increases by 0.84 pp, not statistically significant 

#housewife rate
twfe_high_housewife_rn2 <- feols(
  housewife_rate ~ high_quota_implement | province + year,
  data    = second_stage_high %>%
    filter(!is.na(housewife_rate), !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(twfe_high_housewife_rn2)
#with the implementation of a high quota, housewife rate decreases by 1.08 pp, statistically significant at the 5% level

#female underemployment rate
twfe_high_underemp_rn2 <- feols(
  underemp_rate ~ high_quota_implement | province + year,
  data    = second_stage_high %>%
    filter(!is.na(underemp_rate), !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(twfe_high_underemp_rn2)
#with the implementation of a high quota, female underemployment rate increases by 0.82 pp, not statistically significant 

#female overemployment rate
twfe_high_overemp_rn2 <- feols(
  overemp_rate ~ high_quota_implement | province + year,
  data    = second_stage_high %>%
    filter(!is.na(overemp_rate), !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(twfe_high_overemp_rn2)
#with the implementation of a high quota, female overemployment rate decreases by 0.62 pp, not statistically significant 

#heterogeneity analysis
#weighted distribution of labour market status
eph_panel_full %>%
  group_by(estado) %>%
  summarise(weighted_n = sum(pondera, na.rm = TRUE)) %>%
  mutate(
    status = case_when(
      estado == 1 ~ "Employed",
      estado == 2 ~ "Unemployed",
      estado == 3 ~ "Inactive",
      TRUE ~ "Other/Missing"
    ),
    pct = weighted_n / sum(weighted_n) * 100
  ) %>%
  arrange(estado)
#42% employed, 5% unemployed, 52% inactive

#housewife breakdown among inactive women
eph_panel_full %>%
  filter(estado == 3) %>%
  summarise(
    total_inactive  = sum(pondera, na.rm = TRUE),
    housewives      = sum(pondera[housewife == 1], na.rm = TRUE),
    pct_housewife_of_inactive = housewives / total_inactive * 100
  )
#38% of economically inactive women identify as housewives

#inactivity and housewife rates as share of all women
eph_panel_full %>%
  summarise(
    total_women     = sum(pondera, na.rm = TRUE),
    inactive        = sum(pondera[estado == 3], na.rm = TRUE),
    housewives      = sum(pondera[housewife == 1], na.rm = TRUE),
    pct_inactive    = inactive / total_women * 100,
    pct_housewife   = housewives / total_women * 100
  )
#overall 19% of all working aged women identify as housewives

#pre-treatment vs. post-treatment comparison
treated_provinces <- treatment_panel %>%
  filter(!is.na(high_quota_implement), high_quota_implement == 1) %>%
  group_by(province) %>%
  summarise(treatment_year = min(year), .groups = "drop")
prepost_comparison <- second_stage_high %>%
  inner_join(treated_provinces, by = "province") %>%
  filter(!is.na(housewife_rate), !is.na(unemp_rate), !is.na(emp_rate)) %>%
  mutate(
    period = ifelse(year < treatment_year, "Pre-treatment", "Post-treatment")
  ) %>%
  group_by(period) %>%
  summarise(
    mean_housewife = mean(housewife_rate, na.rm = TRUE),
    mean_unemp = mean(unemp_rate, na.rm = TRUE),
    mean_emp = mean(emp_rate, na.rm = TRUE),
    mean_lfp = mean(lfp_rate, na.rm = TRUE),
    mean_unemp_pop = mean((unemp_rate * lfp_rate) / 100, na.rm = TRUE),
    n_obs = n(),
    .groups = "drop"
  )
pre_values <- prepost_comparison %>% filter(period == "Pre-treatment")
post_values <- prepost_comparison %>% filter(period == "Post-treatment")
print(prepost_comparison)

trends_focus <- absolute_trends %>%
  select(year, mean_housewife_rate, mean_unemp_rate, mean_unemp_pop_rate) %>%
  pivot_longer(cols = -year, names_to = "variable", values_to = "rate") %>%
  mutate(
    variable = case_when(
      variable == "mean_housewife_rate" ~ "Housewife Rate",
      variable == "mean_unemp_rate"     ~ "Unemployment Rate",
      variable == "mean_unemp_pop_rate" ~ "Unemployed/Population"
    )
  )
#pre-treatment large difference in housewife rate (decrease), female unemployment rate (decrease), employment rate (increase) and labour force participation rate (increase)

#demographic composition 
#early panel with composition variables (1996-2002)
clean_eph_composition_early <- function(df, year) {
  df %>%
    rename_with(tolower) %>%
    select(-aglomerado) %>%
    rename(aglomerado = agloreal) %>%
    mutate(
      ano4       = as.integer(year),  #year parameter
      aglomerado = as.integer(aglomerado),
      pondera    = as.numeric(pondera),
      h12        = suppressWarnings(as.integer(h12)),  #age
      h13        = suppressWarnings(as.integer(h13))   #gender
    ) %>%
    filter(
      h12 >= 14,
      estado != 0,
      !is.na(aglomerado),
      !is.na(pondera),
      !is.na(h12),
      !is.na(h13)
    ) %>%
    select(ano4, aglomerado, pondera, h12, h13)
}
#late panel with composition variables (2003-2025)
clean_eph_composition_late <- function(df, year, quarter = 2) {
  df %>%
    mutate(across(where(is.labelled), as.numeric)) %>%
    rename_with(tolower) %>%
    filter(
      ch06 >= 14, estado != 0
    ) %>%
    mutate(
      ano4       = as.integer(year),
      quarter    = quarter,
      aglomerado = as.integer(aglomerado),
      pondera    = as.numeric(pondera),
      ch06       = as.integer(ch06),  #age
      ch04       = as.integer(ch04)   #gender
    ) %>%
    filter(!is.na(aglomerado), !is.na(pondera)) %>%
    select(ano4, aglomerado, pondera, ch06, ch04)
}
#early panel (1996-2002)
eph_comp_early <- suppressWarnings(
  bind_rows(lapply(eph_files_early, function(x) clean_eph_composition_early(x$df, x$year)))
)
#late panel (2003-2025)
eph_comp_late <- bind_rows(lapply(eph_files, function(x) {
  clean_eph_composition_late(x$df, x$year, x$quarter)
}))
#population proxy from early panel
population_proxy_early <- eph_comp_early %>%
  filter(!aglomerado %in% c(38, 91)) %>%
  group_by(ano4, aglomerado) %>%
  summarise(
    total_sample = n(),
    total_weighted = sum(pondera, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  left_join(aglo_to_province, by = "aglomerado") %>%
  filter(!is.na(provincia_cod)) %>%
  left_join(province_mapping, by = "provincia_cod") %>%
  filter(!is.na(province)) %>%
  group_by(province, ano4) %>%
  summarise(
    total_sample = sum(total_sample),
    total_weighted = sum(total_weighted),
    .groups = "drop"
  ) %>%
  rename(year = ano4)
#population proxy from late panel
population_proxy_late <- eph_comp_late %>%
  filter(!aglomerado %in% c(38, 91)) %>%
  group_by(ano4, aglomerado) %>%
  summarise(
    total_sample = n(),
    total_weighted = sum(pondera, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  left_join(aglo_to_province, by = "aglomerado") %>%
  filter(!is.na(provincia_cod)) %>%
  left_join(province_mapping, by = "provincia_cod") %>%
  filter(!is.na(province)) %>%
  group_by(province, ano4) %>%
  summarise(
    total_sample = sum(total_sample),
    total_weighted = sum(total_weighted),
    .groups = "drop"
  ) %>%
  rename(year = ano4)
#population proxies
population_proxy <- bind_rows(population_proxy_early, population_proxy_late)
#year-on-year population growth
population_growth <- population_proxy %>%
  arrange(province, year) %>%
  group_by(province) %>%
  mutate(
    pop_growth_pct = (total_weighted - lag(total_weighted)) / lag(total_weighted) * 100,
    log_pop = log(total_weighted)
  ) %>%
  ungroup()
population_growth %>%
  filter(year >= 1997, year <= 2025) %>%
  group_by(year) %>%
  summarise(
    mean_growth = mean(pop_growth_pct, na.rm = TRUE),
    sd_growth = sd(pop_growth_pct, na.rm = TRUE),
    .groups = "drop"
  )

#demographic composition variables
#early panel (1996-2002)
#h12 = age, h13 = gender
composition_early <- eph_comp_early %>%
  filter(!aglomerado %in% c(38, 91)) %>%
  left_join(aglo_to_province, by = "aglomerado") %>%
  filter(!is.na(provincia_cod)) %>%
  left_join(province_mapping, by = "provincia_cod") %>%
  filter(!is.na(province)) %>%
  group_by(province, ano4) %>%
  summarise(
    mean_age       = weighted.mean(h12, pondera, na.rm = TRUE),
    pct_young      = sum(pondera[h12 >= 14 & h12 <= 29], na.rm = TRUE) /
      sum(pondera, na.rm = TRUE) * 100,
    pct_prime      = sum(pondera[h12 >= 30 & h12 <= 49], na.rm = TRUE) /
      sum(pondera, na.rm = TRUE) * 100,
    pct_older      = sum(pondera[h12 >= 50 & h12 <= 64], na.rm = TRUE) /
      sum(pondera, na.rm = TRUE) * 100,
    pct_female     = sum(pondera[h13 == 2], na.rm = TRUE) /
      sum(pondera, na.rm = TRUE) * 100,
    pct_young_female = sum(pondera[h13 == 2 & h12 >= 14 & h12 <= 29], na.rm = TRUE) /
      sum(pondera[h13 == 2], na.rm = TRUE) * 100,
    pct_prime_female = sum(pondera[h13 == 2 & h12 >= 30 & h12 <= 49], na.rm = TRUE) /
      sum(pondera[h13 == 2], na.rm = TRUE) * 100,
    pct_older_female = sum(pondera[h13 == 2 & h12 >= 50 & h12 <= 64], na.rm = TRUE) /
      sum(pondera[h13 == 2], na.rm = TRUE) * 100,
    mean_age_female  = weighted.mean(h12[h13 == 2], pondera[h13 == 2], na.rm = TRUE),
    pct_young_male   = sum(pondera[h13 == 1 & h12 >= 14 & h12 <= 29], na.rm = TRUE) /
      sum(pondera[h13 == 1], na.rm = TRUE) * 100,
    pct_prime_male   = sum(pondera[h13 == 1 & h12 >= 30 & h12 <= 49], na.rm = TRUE) /
      sum(pondera[h13 == 1], na.rm = TRUE) * 100,
    pct_older_male   = sum(pondera[h13 == 1 & h12 >= 50 & h12 <= 64], na.rm = TRUE) /
      sum(pondera[h13 == 1], na.rm = TRUE) * 100,
    mean_age_male    = weighted.mean(h12[h13 == 1], pondera[h13 == 1], na.rm = TRUE),
    .groups = "drop"
  ) %>%
  rename(year = ano4)

#late panel (2003-2025)
#ch06 = age, ch04 = gender
composition_late <- eph_comp_late %>%
  filter(!aglomerado %in% c(38, 91)) %>%
  left_join(aglo_to_province, by = "aglomerado") %>%
  filter(!is.na(provincia_cod)) %>%
  left_join(province_mapping, by = "provincia_cod") %>%
  filter(!is.na(province)) %>%
  group_by(province, ano4) %>%
  summarise(
    mean_age       = weighted.mean(ch06, pondera, na.rm = TRUE),
    pct_young      = sum(pondera[ch06 >= 14 & ch06 <= 29], na.rm = TRUE) /
      sum(pondera, na.rm = TRUE) * 100,
    pct_prime      = sum(pondera[ch06 >= 30 & ch06 <= 49], na.rm = TRUE) /
      sum(pondera, na.rm = TRUE) * 100,
    pct_older      = sum(pondera[ch06 >= 50 & ch06 <= 64], na.rm = TRUE) /
      sum(pondera, na.rm = TRUE) * 100,
    pct_female     = sum(pondera[ch04 == 2], na.rm = TRUE) /
      sum(pondera, na.rm = TRUE) * 100,
    pct_young_female = sum(pondera[ch04 == 2 & ch06 >= 14 & ch06 <= 29], na.rm = TRUE) /
      sum(pondera[ch04 == 2], na.rm = TRUE) * 100,
    pct_prime_female = sum(pondera[ch04 == 2 & ch06 >= 30 & ch06 <= 49], na.rm = TRUE) /
      sum(pondera[ch04 == 2], na.rm = TRUE) * 100,
    pct_older_female = sum(pondera[ch04 == 2 & ch06 >= 50 & ch06 <= 64], na.rm = TRUE) /
      sum(pondera[ch04 == 2], na.rm = TRUE) * 100,
    mean_age_female  = weighted.mean(ch06[ch04 == 2], pondera[ch04 == 2], na.rm = TRUE),
    pct_young_male   = sum(pondera[ch04 == 1 & ch06 >= 14 & ch06 <= 29], na.rm = TRUE) /
      sum(pondera[ch04 == 1], na.rm = TRUE) * 100,
    pct_prime_male   = sum(pondera[ch04 == 1 & ch06 >= 30 & ch06 <= 49], na.rm = TRUE) /
      sum(pondera[ch04 == 1], na.rm = TRUE) * 100,
    pct_older_male   = sum(pondera[ch04 == 1 & ch06 >= 50 & ch06 <= 64], na.rm = TRUE) /
      sum(pondera[ch04 == 1], na.rm = TRUE) * 100,
    mean_age_male    = weighted.mean(ch06[ch04 == 1], pondera[ch04 == 1], na.rm = TRUE),
    .groups = "drop"
  ) %>%
  rename(year = ano4)
#combine both panels
composition <- bind_rows(composition_early, composition_late)

#merge with treatment panel
migration_panel <- treatment_panel %>%
  filter(year >= 1996) %>%
  left_join(population_growth, by = c("province", "year")) %>%
  left_join(composition, by = c("province", "year")) %>%
  left_join(
    eph_panel_prov_full %>%
      select(province, year, unemp_rate, emp_rate, lfp_rate, housewife_rate),
    by = c("province", "year")
  ) %>%
  filter(!is.na(province))

#regressions for high quota implementation on demographic variables
run_composition_models <- function(data) {
  outcomes <- c(
    "log_pop", "pop_growth_pct",
    "mean_age", "pct_young", "pct_prime", "pct_older", "pct_female",
    "mean_age_female", "pct_young_female", "pct_prime_female", "pct_older_female",
    "mean_age_male", "pct_young_male", "pct_prime_male", "pct_older_male"
  )
  results <- lapply(outcomes, function(outcome) {
    feols(
      as.formula(paste0(outcome, " ~ high_quota_implement | province + year")),
      data    = data %>% filter(!is.na(!!sym(outcome))),
      cluster = ~province
    )
  })
  names(results) <- outcomes
  return(results)
}
composition_results <- run_composition_models(migration_panel)
lapply(names(composition_results), function(x) {
  print(summary(composition_results[[x]]))
})
#all statistically insignificant

#occupational upgrading test: white-collar share
#CNO occupation code:
#Digit 1 = type of work:
#0 Management/government     5 Other services (arts, food, domestic...)
#1 Administrative/legal      6 Agriculture, forestry, fishing
#2 Accounting/finance        7 Extraction, energy, construction
#3 Commerce/transport        8 Manufacturing, crafts, repair
#4 Basic social services     9 Auxiliary production (health, education, military, police)
#Digit 5 = skill level: 1 Professional, 2 Technical, 3 Operational, 4 Unskilled
#white-collar:
#type in {0,1,2} (management, admin, finance)
#type in {3,4,5} and skill in {1,2} (professional/technical services & commerce)
#blue-collar:
#type in {6,7,8,9} (agriculture, construction, industry, auxiliary)
#type in {3,4,5} and skill in {3,4} (operational/unskilled services)

#extract digits from early 3-digit CNO code (1996-2002)
#digit 1 = caracter, digit 3 = calificacion  
extract_cno_early <- function(x) {
  x_chr <- iconv(as.character(x), from = "latin1", to = "UTF-8", sub = "")
  x_chr <- trimws(x_chr)
  x_int <- suppressWarnings(as.integer(x_chr))
  s     <- formatC(x_int, width = 3, flag = "0", format = "d")
  s[is.na(x_int)] <- NA_character_
  tibble(
    cno_code     = x_int,
    caracter     = suppressWarnings(as.integer(substr(s, 1, 1))),
    calificacion = suppressWarnings(as.integer(substr(s, 3, 3)))
  )
}

#extract 1st and 5th digit 
extract_cno <- function(x) {
  x_chr <- iconv(as.character(x), from = "latin1", to = "UTF-8", sub = "")
  x_int <- suppressWarnings(as.integer(x_chr))
  s     <- formatC(x_int, width = 5, flag = "0", format = "d")
  s[is.na(x_int)] <- NA_character_
  tibble(
    cno_code     = x_int,
    caracter     = suppressWarnings(as.integer(substr(s, 1, 1))),
    calificacion = suppressWarnings(as.integer(substr(s, 5, 5)))
  )
}
#white-collar/blue-collar classification 
classify_collar <- function(caracter, calificacion) {
  case_when(
    is.na(caracter) ~ NA_character_,
    #always white-collar: direction, administration, finance
    caracter %in% c(0, 1, 2) ~ "White_Collar",
    #conditional white-collar: services/commerce only if professional/technical
    caracter %in% c(3, 4, 5) & calificacion %in% c(1, 2) ~ "White_Collar",
    #everything else is blue-collar (manual or low-complexity service)
    TRUE ~ "Blue_Collar"
  )
}

#occupational data: early panel (1996-2002)
clean_eph_sector_early <- function(df) {
  df <- df %>%
    rename_with(tolower) %>%
    select(-aglomerado) %>%
    rename(aglomerado = agloreal) %>%
    mutate(
      ch04       = as.integer(h13),
      birth_year = as.integer(format(as.Date(h11), "%Y")),
      ch06       = as.integer(ano4) - birth_year,
      ano4       = as.integer(ano4),
      aglomerado = as.integer(aglomerado),
      pondera    = as.numeric(pondera),
      estado     = as.integer(estado)
    )
  cno <- extract_cno_early(df$p20)        
  df$caracter     <- cno$caracter
  df$calificacion <- cno$calificacion
  df$collar       <- classify_collar(df$caracter, df$calificacion)
  df %>%
    filter(ch06 >= 14, estado != 0) %>%
    filter(!is.na(aglomerado), !is.na(pondera)) %>%
    dplyr::select(ano4, aglomerado, pondera, estado, ch04,
                  caracter, calificacion, collar)
}

#occupational data: late panel (2003-2025)
clean_eph_sector_late <- function(df, year, quarter = 2) {
  df <- df %>%
    mutate(across(where(is.labelled), as.numeric)) %>%
    rename_with(tolower) %>%
    filter(ch06 >= 14, estado != 0) %>%
    mutate(
      ano4       = as.integer(year),
      aglomerado = as.integer(aglomerado),
      pondera    = as.numeric(pondera),
      estado     = as.integer(estado),
      ch04       = as.integer(ch04)
    )
  cno <- extract_cno(df$pp04d_cod)
  df$caracter     <- cno$caracter
  df$calificacion <- cno$calificacion
  df$collar       <- classify_collar(df$caracter, df$calificacion)
  df %>%
    filter(!is.na(aglomerado), !is.na(pondera)) %>%
    dplyr::select(ano4, aglomerado, pondera, estado, ch04,
                  caracter, calificacion, collar)
}

#sector panels
eph_sector_early <- suppressWarnings(
  bind_rows(lapply(eph_files_early, function(x) clean_eph_sector_early(x$df)))
)
eph_sector_late <- bind_rows(lapply(eph_files, function(x) {
  clean_eph_sector_late(x$df, x$year, x$quarter)
}))
eph_sector_full <- bind_rows(eph_sector_early, eph_sector_late)

#only observations with a valid collar classification
eph_sector_collar <- eph_sector_full %>% filter(!is.na(collar))

#compute white-collar share by gender 
compute_white_collar <- function(data, gender_filter = NULL) {
  if (!is.null(gender_filter)) {
    data <- data %>% filter(ch04 == gender_filter)
  }
  data %>%
    filter(!aglomerado %in% c(38, 91), estado == 1) %>%
    left_join(aglo_to_province, by = "aglomerado") %>%
    filter(!is.na(provincia_cod)) %>%
    left_join(province_mapping, by = "provincia_cod") %>%
    filter(!is.na(province)) %>%
    group_by(province, ano4) %>%
    summarise(
      white_collar_emp   = sum(pondera[collar == "White_Collar"], na.rm = TRUE),
      total_emp          = sum(pondera, na.rm = TRUE),
      white_collar_share = white_collar_emp / total_emp * 100,
      .groups = "drop"
    ) %>%
    select(province, ano4, white_collar_share) %>%
    rename(year = ano4)
}
white_collar_overall <- compute_white_collar(eph_sector_collar)
white_collar_female  <- compute_white_collar(eph_sector_collar, gender_filter = 2)
white_collar_male    <- compute_white_collar(eph_sector_collar, gender_filter = 1)

white_collar_overall %>%
  group_by(year) %>%
  summarise(mean_white = mean(white_collar_share, na.rm = TRUE), .groups = "drop") %>%
  
bind_cols(
  white_collar_female %>% filter(year == 2025) %>%
    summarise(female = mean(white_collar_share, na.rm = TRUE)),
  white_collar_male %>% filter(year == 2025) %>%
    summarise(male = mean(white_collar_share, na.rm = TRUE))
) %>% print()
#share of female white-collar workers: 42%, share of male white-collar workers: 28%

#distribution of code
eph_sector_collar %>%
  dplyr::count(caracter) %>%
  mutate(pct = round(100 * n / sum(n), 2)) %>%
  print()
#highest share of workers in commerce and transport, lowest share of workers in agriculture 

#merge with treatment panel
collar_panel <- treatment_panel %>%
  filter(year >= 1996) %>%
  left_join(white_collar_overall %>% rename(pct_white_overall = white_collar_share),
            by = c("province", "year")) %>%
  left_join(white_collar_female  %>% rename(pct_white_female  = white_collar_share),
            by = c("province", "year")) %>%
  left_join(white_collar_male    %>% rename(pct_white_male    = white_collar_share),
            by = c("province", "year")) %>%
  filter(!is.na(province))
collar_panel %>%
  summarise(
    n               = n(),
    n_provinces     = n_distinct(province),
    years           = paste(min(year), max(year), sep = "-"),
    n_white_overall = sum(!is.na(pct_white_overall)),
    n_white_female  = sum(!is.na(pct_white_female)),
    n_white_male    = sum(!is.na(pct_white_male))
  )

#regressions: high quota implementation on white-collar share 
#overall
quota_white_overall <- feols(
  pct_white_overall ~ high_quota_implement | province + year,
  data    = collar_panel %>% filter(!is.na(pct_white_overall)),
  cluster = ~province
)
summary(quota_white_overall)
#with the implementation of a high quota, overall white-collar share increases by 0.99 pp, not statistically significant 

#female
quota_white_female <- feols(
  pct_white_female ~ high_quota_implement | province + year,
  data    = collar_panel %>% filter(!is.na(pct_white_female)),
  cluster = ~province
)
summary(quota_white_female)
#with the implementation of a high quota, female white-collar share increases by 1.29 pp, not statistically significant 

#male
quota_white_male <- feols(
  pct_white_male ~ high_quota_implement | province + year,
  data    = collar_panel %>% filter(!is.na(pct_white_male)),
  cluster = ~province
)
summary(quota_white_male)
#with the implementation of a high quota, male white-collar share increases by 0.73 pp, not statistically significant 

#male and overall labour market outcomes
#early panel (1996-2002): overall unemployment
clean_eph_early_overall <- function(df) {
  df %>%
    rename_with(tolower) %>%
    select(-aglomerado) %>%
    rename(aglomerado = agloreal) %>%
    mutate(
      ch04       = as.integer(h13), #gender: 1=male, 2=female
      birth_year = as.integer(format(as.Date(h11), "%Y")),
      ch06       = as.integer(ano4) - birth_year,
      ano4       = as.integer(ano4),
      aglomerado = as.integer(aglomerado),
      pondera    = as.numeric(pondera),
      estado     = as.integer(estado) #1=employed, 2=unemployed, 3=inactive, 0=unknown
    ) %>%
    filter(
      ch06 >= 14, #age 14+
      estado != 0
    ) %>%
    filter(!is.na(aglomerado), !is.na(pondera)) %>%
    dplyr::select(ano4, aglomerado, pondera, estado, ch04)
}
#late panel (2003-2025): overall unemployment
clean_eph_overall <- function(df, year, quarter = 2) {
  df %>%
    mutate(across(where(is.labelled), as.numeric)) %>%
    rename_with(tolower) %>%
    filter(
      ch06 >= 14,
      estado != 0
    ) %>%
    mutate(
      ano4         = as.integer(year),
      quarter      = quarter,
      aglomerado   = as.integer(aglomerado),
      pondera      = as.numeric(pondera),
      estado       = as.integer(estado),
      ch04         = as.integer(ch04) #gender
    ) %>%
    filter(!is.na(aglomerado), !is.na(pondera)) %>%
    dplyr::select(ano4, aglomerado, pondera, estado, ch04)
}
#overall unemployment panel (men + women)
#early panel (1996-2002)
eph_panel_early_overall <- suppressWarnings(
  bind_rows(lapply(eph_files_early, function(x) clean_eph_early_overall(x$df)))
)
#late panel (2003-2025)
eph_panel_overall <- bind_rows(lapply(eph_files, function(x) {
  clean_eph_overall(x$df, x$year, x$quarter)
}))
#early and late panels
eph_panel_full_overall <- bind_rows(
  eph_panel_early_overall,
  eph_panel_overall
)

#aggregate to province-year level
#overall unemployment (men + women together)
eph_panel_prov_overall <- eph_panel_full_overall %>%
  filter(!aglomerado %in% c(38, 91)) %>%
  left_join(aglo_to_province, by = "aglomerado") %>%
  filter(!is.na(provincia_cod)) %>%
  left_join(province_mapping, by = "provincia_cod") %>%
  filter(!is.na(province)) %>%
  group_by(province, ano4) %>%
  summarise(
    #overall rates (both genders)
    unemp_rate_overall = sum(pondera[estado == 2], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2)], na.rm = TRUE) * 100,
    emp_rate_overall = sum(pondera[estado == 1], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2, 3)], na.rm = TRUE) * 100,
    lfp_rate_overall = sum(pondera[estado %in% c(1, 2)], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2, 3)], na.rm = TRUE) * 100,
    #male-only rates
    unemp_rate_male = sum(pondera[estado == 2 & ch04 == 1], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2) & ch04 == 1], na.rm = TRUE) * 100,
    emp_rate_male = sum(pondera[estado == 1 & ch04 == 1], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2, 3) & ch04 == 1], na.rm = TRUE) * 100,
    lfp_rate_male = sum(pondera[estado %in% c(1, 2) & ch04 == 1], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2, 3) & ch04 == 1], na.rm = TRUE) * 100,
    #female-only rates
    unemp_rate_female = sum(pondera[estado == 2 & ch04 == 2], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2) & ch04 == 2], na.rm = TRUE) * 100,
    emp_rate_female = sum(pondera[estado == 1 & ch04 == 2], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2, 3) & ch04 == 2], na.rm = TRUE) * 100,
    lfp_rate_female = sum(pondera[estado %in% c(1, 2) & ch04 == 2], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2, 3) & ch04 == 2], na.rm = TRUE) * 100,
    .groups = "drop"
  ) %>%
  rename(year = ano4)
#summary 
eph_panel_prov_overall %>%
  group_by(year) %>%
  summarise(
    mean_unemp_female = round(mean(unemp_rate_female, na.rm = TRUE), 2),
    mean_unemp_male = round(mean(unemp_rate_male, na.rm = TRUE), 2),
    mean_unemp_overall = round(mean(unemp_rate_overall, na.rm = TRUE), 2),
    .groups = "drop"
  ) %>%
  print(n = 30)
#female unemployment rate is always slightly higher than male unemployment rate throughout the panel

#merge with treatment panel
second_stage_high_extended <- treatment_panel %>%
  filter(year >= 1996) %>%
  left_join(eph_panel_prov_overall, by = c("province", "year")) %>%
  filter(!is.na(province))
#coverage check
second_stage_high_extended %>%
  summarise(
    n           = n(),
    n_provinces = n_distinct(province),
    years       = paste(min(year), max(year), sep = "-"),
    n_unemp_overall = sum(!is.na(unemp_rate_overall)),
    n_unemp_male    = sum(!is.na(unemp_rate_male))
  ) %>%
  print()
#11 missing data entries due to Rio Negro

#regressions: high quota implementation on overall labour market outcomes
#overall unemployment rate
twfe_high_unemp_overall <- feols(
  unemp_rate_overall ~ high_quota_implement | province + year,
  data    = second_stage_high_extended %>%
    filter(!is.na(unemp_rate_overall)),
  cluster = ~province
)
summary(twfe_high_unemp_overall)
#with the implementation of a high quota, overall unemployment rate increases by 1.13 pp, statistically significant at the 10% level

#overall employment rate
twfe_high_emp_overall <- feols(
  emp_rate_overall ~ high_quota_implement | province + year,
  data    = second_stage_high_extended %>%
    filter(!is.na(emp_rate_overall)),
  cluster = ~province
)
summary(twfe_high_emp_overall)
#with the implementation of a high quota, overall employment rate increases by 0.87 pp, not statistically significant 

#overall lfp rate
twfe_high_lfp_overall <- feols(
  lfp_rate_overall ~ high_quota_implement | province + year,
  data    = second_stage_high_extended %>%
    filter(!is.na(lfp_rate_overall)),
  cluster = ~province
)
summary(twfe_high_lfp_overall)
#with the implementation of a high quota, overall lfp rate increases by 1.60 pp, statistically significant at the 10% level

#regressions: high quota implementation on male labour market outcomes
#male unemployment rate
twfe_high_unemp_male <- feols(
  unemp_rate_male ~ high_quota_implement | province + year,
  data    = second_stage_high_extended %>%
    filter(!is.na(unemp_rate_male)),
  cluster = ~province
)
summary(twfe_high_unemp_male)
#with the implementation of a high quota, male unemployment rate increases by 1.12 pp, statistically significant at the 10% level

#male employment rate
twfe_high_emp_male <- feols(
  emp_rate_male ~ high_quota_implement | province + year,
  data    = second_stage_high_extended %>%
    filter(!is.na(emp_rate_male)),
  cluster = ~province
)
summary(twfe_high_emp_male)
#with the implementation of a high quota, male employment rate increases by 1.03 pp, not statistically significant

#male lfp rate
twfe_high_lfp_male <- feols(
  lfp_rate_male ~ high_quota_implement | province + year,
  data    = second_stage_high_extended %>%
    filter(!is.na(lfp_rate_male)),
  cluster = ~province
)
summary(twfe_high_lfp_male)
#with the implementation of a high quota, male lfp rate increases by 1.91 pp, statistically significant at the 10% level

#regressions: high quota implementation on male labour market outcomes (Rio Negro excluded)
#male unemployment rate
twfe_high_unemp_male_no_rn <- feols(
  unemp_rate_male ~ high_quota_implement | province + year,
  data    = second_stage_high_extended %>%
    filter(!is.na(unemp_rate_male), !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(twfe_high_unemp_male_no_rn)
#with the implementation of a high quota, male unemployment rate increases by 0.88 pp, not statistically significant

#male employment rate 
twfe_high_emp_male_no_rn <- feols(
  emp_rate_male ~ high_quota_implement | province + year,
  data    = second_stage_high_extended %>%
    filter(!is.na(emp_rate_male), !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(twfe_high_emp_male_no_rn)
#with the implementation of a high quota, male employment rate increases by 0.65 pp, not statistically significant

#male lfp rate 
twfe_high_lfp_male_no_rn <- feols(
  lfp_rate_male ~ high_quota_implement | province + year,
  data    = second_stage_high_extended %>%
    filter(!is.na(lfp_rate_male), !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(twfe_high_lfp_male_no_rn)
#with the implementation of a high quota, male lfp rate increases by 1.38 pp, not statistically significant

#male housewife rate
#early panel (1996-2002)
clean_eph_early_hw_male <- function(df) {
  df %>%
    rename_with(tolower) %>%
    select(-aglomerado) %>%
    rename(aglomerado = agloreal) %>%
    mutate(
      ch04       = as.integer(h13),                       #1=male, 2=female
      birth_year = as.integer(format(as.Date(h11), "%Y")),
      ch06       = as.integer(ano4) - birth_year,
      ano4       = as.integer(ano4),
      aglomerado = as.integer(aglomerado),
      pondera    = as.numeric(pondera),
      estado     = as.integer(estado),
      housewife  = as.integer(p11) == 4                   
    ) %>%
    filter(ch06 >= 14, estado != 0) %>%
    filter(!is.na(aglomerado), !is.na(pondera)) %>%
    dplyr::select(ano4, aglomerado, pondera, estado, ch04, housewife)
}

#late panel (2003-2025)
clean_eph_hw_male <- function(df, year, quarter = 2) {
  df %>%
    mutate(across(where(is.labelled), as.numeric)) %>%
    rename_with(tolower) %>%
    filter(ch06 >= 14, estado != 0) %>%
    mutate(
      ano4       = as.integer(year),
      quarter    = quarter,
      aglomerado = as.integer(aglomerado),
      pondera    = as.numeric(pondera),
      estado     = as.integer(estado),
      ch04       = as.integer(ch04),
      housewife  = as.integer(cat_inac) == 4              
    ) %>%
    filter(!is.na(aglomerado), !is.na(pondera)) %>%
    dplyr::select(ano4, aglomerado, pondera, estado, ch04, housewife)
}

#panels
eph_panel_early_hw_male <- suppressWarnings(
  bind_rows(lapply(eph_files_early, function(x) clean_eph_early_hw_male(x$df)))
)
eph_panel_hw_male <- bind_rows(lapply(eph_files, function(x) {
  clean_eph_hw_male(x$df, x$year, x$quarter)
}))
eph_panel_full_hw_male <- bind_rows(eph_panel_early_hw_male, eph_panel_hw_male)

#aggregate to province-year
eph_panel_prov_hw_male <- eph_panel_full_hw_male %>%
  filter(!aglomerado %in% c(38, 91)) %>%
  left_join(aglo_to_province, by = "aglomerado") %>%
  filter(!is.na(provincia_cod)) %>%
  left_join(province_mapping, by = "provincia_cod") %>%
  filter(!is.na(province)) %>%
  group_by(province, ano4) %>%
  summarise(
    housewife_rate_male = sum(pondera[housewife & ch04 == 1], na.rm = TRUE) /
      sum(pondera[ch04 == 1], na.rm = TRUE) * 100,
    n_hw_male_raw = sum(housewife & ch04 == 1, na.rm = TRUE),   #unweighted count
    n_male_raw    = sum(ch04 == 1, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  rename(year = ano4)

#time series: weighted national male housewife rate 
male_hw_timeseries <- eph_panel_full_hw_male %>%
  filter(!aglomerado %in% c(38, 91)) %>%
  group_by(ano4) %>%
  summarise(
    housewife_rate_male = sum(pondera[housewife & ch04 == 1], na.rm = TRUE) /
      sum(pondera[ch04 == 1], na.rm = TRUE) * 100,
    n_hw_male_raw = sum(housewife & ch04 == 1, na.rm = TRUE),
    n_male_raw    = sum(ch04 == 1, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  rename(year = ano4) %>%
  arrange(year)
print(male_hw_timeseries, n = 40)
#housewife rate for men remains very low across all years

#merge with treatment panel
second_stage_high_hw_male <- treatment_panel %>%
  filter(year >= 1996) %>%
  left_join(eph_panel_prov_hw_male, by = c("province", "year")) %>%
  filter(!is.na(province))

#coverage 
second_stage_high_hw_male %>%
  summarise(
    n                = n(),
    n_provinces      = n_distinct(province),
    years            = paste(min(year), max(year), sep = "-"),
    total_hw_male    = sum(n_hw_male_raw, na.rm = TRUE),
    cells_with_hw    = sum(n_hw_male_raw > 0, na.rm = TRUE),
    cells_total      = sum(!is.na(housewife_rate_male))
  ) %>%
  print()
#11 missing observations from Rio Negro

#all provinces
#regression: high quota implementation on housewife rate for men
twfe_high_hw_male <- feols(
  housewife_rate_male ~ high_quota_implement | province + year,
  data    = second_stage_high_hw_male %>% filter(!is.na(housewife_rate_male)),
  cluster = ~province
)
summary(twfe_high_hw_male)
#with the implementation of a high quota, men's housewife rate increases by 0.03 pp, not statistically significant

#regression: high quota implementation on housewife rate for men (Rio Negro excluded)
twfe_high_hw_male_no_rn <- feols(
  housewife_rate_male ~ high_quota_implement | province + year,
  data    = second_stage_high_hw_male %>%
    filter(!is.na(housewife_rate_male), !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(twfe_high_hw_male_no_rn)
#with the implementation of a high quota, men's housewife rate decreases by 0.002 pp, not statistically significant            
            
#marital status analysis
#early EPH data (1996-2002)
clean_eph_early_marital <- function(df) {
  df %>%
    rename_with(tolower) %>%
    select(-aglomerado) %>%
    rename(aglomerado = agloreal) %>%
    mutate(
      ch04       = as.integer(h13), #gender: 1=male, 2=female
      birth_year = as.integer(format(as.Date(h11), "%Y")),
      age        = as.integer(ano4) - birth_year,
      ano4       = as.integer(ano4),
      aglomerado = as.integer(aglomerado),
      pondera    = as.numeric(pondera),
      estado     = as.integer(estado),
      p11        = suppressWarnings(as.integer(p11)),
      #marital status (early coding, H14):
      #1=single, 2=partnered, 3=married, 4=separated/divorced, 5=widowed
      marital_raw = suppressWarnings(as.integer(h14)),
      married_partnered = case_when(
        marital_raw %in% c(2, 3) ~ 1,   #partnered or married
        marital_raw == 1         ~ 0,   #single
        TRUE                     ~ NA_real_
      ),
      single = case_when(
        marital_raw == 1         ~ 1,   #single
        marital_raw %in% c(2, 3) ~ 0,   #partnered or married
        TRUE                     ~ NA_real_
      ),
      housewife = case_when(
        estado == 3 & p11 == 4 ~ 1,  #inactive and housewife
        estado == 3 & p11 != 4 ~ 0,  #inactive but not housewife
        estado != 3            ~ 0,  #employed or unemployed
        TRUE                   ~ NA_real_
      )
    ) %>%
    filter(
      ch04 == 2, #female only
      age  >= 14,
      estado != 0,
      !is.na(aglomerado), !is.na(pondera)
    ) %>%
    dplyr::select(ano4, aglomerado, pondera, estado, housewife,
                  married_partnered, single, age)
}

#late EPH data (2003-2025)
clean_eph_marital <- function(df, year, quarter = 2) {
  df %>%
    mutate(across(where(is.labelled), as.numeric)) %>%
    rename_with(tolower) %>%
    filter(
      ch06 >= 14,
      estado != 0
    ) %>%
    mutate(
      ano4       = as.integer(year),
      quarter    = quarter,
      aglomerado = as.integer(aglomerado),
      pondera    = as.numeric(pondera),
      estado     = as.integer(estado),
      ch04       = as.integer(ch04), #gender: 1=male, 2=female
      age        = as.integer(ch06),
      #marital status (2003-2025 coding, CH07):
      #1=partnered, 2=married, 3=separated/divorced, 4=widowed, 5=single
      marital_raw = suppressWarnings(as.integer(ch07)),
      married_partnered = case_when(
        marital_raw %in% c(1, 2) ~ 1,   #partnered or married
        marital_raw == 5         ~ 0,   #single
        TRUE                     ~ NA_real_
      ),
      single = case_when(
        marital_raw == 5         ~ 1,   #single
        marital_raw %in% c(1, 2) ~ 0,   #partnered or married
        TRUE                     ~ NA_real_
      ),
      #housewife (2003-2025: cat_inac=4 = ama de casa)
      cat_inac  = suppressWarnings(as.integer(cat_inac)),
      housewife = case_when(
        estado == 3 & cat_inac == 4 ~ 1,  #inactive and housewife
        estado == 3 & cat_inac != 4 ~ 0,  #inactive but not housewife
        estado != 3                 ~ 0,  #employed or unemployed
        TRUE                        ~ NA_real_
      )
    ) %>%
    filter(
      ch04 == 2, #female only
      !is.na(aglomerado), !is.na(pondera)
    ) %>%
    dplyr::select(ano4, aglomerado, pondera, estado, housewife,
                  married_partnered, single, age)
}

#panel by marital status 
#early panel (1996–2002)
eph_panel_early_marital <- suppressWarnings(
  bind_rows(lapply(eph_files_early, function(x) clean_eph_early_marital(x$df)))
)
#late panel (2003–2025)
eph_panel_marital <- bind_rows(lapply(eph_files, function(x) {
  clean_eph_marital(x$df, x$year, x$quarter)
}))
#combine panels
eph_panel_full_marital <- bind_rows(
  eph_panel_early_marital,
  eph_panel_marital
)

#marital status distribution 
marital_dist <- eph_panel_full_marital %>%
  mutate(
    marital_category = case_when(
      married_partnered == 1 ~ "Married/Partnered",
      single == 1            ~ "Single",
      TRUE                   ~ "Other (separated/divorced/widowed)"
    )
  ) %>%
  dplyr::count(marital_category) %>%
  mutate(pct = n / sum(n) * 100)
print(marital_dist)
#48% of women aged 14 and older are married, 35% are single, 16% are seperated, divorced or widowed

marital_by_year <- eph_panel_full_marital %>%
  mutate(
    marital_category = case_when(
      married_partnered == 1 ~ "Married/Partnered",
      single == 1            ~ "Single",
      TRUE                   ~ "Other"
    )
  ) %>%
  group_by(ano4, marital_category) %>%
  summarise(n = n(), .groups = "drop") %>%
  group_by(ano4) %>%
  mutate(pct = n / sum(n) * 100) %>%
  arrange(ano4, marital_category)
print(marital_by_year, n = 90)
#percentage of married women decreases over the years while percentage of single women increases

#age composition analysis 
age_diagnostic <- eph_panel_full_marital %>%
  summarise(
    mean_age_married = weighted.mean(age[married_partnered == 1],
                                     w = pondera[married_partnered == 1],
                                     na.rm = TRUE),
    mean_age_single  = weighted.mean(age[single == 1],
                                     w = pondera[single == 1],
                                     na.rm = TRUE)
  )
age_distribution <- eph_panel_full_marital %>%
  mutate(
    marital_status = case_when(
      married_partnered == 1 ~ "Married/Partnered",
      single == 1            ~ "Single",
      TRUE                   ~ "Other"
    )
  ) %>%
  filter(marital_status != "Other") %>%
  group_by(marital_status) %>%
  summarise(
    n            = n(),
    mean_age     = weighted.mean(age, w = pondera, na.rm = TRUE),
    pct_under_25 = sum(pondera[age < 25],            na.rm = TRUE) / sum(pondera, na.rm = TRUE) * 100,
    pct_25_44    = sum(pondera[age >= 25 & age < 45], na.rm = TRUE) / sum(pondera, na.rm = TRUE) * 100,
    pct_45_plus  = sum(pondera[age >= 45],            na.rm = TRUE) / sum(pondera, na.rm = TRUE) * 100,
    .groups = "drop"
  )
print(age_distribution)
#mean age for married women is 45%, while the mean age for single women is 28% across the years, so married women are older on average

#aggregate to province-year panel
#married women
eph_panel_prov_married <- eph_panel_full_marital %>%
  filter(married_partnered == 1, !aglomerado %in% c(38, 91)) %>%
  left_join(aglo_to_province, by = "aglomerado") %>%
  filter(!is.na(provincia_cod)) %>%
  left_join(province_mapping, by = "provincia_cod") %>%
  filter(!is.na(province)) %>%
  group_by(province, ano4) %>%
  summarise(
    unemp_rate_married = sum(pondera[estado == 2], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2)], na.rm = TRUE) * 100,
    emp_rate_married   = sum(pondera[estado == 1], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2, 3)], na.rm = TRUE) * 100,
    lfp_rate_married   = sum(pondera[estado %in% c(1, 2)], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2, 3)], na.rm = TRUE) * 100,
    housewife_rate_married = sum(pondera[housewife == 1], na.rm = TRUE) /
      sum(pondera, na.rm = TRUE) * 100,
    .groups = "drop"
  ) %>%
  rename(year = ano4)

#single women
eph_panel_prov_single <- eph_panel_full_marital %>%
  filter(single == 1, !aglomerado %in% c(38, 91)) %>%
  left_join(aglo_to_province, by = "aglomerado") %>%
  filter(!is.na(provincia_cod)) %>%
  left_join(province_mapping, by = "provincia_cod") %>%
  filter(!is.na(province)) %>%
  group_by(province, ano4) %>%
  summarise(
    unemp_rate_single = sum(pondera[estado == 2], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2)], na.rm = TRUE) * 100,
    emp_rate_single   = sum(pondera[estado == 1], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2, 3)], na.rm = TRUE) * 100,
    lfp_rate_single   = sum(pondera[estado %in% c(1, 2)], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2, 3)], na.rm = TRUE) * 100,
    housewife_rate_single = sum(pondera[housewife == 1], na.rm = TRUE) /
      sum(pondera, na.rm = TRUE) * 100,
    .groups = "drop"
  ) %>%
  rename(year = ano4)

#province-year level summary for married women
eph_panel_prov_married %>%
  group_by(year) %>%
  summarise(
    mean_unemp     = round(mean(unemp_rate_married,     na.rm = TRUE), 2),
    mean_lfp       = round(mean(lfp_rate_married,       na.rm = TRUE), 2),
    mean_housewife = round(mean(housewife_rate_married, na.rm = TRUE), 2),
    .groups = "drop"
  ) %>%
  print(n = 30)
#married women have high housewife rates, low unemployment and high lfp rates across the years
#housewife rate decreases largely, unemployment rate also decreases while lfp increases over the years

#province-year level summary for single women
eph_panel_prov_single %>%
  group_by(year) %>%
  summarise(
    mean_unemp     = round(mean(unemp_rate_single,     na.rm = TRUE), 2),
    mean_lfp       = round(mean(lfp_rate_single,       na.rm = TRUE), 2),
    mean_housewife = round(mean(housewife_rate_single, na.rm = TRUE), 2),
    .groups = "drop"
  ) %>%
  print(n = 30)
#single women have low housewife rates, high unemployment and low lfp rates across the years
#housewife rate remains relatively constant, while lfp rate increases and unemployment rate decreases over the years

#merge with treatment panel 
second_stage_marital <- treatment_panel %>%
  filter(year >= 1996) %>%
  left_join(eph_panel_prov_married, by = c("province", "year")) %>%
  left_join(eph_panel_prov_single,  by = c("province", "year")) %>%
  filter(!is.na(province))
second_stage_marital %>%
  summarise(
    n           = n(),
    n_provinces = n_distinct(province),
    years       = paste(min(year), max(year), sep = "-"),
    n_married   = sum(!is.na(unemp_rate_married)),
    n_single    = sum(!is.na(unemp_rate_single))
  ) %>%
  print()
#11 missing observations from Rio Negro

#regressions: high quota implementation on partnered/married women's labour market outcomes 
#married women's unemployment rate
twfe_married_unemp <- feols(
  unemp_rate_married ~ high_quota_implement | province + year,
  data = second_stage_marital %>% filter(!is.na(unemp_rate_married)),
  cluster = ~province
)
summary(twfe_married_unemp)
#with the implementation of a high quota, married women's unemployment rate increases by 0.81 pp, not statistically significant

#married women's employment rate
twfe_married_emp <- feols(
  emp_rate_married ~ high_quota_implement | province + year,
  data = second_stage_marital %>% filter(!is.na(emp_rate_married)),
  cluster = ~province
)
summary(twfe_married_emp)
#with the implementation of a high quota, married women's employment rate increases by 1.48 pp, not statistically significant

#married women's lfp rate
twfe_married_lfp <- feols(
  lfp_rate_married ~ high_quota_implement | province + year,
  data = second_stage_marital %>% filter(!is.na(lfp_rate_married)),
  cluster = ~province
)
summary(twfe_married_lfp)
#with the implementation of a high quota, married women's lfp rate increases by 1.97 pp, not statistically significant

#married women's housewife rate
twfe_married_housewife <- feols(
  housewife_rate_married ~ high_quota_implement | province + year,
  data = second_stage_marital %>% filter(!is.na(housewife_rate_married)),
  cluster = ~province
)
summary(twfe_married_housewife)
#with the implementation of a high quota, married women's housewife decreases by 2.39 pp, statistically significant at the 5% level

#regressions: high quota implementation on single women's labour market outcomes
#single women's unemployment
twfe_single_unemp <- feols(
  unemp_rate_single ~ high_quota_implement | province + year,
  data = second_stage_marital %>% filter(!is.na(unemp_rate_single)),
  cluster = ~province
)
summary(twfe_single_unemp)
#with the implementation of a high quota, single women's unemployment rate increases by 2.10 pp, statistically significant at the 5% level

#single women's employment rate
twfe_single_emp <- feols(
  emp_rate_single ~ high_quota_implement | province + year,
  data = second_stage_marital %>% filter(!is.na(emp_rate_single)),
  cluster = ~province
)
summary(twfe_single_emp)
#with the implementation of a high quota, single women's employment rate decreases by 0.42 pp, not statistically significant 

#single women's lfp rate
twfe_single_lfp <- feols(
  lfp_rate_single ~ high_quota_implement | province + year,
  data = second_stage_marital %>% filter(!is.na(lfp_rate_single)),
  cluster = ~province
)
summary(twfe_single_lfp)
#with the implementation of a high quota, single women's lfp rate increases by 0.36 pp, not statistically significant 

#single women's housewife rate
twfe_single_housewife <- feols(
  housewife_rate_single ~ high_quota_implement | province + year,
  data = second_stage_marital %>% filter(!is.na(housewife_rate_single)),
  cluster = ~province
)
summary(twfe_single_housewife)
#with the implementation of a high quota, single women's housewife decreases by 0.07 pp, not statistically significant 

#regressions: high quota implementation on partnered/married women's labour market outcomes (Rio Negro excluded)
#married women's unemployment rate
twfe_married_unemp_no_rn <- feols(
  unemp_rate_married ~ high_quota_implement | province + year,
  data = second_stage_marital %>%
    filter(!is.na(unemp_rate_married), !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(twfe_married_unemp_no_rn)
#with the implementation of a high quota, married women's unemployment rate increases by 0.64 pp, not statistically significant 

#married women's employment rate
twfe_married_emp_no_rn <- feols(
  emp_rate_married ~ high_quota_implement | province + year,
  data = second_stage_marital %>%
    filter(!is.na(emp_rate_married), !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(twfe_married_emp_no_rn)
#with the implementation of a high quota, married women's employment rate increases by 0.64 pp, not statistically significant 

#married women's lfp rate
twfe_married_lfp_no_rn <- feols(
  lfp_rate_married ~ high_quota_implement | province + year,
  data = second_stage_marital %>%
    filter(!is.na(lfp_rate_married), !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(twfe_married_lfp_no_rn)
#with the implementation of a high quota, married women's lfp rate increases by 1.38 pp, not statistically significant 

#married women's housewife rate
twfe_married_housewife_no_rn <- feols(
  housewife_rate_married ~ high_quota_implement | province + year,
  data = second_stage_marital %>%
    filter(!is.na(housewife_rate_married), !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(twfe_married_housewife_no_rn)
#with the implementation of a high quota, married women's housewife decreases by 2.18 pp, statistically significant at the 5% level

#regressions: high quota implementation on single women's labour market outcomes (Rio Negro excluded)
#single women's unemployment rate
twfe_single_unemp_no_rn <- feols(
  unemp_rate_single ~ high_quota_implement | province + year,
  data = second_stage_marital %>%
    filter(!is.na(unemp_rate_single), !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(twfe_single_unemp_no_rn)
#with the implementation of a high quota, single women's unemployment rate increases by 1.66 pp, statistically significant at the 10% level

#single women's employment rate
twfe_single_emp_no_rn <- feols(
  emp_rate_single ~ high_quota_implement | province + year,
  data = second_stage_marital %>%
    filter(!is.na(emp_rate_single), !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(twfe_single_emp_no_rn)
#with the implementation of a high quota, single women's employment rate decreases by 0.41 pp, not statistically significant 

#single women's lfp rate
twfe_single_lfp_no_rn <- feols(
  lfp_rate_single ~ high_quota_implement | province + year,
  data = second_stage_marital %>%
    filter(!is.na(lfp_rate_single), !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(twfe_single_lfp_no_rn)
#with the implementation of a high quota, single women's lfp rate increases by 0.19 pp, not statistically significant 

#single women's housewife rate
twfe_single_housewife_no_rn <- feols(
  housewife_rate_single ~ high_quota_implement | province + year,
  data = second_stage_marital %>%
    filter(!is.na(housewife_rate_single), !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(twfe_single_housewife_no_rn)
#with the implementation of a high quota, single women's housewife decreases by 0.23 pp, not statistically significant 

#household mechanism check
#clean EPH data with household identifiers 
#early panel (1996-2002) 
clean_eph_household_early <- function(df, year) {
  df %>%
    rename_with(tolower) %>%
    # build household_id from agloreal + codusu (the unique early household key)
    mutate(household_id = paste0(as.character(agloreal), "_", as.character(codusu))) %>%
    select(-aglomerado) %>%
    rename(aglomerado = agloreal) %>%
    mutate(
      ch04       = as.integer(h13),
      birth_year = as.integer(format(as.Date(h11), "%Y")),
      ch06       = as.integer(year) - birth_year,
      ano4       = as.integer(year),
      aglomerado = as.integer(aglomerado),
      pondera    = as.numeric(pondera),
      estado     = as.integer(estado),
      h14        = suppressWarnings(as.integer(h14)),
      married_partnered = h14 %in% c(2, 3),
      h08        = suppressWarnings(as.integer(h08)),
      p11        = suppressWarnings(as.integer(p11)),
      housewife = case_when(
        estado == 3 & p11 == 4 ~ 1,
        estado == 3 & p11 != 4 ~ 0,
        estado != 3            ~ 0,
        TRUE                   ~ NA_real_
      )
    ) %>%
    filter(ch06 >= 14, estado != 0) %>%
    filter(!is.na(aglomerado), !is.na(pondera), !is.na(household_id)) %>%
    dplyr::select(ano4, aglomerado, household_id, pondera, ch04, ch06, estado,
                  housewife, married_partnered, h08)
}

#late panel (2003-2025)
clean_eph_household_post <- function(df, year, quarter = 2) {
  df %>%
    mutate(across(where(is.labelled), as.numeric)) %>%
    rename_with(tolower) %>%
    mutate(
      #household identifier
      nro_hogar  = as.character(nro_hogar),  #household code
      codusu     = as.character(codusu),     
      household_id = paste0(codusu, "_", nro_hogar),  #household ID
      #individual characteristics
      ch04       = as.integer(ch04),    #gender
      ch06       = as.integer(ch06),    #age
      ano4       = as.integer(year),
      quarter    = quarter,
      aglomerado = as.integer(aglomerado),
      pondera    = as.numeric(pondera),
      estado     = as.integer(estado),
      #marital status (2003-2025 coding):
      ch07       = suppressWarnings(as.integer(ch07)),
      married_partnered = ch07 %in% c(1, 2),  #partnered or married
      #relationship to household head (2003-2025 coding)
      ch03       = suppressWarnings(as.integer(ch03)),  # 1=head, 2=spouse/partner, 3=child/stepchild, 4=son-in-law/daughter-in-law, 5=grandchild, 6=mother/father, 
      #7=parent-in-law, 8=sibling, 9=other relatives, 10 = non-relatives
      #housewife indicator
      cat_inac   = suppressWarnings(as.integer(cat_inac)),
      housewife = case_when(
        estado == 3 & cat_inac == 4 ~ 1,
        estado == 3 & cat_inac != 4 ~ 0,
        estado != 3                 ~ 0,
        TRUE                        ~ NA_real_
      )
    ) %>%
    filter(
      ch06 >= 14,
      estado != 0
    ) %>%
    filter(!is.na(aglomerado), !is.na(pondera), !is.na(household_id)) %>%
    dplyr::select(ano4, aglomerado, household_id, pondera, ch04, ch06, estado,
                  housewife, married_partnered, ch03)
}

#household-level panel 
#early panel (1996-2002)
eph_household_early <- suppressWarnings(
  bind_rows(lapply(eph_files_early, function(x) {
    clean_eph_household_early(x$df, x$year)
  }))
)  
#late panel (2003-2025)
eph_household_post <- bind_rows(lapply(eph_files, function(x) {
  clean_eph_household_post(x$df, x$year, x$quarter)
}))
#combine panels (with harmonised relationship variable)
eph_household_full <- bind_rows(
  eph_household_early %>% 
    mutate(relationship = h08) %>%
    select(ano4, aglomerado, household_id, pondera, 
           ch04, ch06, estado, housewife, married_partnered, relationship),
  eph_household_post %>% 
    mutate(relationship = ch03) %>%
    select(ano4, aglomerado, household_id, pondera,
           ch04, ch06, estado, housewife, married_partnered, relationship)
)

#identify partnered/married couples within households 
#for each household, match married/partnered household heads (relationship=1) with spouses (relationship=2)
heads_in_hh <- eph_household_full %>%
  filter(relationship == 1, married_partnered == TRUE) %>%
  mutate(
    head_unemployed = ifelse(estado == 2, 1, 0),
    head_employed = ifelse(estado == 1, 1, 0),
    head_lfp = ifelse(estado %in% c(1, 2), 1, 0),
    head_housewife = housewife,
    head_gender = ch04  #1=male, 2=female
  ) %>%
  select(ano4, aglomerado, household_id, pondera,
         head_unemployed, head_employed, head_lfp, head_housewife, head_gender)

#spouses of household heads
spouses_in_hh <- eph_household_full %>%
  filter(relationship == 2, married_partnered == TRUE) %>%
  mutate(spouse_unemployed = ifelse(estado == 2, 1, 0),
         spouse_employed   = ifelse(estado == 1, 1, 0),
         spouse_lfp        = ifelse(estado %in% c(1, 2), 1, 0),
         spouse_housewife  = housewife,
         spouse_gender     = ch04,
         spouse_age        = ch06) %>%
  group_by(ano4, aglomerado, household_id) %>%
  slice(1) %>%                    # one spouse per household
  ungroup() %>%
  select(ano4, aglomerado, household_id, pondera,
         spouse_unemployed, spouse_employed, spouse_lfp,
         spouse_housewife, spouse_gender)
#link heads and spouses
couples_all <- heads_in_hh %>%
  inner_join(spouses_in_hh, by = c("ano4", "aglomerado", "household_id"),
             suffix = c("_head", "_spouse"))
#keep only male-female couples 
#separate into male head/female spouse vs female head/male spouse
couples_male_head <- couples_all %>%
  filter(head_gender == 1, spouse_gender == 2) %>%
  mutate(
    male_unemployed = head_unemployed,
    male_employed = head_employed,
    male_lfp = head_lfp,
    female_unemployed = spouse_unemployed,
    female_employed = spouse_employed,
    female_lfp = spouse_lfp,
    female_housewife = spouse_housewife,
    pondera_male = pondera_head,
    pondera_female = pondera_spouse
  ) %>%
  select(ano4, aglomerado, household_id, 
         male_unemployed, male_employed, male_lfp,
         female_unemployed, female_employed, female_lfp, female_housewife,
         pondera_male, pondera_female)
couples_female_head <- couples_all %>%
  filter(head_gender == 2, spouse_gender == 1) %>%
  mutate(
    male_unemployed = spouse_unemployed,
    male_employed = spouse_employed,
    male_lfp = spouse_lfp,
    female_unemployed = head_unemployed,
    female_employed = head_employed,
    female_lfp = head_lfp,
    female_housewife = head_housewife,
    pondera_male = pondera_spouse,
    pondera_female = pondera_head
  ) %>%
  select(ano4, aglomerado, household_id,
         male_unemployed, male_employed, male_lfp,
         female_unemployed, female_employed, female_lfp, female_housewife,
         pondera_male, pondera_female)
#combine both types
couples <- bind_rows(couples_male_head, couples_female_head)
couples %>%
  group_by(ano4) %>%
  summarise(
    n_couples = n(),
    total_weighted = sum(pondera_male, na.rm = TRUE),
    .groups = "drop"
  ) 
eph_household_full %>%
  filter(ch04 == 2, ch06 >= 14, married_partnered == TRUE) %>%
  group_by(ano4) %>%
  summarise(
    n_married_women = n(),
    n_in_couple_hh = sum(relationship == 2 | relationship == 1, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  print(n = 30)
#most married women live in the same household with their spouse across all years

#labour market outcome trends among couples 
couples %>%
  group_by(ano4) %>%
  summarise(
    n_couples = n(),
    male_unemp_rate = weighted.mean(male_unemployed, pondera_male, na.rm = TRUE) * 100,
    female_unemp_rate = weighted.mean(female_unemployed, pondera_female, na.rm = TRUE) * 100,
    female_housewife_rate = weighted.mean(female_housewife, pondera_female, na.rm = TRUE) * 100,
    .groups = "drop"
  ) %>%
  print(n = 30)
#male and female unemployment rate shows decreasing trend, housewife rate also shows decreasing trend

#share of partnered/married women in co-residing couples
couple_household_ids <- couples_all %>%
  distinct(ano4, aglomerado, household_id)
married_women_coverage <- eph_household_full %>%
  filter(
    ch04 == 2, #female
    ch06 >= 14,
    married_partnered == TRUE,
    relationship %in% c(1, 2) #head or spouse
  ) %>%
  left_join(
    couple_household_ids %>% mutate(in_couple = 1),
    by = c("ano4", "aglomerado", "household_id")
  ) %>%
  mutate(in_couple = ifelse(is.na(in_couple), 0, 1))
coverage_summary <- married_women_coverage %>%
  summarise(
    n_total_married_women   = n(),
    n_in_couple_hh          = sum(in_couple),
    pct_unweighted          = n_in_couple_hh / n_total_married_women * 100,
    weighted_total          = sum(pondera, na.rm = TRUE),
    weighted_in_couple      = sum(pondera[in_couple == 1], na.rm = TRUE),
    pct_weighted            = weighted_in_couple / weighted_total * 100
  )
print(coverage_summary)
#99% of married women live in co-residing couple-households

#aggregate to province-year level for couples
couples_agg <- couples %>%
  filter(!aglomerado %in% c(38, 91)) %>%
  left_join(aglo_to_province, by = "aglomerado") %>%
  filter(!is.na(provincia_cod)) %>%
  left_join(province_mapping, by = "provincia_cod") %>%
  filter(!is.na(province)) %>%
  group_by(province, ano4) %>%
  summarise(
    male_unemp_rate = sum(pondera_male[male_unemployed == 1], na.rm = TRUE) /
      sum(pondera_male, na.rm = TRUE) * 100,
    female_unemp_rate = sum(pondera_female[female_unemployed == 1], na.rm = TRUE) /
      sum(pondera_female, na.rm = TRUE) * 100,
    male_emp_rate = sum(pondera_male[male_employed == 1], na.rm = TRUE) /
      sum(pondera_male, na.rm = TRUE) * 100,
    female_emp_rate = sum(pondera_female[female_employed == 1], na.rm = TRUE) /
      sum(pondera_female, na.rm = TRUE) * 100,
    male_lfp_rate = sum(pondera_male[male_lfp == 1], na.rm = TRUE) /
      sum(pondera_male, na.rm = TRUE) * 100,
    female_lfp_rate = sum(pondera_female[female_lfp == 1], na.rm = TRUE) /
      sum(pondera_female, na.rm = TRUE) * 100,
    female_housewife_rate = sum(pondera_female[female_housewife == 1], na.rm = TRUE) /
      sum(pondera_female, na.rm = TRUE) * 100,
    .groups = "drop"
  ) %>%
  rename(year = ano4)
#merge with treatment panel
couples_treatment <- treatment_panel %>%
  filter(year >= 1996) %>%
  left_join(couples_agg, by = c("province", "year")) %>%
  filter(!is.na(province))

#comparing married women in co-residing couple households to married women overall
eph_household_full %>%
  filter(ch04 == 2, ch06 >= 14, married_partnered == TRUE) %>%
  left_join(couple_household_ids %>% mutate(in_couple = 1),
            by = c("ano4","aglomerado","household_id")) %>%
  mutate(in_couple = ifelse(is.na(in_couple), 0, 1)) %>%
  group_by(ano4, in_couple) %>%
  summarise(unemp = weighted.mean(estado == 2, pondera, na.rm = TRUE) * 100,
            .groups = "drop") %>%
  tidyr::pivot_wider(names_from = in_couple, values_from = unemp,
                     names_prefix = "in_couple_") %>%
  mutate(gap = in_couple_0 - in_couple_1) %>%
  print(n = 30)
#married women not in couple households have higher unemployment rates across most years

#pooled average (across all years, weighted by population)
eph_household_full %>%
  filter(ch04 == 2, ch06 >= 14, married_partnered == TRUE) %>%
  left_join(couple_household_ids %>% mutate(in_couple = 1),
            by = c("ano4","aglomerado","household_id")) %>%
  mutate(in_couple = ifelse(is.na(in_couple), 0, 1)) %>%
  group_by(in_couple) %>%
  summarise(unemp = weighted.mean(estado == 2, pondera, na.rm = TRUE) * 100,
            n = n(),
            .groups = "drop") %>%
  print()
#married women not in couple households have an average unemployment rate across most years of 5.74%; married women in couple households of 4.29%

#share of married women in co-residing couple households
married_in_couple_coverage <- eph_household_full %>%
  filter(ch04 == 2, ch06 >= 14, married_partnered == TRUE) %>%
  left_join(
    couple_household_ids %>% mutate(in_couple = 1),
    by = c("ano4", "aglomerado", "household_id")
  ) %>%
  mutate(in_couple = ifelse(is.na(in_couple), 0, 1)) %>%
  summarise(
    n_total          = n(),
    n_in_couple      = sum(in_couple),
    pct_unweighted   = n_in_couple / n_total * 100,
    weighted_total   = sum(pondera, na.rm = TRUE),
    weighted_in_couple = sum(pondera[in_couple == 1], na.rm = TRUE),
    pct_weighted     = weighted_in_couple / weighted_total * 100
  )
print(married_in_couple_coverage)
#restricting to co-residing couples retains 95% of married women

#regressions: high quota implementation on labour market outcomes among women in couple households 
#unemployment rate among women in couple hh
female_unemp_couples <- feols(
  female_unemp_rate ~ high_quota_implement | province + year,
  data    = couples_treatment %>% filter(!is.na(female_unemp_rate)),
  cluster = ~province
)
summary(female_unemp_couples)
#with the implementation of a high quota, unemployment rate among women in couple hh increases by 0.53 pp, statistically significant at the 10% level

#employment rate among women in couple hh
female_emp_couples <- feols(
  female_emp_rate ~ high_quota_implement | province + year,
  data    = couples_treatment %>% filter(!is.na(female_emp_rate)),
  cluster = ~province
)
summary(female_emp_couples)
#with the implementation of a high quota, employment rate among women in couple hh increases by 1.40 pp, not statistically significant 

#LFP rate among women in couple hh
female_lfp_couples <- feols(
  female_lfp_rate ~ high_quota_implement | province + year,
  data    = couples_treatment %>% filter(!is.na(female_lfp_rate)),
  cluster = ~province
)
summary(female_lfp_couples)
#with the implementation of a high quota, LFP rate among women in couple hh increases by 1.93 pp, not statistically significant 

#housewife rate among women in couple hh
female_housewife_couples <- feols(
  female_housewife_rate ~ high_quota_implement | province + year,
  data    = couples_treatment %>% filter(!is.na(female_housewife_rate)),
  cluster = ~province
)
summary(female_housewife_couples)
#with the implementation of a high quota, housewife rate among women in couple hh decreases by 2.34 pp, statistically significant at the 5% level

#regressions: high quota implementation on labour market outcomes among men in couple households
#unemployment rate among men in couple hh
male_unemp_couples <- feols(
  male_unemp_rate ~ high_quota_implement | province + year,
  data    = couples_treatment %>% filter(!is.na(male_unemp_rate)),
  cluster = ~province
)
summary(male_unemp_couples)
#with the implementation of a high quota, unemployment rate among men in couple hh increases by 0.51 pp, not statistically significant 

#employment rate among men in couple hh
male_emp_couples <- feols(
  male_emp_rate ~ high_quota_implement | province + year,
  data    = couples_treatment %>% filter(!is.na(male_emp_rate)),
  cluster = ~province
)
summary(male_emp_couples)
#with the implementation of a high quota, employment rate among men in couple hh increases by 0.74 pp, not statistically significant 

#LFP rate among men in couple hh
male_lfp_couples <- feols(
  male_lfp_rate ~ high_quota_implement | province + year,
  data    = couples_treatment %>% filter(!is.na(male_lfp_rate)),
  cluster = ~province
)
summary(male_lfp_couples)
#with the implementation of a high quota, LFP rate among men in couple hh increases by 1.25 pp, statistically significant at the 10% level

#regressions: high quota implementation on labour market outcomes among women in couple households (Rio Negro excluded)
#unemployment rate among women in couple hh
female_unemp_couples_no_rn <- feols(
  female_unemp_rate ~ high_quota_implement | province + year,
  data    = couples_treatment %>%
    filter(!is.na(female_unemp_rate), !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(female_unemp_couples_no_rn)
#with the implementation of a high quota, unemployment rate among women in couple hh increases by 0.42 pp, not statistically significant 

#employment rate among women in couple hh
female_emp_couples_no_rn <- feols(
  female_emp_rate ~ high_quota_implement | province + year,
  data    = couples_treatment %>%
    filter(!is.na(female_emp_rate), !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(female_emp_couples_no_rn)
#with the implementation of a high quota, employment rate among women in couple hh increases by 0.93 pp, not statistically significant 

#LFP rate among women in couple hh
female_lfp_couples_no_rn <- feols(
  female_lfp_rate ~ high_quota_implement | province + year,
  data    = couples_treatment %>%
    filter(!is.na(female_lfp_rate), !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(female_lfp_couples_no_rn)
#with the implementation of a high quota, LFP rate among women in couple hh increases by 1.35 pp, not statistically significant 

#housewife rate among women in couple hh
female_housewife_couples_no_rn <- feols(
  female_housewife_rate ~ high_quota_implement | province + year,
  data    = couples_treatment %>%
    filter(!is.na(female_housewife_rate), !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(female_housewife_couples_no_rn)
#with the implementation of a high quota, housewife rate among women in couple hh increases by 1.35 pp, not statistically significant 

#regressions: high quota implementation on labour market outcomes among men in couple households (Rio Negro excluded)
#unemployment rate among men in couple hh
male_unemp_couples_no_rn <- feols(
  male_unemp_rate ~ high_quota_implement | province + year,
  data    = couples_treatment %>%
    filter(!is.na(male_unemp_rate), !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(male_unemp_couples_no_rn)
#with the implementation of a high quota, unemployment rate among men in couple hh increases by 0.40 pp, not statistically significant 

#employment rate among men in couple hh
male_emp_couples_no_rn <- feols(
  male_emp_rate ~ high_quota_implement | province + year,
  data    = couples_treatment %>%
    filter(!is.na(male_emp_rate), !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(male_emp_couples_no_rn)
#with the implementation of a high quota, employment rate among men in couple hh increases by 0.49 pp, not statistically significant 

#LFP rate among men in couple hh
male_lfp_couples_no_rn <- feols(
  male_lfp_rate ~ high_quota_implement | province + year,
  data    = couples_treatment %>%
    filter(!is.na(male_lfp_rate), !province %in% c("Rio Negro")),
  cluster = ~province
)
summary(male_lfp_couples_no_rn)
#with the implementation of a high quota, LFP rate among men in couple hh increases by 0.88 pp, not statistically significant 

#young women analysis (ages 14-30)
#cleaning function for early panels (1996-2002)
clean_eph_early_young <- function(df) {
  df %>%
    rename_with(tolower) %>%
    select(-aglomerado) %>%
    rename(aglomerado = agloreal) %>%
    mutate(
      ch04       = as.integer(h13),
      birth_year = as.integer(format(as.Date(h11), "%Y")),
      ch06       = as.integer(ano4) - birth_year,
      ano4       = as.integer(ano4),
      aglomerado = as.integer(aglomerado),
      pondera    = as.numeric(pondera),
      estado     = as.integer(estado),
      p11        = suppressWarnings(as.integer(p11)),
      p15t       = as.numeric(p15t),
      p16        = suppressWarnings(as.integer(p16)),
      housewife = case_when(
        estado == 3 & p11 == 4 ~ 1,
        estado == 3 & p11 != 4 ~ 0,
        estado != 3            ~ 0,
        TRUE                   ~ NA_real_
      ),
      underemp = case_when(
        estado == 1 & !is.na(p15t) & p15t < 35 & p16 == 1 ~ 1,
        estado == 1 & !is.na(p15t) & !is.na(p16) & (p15t >= 35 | p16 != 1) ~ 0,
        TRUE ~ NA_real_
      ),
      overemp = case_when(
        estado == 1 & !is.na(p15t) & p15t > 45 ~ 1,
        estado == 1 & !is.na(p15t) & p15t <= 45 ~ 0,
        TRUE ~ NA_real_
      )
    ) %>%
    filter(
      ch04 == 2,
      ch06 >= 14,
      ch06 <= 30,
      estado != 0
    ) %>%
    filter(!is.na(aglomerado), !is.na(pondera)) %>%
    select(ano4, aglomerado, pondera, estado, housewife,
           underemp, overemp, ch06)
}
eph_early_young <- suppressWarnings(
  bind_rows(lapply(eph_files_early, function(x) clean_eph_early_young(x$df)))
)

#cleaning function for late period (2003-2025)
clean_eph_late_young <- function(df, year, quarter = 2) {
  df %>%
    mutate(across(where(is.labelled), as.numeric)) %>%
    rename_with(tolower) %>%
    filter(
      ch04 == 2,
      ch06 >= 14,
      ch06 <= 30,
      estado != 0
    ) %>%
    mutate(
      ano4       = as.integer(year),
      quarter    = quarter,
      aglomerado = as.integer(aglomerado),
      pondera    = as.numeric(pondera),
      estado     = as.integer(estado),
      cat_inac   = suppressWarnings(as.integer(cat_inac)),
      housewife  = case_when(
        estado == 3 & cat_inac == 4 ~ 1,
        estado == 3 & cat_inac != 4 ~ 0,
        estado != 3                 ~ 0,
        TRUE                        ~ NA_real_
      ),
      intensi = suppressWarnings(as.integer(intensi)),
      underemp = case_when(
        ano4 <= 2015 & estado == 1 & intensi %in% c(1, 2) ~ 1,
        ano4 <= 2015 & estado == 1 & !is.na(intensi) & !intensi %in% c(1, 2) ~ 0,
        ano4 >= 2016 & estado == 1 & intensi == 1 ~ 1,
        ano4 >= 2016 & estado == 1 & !is.na(intensi) & intensi != 1 ~ 0,
        TRUE ~ NA_real_
      ),
      overemp = case_when(
        ano4 <= 2015 & estado == 1 & intensi == 4 ~ 1,
        ano4 <= 2015 & estado == 1 & !is.na(intensi) & intensi != 4 ~ 0,
        ano4 >= 2016 & estado == 1 & intensi == 3 ~ 1,
        ano4 >= 2016 & estado == 1 & !is.na(intensi) & intensi != 3 ~ 0,
        TRUE ~ NA_real_
      )
    ) %>%
    filter(!is.na(aglomerado), !is.na(pondera)) %>%
    select(ano4, aglomerado, pondera, estado, housewife,
           underemp, overemp, ch06)
}
eph_late_young <- bind_rows(lapply(eph_files, function(x) {
  clean_eph_late_young(x$df, x$year, x$quarter)
}))

#aggregate to province-year level 
eph_early_young_prov <- eph_early_young %>%
  filter(!aglomerado %in% c(38, 91)) %>%
  left_join(aglo_to_province, by = "aglomerado") %>%
  filter(!is.na(provincia_cod)) %>%
  left_join(province_mapping, by = "provincia_cod") %>%
  filter(!is.na(province)) %>%
  group_by(province, ano4) %>%
  summarise(
    young_unemp_rate     = sum(pondera[estado == 2], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2)], na.rm = TRUE) * 100,
    young_emp_rate       = sum(pondera[estado == 1], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2, 3)], na.rm = TRUE) * 100,
    young_lfp_rate       = sum(pondera[estado %in% c(1, 2)], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2, 3)], na.rm = TRUE) * 100,
    young_housewife_rate = sum(pondera[housewife == 1], na.rm = TRUE) /
      sum(pondera, na.rm = TRUE) * 100,
    young_underemp_rate  = sum(pondera[underemp == 1], na.rm = TRUE) /
      sum(pondera[estado == 1], na.rm = TRUE) * 100,
    young_overemp_rate   = sum(pondera[overemp == 1], na.rm = TRUE) /
      sum(pondera[estado == 1], na.rm = TRUE) * 100,
    n_young              = n(),
    .groups              = "drop"
  ) %>%
  rename(year = ano4)
eph_late_young_prov <- eph_late_young %>%
  filter(!aglomerado %in% c(38, 91)) %>%
  left_join(aglo_to_province, by = "aglomerado") %>%
  filter(!is.na(provincia_cod)) %>%
  left_join(province_mapping, by = "provincia_cod") %>%
  filter(!is.na(province)) %>%
  group_by(province, ano4) %>%
  summarise(
    young_unemp_rate     = sum(pondera[estado == 2], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2)], na.rm = TRUE) * 100,
    young_emp_rate       = sum(pondera[estado == 1], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2, 3)], na.rm = TRUE) * 100,
    young_lfp_rate       = sum(pondera[estado %in% c(1, 2)], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2, 3)], na.rm = TRUE) * 100,
    young_housewife_rate = sum(pondera[housewife == 1], na.rm = TRUE) /
      sum(pondera, na.rm = TRUE) * 100,
    young_underemp_rate  = sum(pondera[underemp == 1], na.rm = TRUE) /
      sum(pondera[estado == 1], na.rm = TRUE) * 100,
    young_overemp_rate   = sum(pondera[overemp == 1], na.rm = TRUE) /
      sum(pondera[estado == 1], na.rm = TRUE) * 100,
    n_young              = n(),
    .groups              = "drop"
  ) %>%
  rename(year = ano4)
#combine panels
eph_young_panel_prov <- bind_rows(
  eph_early_young_prov,
  eph_late_young_prov
) %>%
  arrange(province, year)

#descriptive statistics 
eph_young_panel_prov %>%
  group_by(year) %>%
  summarise(
    mean_unemp     = round(mean(young_unemp_rate,     na.rm = TRUE), 2),
    mean_emp       = round(mean(young_emp_rate,       na.rm = TRUE), 2),
    mean_lfp       = round(mean(young_lfp_rate,       na.rm = TRUE), 2),
    mean_housewife = round(mean(young_housewife_rate, na.rm = TRUE), 2),
    mean_underemp  = round(mean(young_underemp_rate,  na.rm = TRUE), 2),
    mean_overemp   = round(mean(young_overemp_rate,   na.rm = TRUE), 2),
    avg_n_young    = round(mean(n_young, na.rm = TRUE), 0),
    .groups        = "drop"
  ) %>%
  print(n = 30)
#unemployment and underemployment rate decrease, employment rate increases, LFP and overemployment rate remain relatively constant, housewife rate is low throughout and decreases further across the years

#merge with treatment panel
second_stage_young <- treatment_panel %>%
  filter(year >= 1996) %>%
  left_join(eph_young_panel_prov, by = c("province", "year")) %>%
  filter(!is.na(province))
second_stage_young %>%
  summarise(
    n           = n(),
    n_provinces = n_distinct(province),
    years       = paste(min(year), max(year), sep = "-"),
    n_unemp     = sum(!is.na(young_unemp_rate)),
    n_housewife = sum(!is.na(young_housewife_rate))
  )
#11 missing observations from Rio Negro

#regressions: high quota implementation on labour market outcomes among young women 
#unemployment rate among young women
twfe_young_unemp <- feols(
  young_unemp_rate ~ high_quota_implement | province + year,
  data    = second_stage_young %>% filter(!is.na(young_unemp_rate)),
  cluster = ~province
)
summary(twfe_young_unemp)
#with the implementation of a high quota, unemployment rate among young women increases by 1.79 pp, not statistically significant 

#employment rate among young women
twfe_young_emp <- feols(
  young_emp_rate ~ high_quota_implement | province + year,
  data    = second_stage_young %>% filter(!is.na(young_emp_rate)),
  cluster = ~province
)
summary(twfe_young_emp)
#with the implementation of a high quota, employment rate among young women increases by 1.09 pp, not statistically significant 

#LFP rate among young women
twfe_young_lfp <- feols(
  young_lfp_rate ~ high_quota_implement | province + year,
  data    = second_stage_young %>% filter(!is.na(young_lfp_rate)),
  cluster = ~province
)
summary(twfe_young_lfp)
#with the implementation of a high quota, LFP rate among young women increases by 1.88 pp, not statistically significant 

#housewife rate among young women
twfe_young_housewife <- feols(
  young_housewife_rate ~ high_quota_implement | province + year,
  data    = second_stage_young %>% filter(!is.na(young_housewife_rate)),
  cluster = ~province
)
summary(twfe_young_housewife)
#with the implementation of a high quota, housewife rate among young women decreases by 0.72 pp, not statistically significant 

#underemployment rate among young women
twfe_young_underemp <- feols(
  young_underemp_rate ~ high_quota_implement | province + year,
  data    = second_stage_young %>% filter(!is.na(young_underemp_rate)),
  cluster = ~province
)
summary(twfe_young_underemp)
#with the implementation of a high quota, underemployment rate among young women increases by 2.38 pp, not statistically significant 

#overemployment rate among young women
twfe_young_overemp <- feols(
  young_overemp_rate ~ high_quota_implement | province + year,
  data    = second_stage_young %>% filter(!is.na(young_overemp_rate)),
  cluster = ~province
)
summary(twfe_young_overemp)
#with the implementation of a high quota, overemployment rate among young women decreases by 0.81 pp, not statistically significant 

#robustness check 1: event study and parallel pre-treatment trends
#treatment timing 
#low quota
treatment_years_low_es <- treatment_panel %>%
  group_by(province) %>%
  summarise(
    treatment_year = ifelse(
      any(low_quota_implement == 1),
      min(year[low_quota_implement == 1]),
      NA_real_
    ),
    .groups = "drop"
  )
#high quota
treatment_years_high_es <- treatment_panel %>%
  group_by(province) %>%
  summarise(
    treatment_year = ifelse(
      any(high_quota_implement == 1),
      min(year[high_quota_implement == 1]),
      NA_real_
    ),
    .groups = "drop"
  )
#merge treatment panel with EPH outcomes 
treatment_panel_es <- treatment_panel %>%
  left_join(
    eph_panel_prov_full %>%
      select(province, year, housewife_rate, unemp_rate, underemp_rate,
             overemp_rate, emp_rate, lfp_rate),
    by = c("province", "year")
  )

#event study functions 
build_es_data <- function(panel, outcome_var, treatment_years, min_year, max_year,
                          exclude_provinces = NULL, time_window = NULL,
                          max_cohort = NULL) {
  data <- panel %>%
    filter(year >= min_year, year <= max_year)
  if (!is.null(exclude_provinces)) {
    data <- data %>% filter(!province %in% exclude_provinces)
  }
  data <- data %>%
    left_join(treatment_years, by = "province") %>%
    filter(!is.na(treatment_year))
  #drop late cohorts whose post-period falls outside the data window
  if (!is.null(max_cohort)) {
    data <- data %>% filter(treatment_year <= max_cohort)
  }
  data <- data %>%
    mutate(event_time = year - treatment_year)
  if (!is.null(time_window)) {
    data <- data %>%
      filter(event_time >= time_window[1], event_time <= time_window[2])
  }
  return(data)
}

#bin endpoints
run_es <- function(data, outcome_var, ref_period = -1,
                   bin_low = NULL, bin_high = NULL,
                   expected_grid = NULL) {
  d <- data %>% filter(!is.na(!!sym(outcome_var)))
  if (!is.null(bin_low))  d$event_time <- pmax(d$event_time, bin_low)
  if (!is.null(bin_high)) d$event_time <- pmin(d$event_time, bin_high)
  
  formula_str <- paste0(outcome_var,
                        " ~ i(event_time, ref = ", ref_period, ") | province + year")
  mod <- feols(as.formula(formula_str), data = d, cluster = ~province)
  
  all_coefs   <- coef(mod)
  all_ses     <- se(mod)
  event_names <- grep("^event_time::", names(all_coefs), value = TRUE)
  event_times <- as.integer(gsub("event_time::", "", event_names))
  
  results <- tibble(event_time = event_times,
                    estimate   = all_coefs[event_names],
                    std.error  = all_ses[event_names])
  #reference period as the zero point
  results <- bind_rows(results, tibble(event_time = ref_period,
                                       estimate = 0, std.error = 0))
  dropped <- integer(0)
  if (!is.null(expected_grid)) {
    dropped <- setdiff(expected_grid, results$event_time)
    if (length(dropped) > 0) {
      pre_dropped <- dropped[dropped < ref_period]
      if (length(pre_dropped) > 0) {
        warning(sprintf("[%s] PRE-period dropped (check this): %s",
                        outcome_var, paste(pre_dropped, collapse = ", ")))
      }
      results <- bind_rows(results,
                           tibble(event_time = dropped, estimate = NA_real_, std.error = NA_real_))
    }
  }
  results <- results %>% arrange(event_time)
  list(results = results, model = mod, dropped = dropped)
}

#axis labels
es_x_labels <- function(breaks, bin_low = -4, bin_high = 3) {
  vapply(breaks, function(b) if (b > 0) paste0("+", b) else as.character(b),
         character(1))
}
plot_es <- function(es_data, title, subtitle, filename = NULL,
                    bin_low = -4, bin_high = 3, y_lim = NULL) {
  x_breaks <- seq(bin_low, bin_high, by = 1)
  #SE = 0 is marked as missing, the reference period is exempt
  es_data <- es_data %>%
    mutate(
      std.error = ifelse(!is.na(std.error) & std.error <= 0 & event_time != -1,
                         NA_real_, std.error),
      degenerate = is.na(std.error) & !is.na(estimate) & event_time != -1
    )
  p <- ggplot(es_data, aes(x = event_time, y = estimate)) +
    geom_errorbar(aes(ymin = estimate - 1.96 * std.error,
                      ymax = estimate + 1.96 * std.error),
                  width = 0.3, colour = "#2166ac", alpha = 0.7, na.rm = TRUE) +
    geom_point(data = ~ dplyr::filter(.x, !degenerate),
               size = 2, colour = "#2166ac", na.rm = TRUE) +
    geom_point(data = ~ dplyr::filter(.x, degenerate),
               size = 2, shape = 1, stroke = 1, colour = "#2166ac", na.rm = TRUE) +
    geom_hline(yintercept = 0, linetype = "dashed", colour = "grey40", linewidth = 0.8) +
    geom_vline(xintercept = -1, linetype = "dashed", colour = "grey40", linewidth = 0.8) +
    scale_x_continuous(breaks = x_breaks,
                       labels = es_x_labels(x_breaks, bin_low, bin_high)) +
    labs(
      title    = title,
      subtitle = subtitle,
      x        = "Event Time (Years Relative to Treatment)",
      y        = "Coefficient Estimate"
    ) +
    theme_minimal(base_size = 11) +
    theme(
      panel.grid.minor = element_blank(),
      plot.title       = element_text(face = "bold", size = 12),
      plot.subtitle    = element_text(size = 10, colour = "grey40"),
      plot.caption     = element_text(size = 8, colour = "grey50")
    )
  #every panel is the same rectangle on the page 
  x_lim <- c(bin_low - 0.5, bin_high + 0.5)
  p <- p + coord_cartesian(xlim = x_lim, ylim = y_lim)
  if (is.null(filename)) {
    filename <- paste0("es_", tolower(gsub("[^a-zA-Z0-9]", "_", title)), ".pdf")
  }
  ggsave(filename, plot = p, width = 8, height = 5, dpi = 300)
  return(p)
}

#joint pre-trend test using the clustered variance-covariance matrix (proper Wald-test)
test_pretrends <- function(es_model, ref_period = -1) {
  cf <- grep("^event_time::-", names(coef(es_model)), value = TRUE)
  cf <- cf[as.integer(gsub(".*::", "", cf)) != ref_period]
  if (length(cf) == 0) return(list(stat = NA, df = 0, p = NA, note = "no pre-periods"))
  pat <- paste0("^(", paste(gsub("([.|()\\^{}+$*?\\[\\]])", "\\\\\\1", cf),
                            collapse = "|"), ")$")
  w <- tryCatch(fixest::wald(es_model, keep = pat),
                error = function(e) NULL)
  if (is.null(w) || is.na(w$stat)) {
    return(list(stat = NA, df = length(cf), p = NA,
                note = "pre-test under-identified (singular VCV)"))
  }
  list(stat = w$stat, df = w$df1, p = w$p, note = "ok")
}

#bin bounds
BIN_LOW  <- -4
BIN_HIGH <-  3

#shared axis settings
GRID     <- seq(BIN_LOW, BIN_HIGH)          

#y-axis same for first step outcomes and same for second step outcomes
Y_LIM_FS <- c(-6, 16) #women's representation
Y_LIM_SS <- c(-3, 3)  #housewife/LFP rates

#cohort distribution
treatment_years_high_es %>% filter(!is.na(treatment_year)) %>% dplyr::count(treatment_year) %>% arrange(treatment_year)
treatment_years_low_es  %>% filter(!is.na(treatment_year)) %>% dplyr::count(treatment_year) %>% arrange(treatment_year)

#plots
#same exclusion restrictions as in baseline specification
#implementation of a low quota on women's representation 
#same datasets as in baseline specification 
es_low_fs_data   <- build_es_data(treatment_panel_es, "womens_rep",
                                  treatment_years_low_es, 1987, 2025,
                                  exclude_provinces = c("CABA"))
es_low_fs_output <- run_es(es_low_fs_data, "womens_rep",
                           bin_low = BIN_LOW, bin_high = BIN_HIGH,
                           expected_grid = GRID)
test_low_fs      <- test_pretrends(es_low_fs_output$model)
print(data.frame(stat = test_low_fs$stat, df = test_low_fs$df, p_value = test_low_fs$p, note = test_low_fs$note))
plot_es(es_low_fs_output$results,
        "Low Quota: Women's Representation",
        sprintf("Event window: -4 to +3 (endpoints binned) | Pre-trend p = %.3f", test_low_fs$p),
        "es_low_fs.pdf", y_lim = Y_LIM_FS)

#implementation of a high quota on women's representation 
es_high_fs_data   <- build_es_data(treatment_panel_es, "womens_rep",
                                   treatment_years_high_es, 1987, 2025,
                                   exclude_provinces = c("CABA"))
es_high_fs_output <- run_es(es_high_fs_data, "womens_rep",
                            bin_low = BIN_LOW, bin_high = BIN_HIGH,
                            expected_grid = GRID)
test_high_fs      <- test_pretrends(es_high_fs_output$model)
print(data.frame(stat = test_high_fs$stat, df = test_high_fs$df, p_value = test_high_fs$p, note = test_high_fs$note))
plot_es(es_high_fs_output$results,
        "High Quota: Women's Representation",
        sprintf("Event window: -4 to +3 (endpoints binned) | Pre-trend p = %.3f", test_high_fs$p),
        "es_high_fs.pdf", y_lim = Y_LIM_FS)

#implementation of a low quota on female LFP rate
es_low_lfp_data   <- build_es_data(second_stage_low, "lfp_rate",
                                   treatment_years_low_es, 1990, 2003,
                                   exclude_provinces = c("Rio Negro"))
es_low_lfp_output <- run_es(es_low_lfp_data, "lfp_rate",
                            bin_low = BIN_LOW, bin_high = BIN_HIGH,
                            expected_grid = GRID)
test_low_lfp      <- test_pretrends(es_low_lfp_output$model)
print(data.frame(stat = test_low_lfp$stat, df = test_low_lfp$df, p_value = test_low_lfp$p, note = test_low_lfp$note))
plot_es(es_low_lfp_output$results,
        "Low Quota: LFP Rate",
        sprintf("Event window: -4 to +3 (endpoints binned) | Pre-trend p = %.3f", test_low_lfp$p),
        "es_low_lfp.pdf", y_lim = Y_LIM_SS)

#implementation of a high quota on housewife rate
es_high_hw_data   <- build_es_data(treatment_panel_es, "housewife_rate",
                                   treatment_years_high_es, 1996, 2025)
es_high_hw_output <- run_es(es_high_hw_data, "housewife_rate",
                            bin_low = BIN_LOW, bin_high = BIN_HIGH,
                            expected_grid = GRID)
test_high_hw      <- test_pretrends(es_high_hw_output$model)
print(data.frame(stat = test_high_hw$stat, df = test_high_hw$df, p_value = test_high_hw$p, note = test_high_hw$note))
plot_es(es_high_hw_output$results,
        "High Quota: Housewife Rate",
        sprintf("Event window: -4 to +3 (endpoints binned) | Pre-trend p = %.3f", test_high_hw$p),
        "es_high_housewife.pdf", y_lim = Y_LIM_SS)

#reference period sensitivity check (high quota housewife rate only)
ref_periods <- c(-3, -2, -1)
ref_sensitivity <- bind_rows(lapply(ref_periods, function(ref) {
  es_output <- run_es(es_high_hw_data, "housewife_rate", ref_period = ref,
                      bin_low = BIN_LOW, bin_high = BIN_HIGH,
                      expected_grid = GRID)
  test <- test_pretrends(es_output$model, ref_period = ref)
  es_output$results %>%
    mutate(
      reference  = paste0("Ref = ", ref),
      pretrend_p = test$p
    )
}))
ref_breaks <- seq(BIN_LOW, BIN_HIGH, by = 1)
ggplot(ref_sensitivity, aes(x = event_time, y = estimate, colour = reference)) +
  geom_point(size = 2, position = position_dodge(width = 0.3), na.rm = TRUE) +
  geom_errorbar(aes(ymin = estimate - 1.96 * std.error,
                    ymax = estimate + 1.96 * std.error),
                width = 0.2, position = position_dodge(width = 0.3),
                alpha = 0.7, na.rm = TRUE) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey40") +
  geom_vline(xintercept = -1, linetype = "dashed", colour = "grey40") +
  scale_x_continuous(breaks = ref_breaks,
                     labels = es_x_labels(ref_breaks, BIN_LOW, BIN_HIGH)) +
  coord_cartesian(xlim = c(BIN_LOW - 0.5, BIN_HIGH + 0.5),
                  ylim = Y_LIM_SS) +
  scale_colour_manual(values = c("#2166ac", "#d73027", "#1a9641")) +
  labs(
    title    = "High-Quota Event Study: Housewife Rate and Reference-Period Sensitivity",
    subtitle = "Event window: -4 to +3 (endpoints binned)",
    x        = "Event Time (Years Relative to Treatment)",
    y        = "Coefficient Estimate",
    colour   = "Reference Period"
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid.minor = element_blank(),
    plot.title       = element_text(face = "bold", size = 12),
    plot.subtitle    = element_text(size = 10, colour = "grey40"),
    legend.position  = "bottom"
  )
ggsave("es_housewife_reference_sensitivity.pdf", width = 8, height = 5, dpi = 300)
#pre-trend p-values for each reference period
ref_sensitivity %>%
  distinct(reference, pretrend_p) %>%
  print()

#robustness check 2: placebo treatment timing
#assign fake treatment date before the true treatment date 

#quota-specific placebo 
#High quota: shift = -4   (data 1987/1996-2025, treatment 2002-2023 -> 6-15 clean pre-periods)
HIGH_SHIFT <- -4
#Low quota : shift = -2   (data 1990-2003, treatment 1993-2011 -> 3 pre-periods in the 1990-2003 LFP panel)
LOW_SHIFT  <- -2

#assign placebo timing and censor true post-treatment observations 
run_placebo <- function(panel, outcome, treatment_years, shift,
                        min_year, max_year,
                        exclude_provinces = NULL,
                        exclude_cohorts   = NULL) {
  ty <- treatment_years %>%
    filter(!is.na(treatment_year))
  if (!is.null(exclude_cohorts)) {
    ty <- ty %>% filter(!treatment_year %in% exclude_cohorts)
  }
  ty <- ty %>% mutate(placebo_year = treatment_year + shift)  
  
  #censor every genuinely treated observation
  d <- panel %>%
    filter(year >= min_year, year <= max_year,
           !is.na(.data[[outcome]])) %>%
    { if (!is.null(exclude_provinces))
      filter(., !province %in% exclude_provinces) else . } %>%
    inner_join(ty, by = "province") %>%             #keep only treated provinces
    filter(year < treatment_year) %>%               #censor true post-period
    mutate(placebo = as.integer(year >= placebo_year))
  
  fml <- as.formula(paste0(outcome, " ~ placebo | province + year"))
  feols(fml, data = d, cluster = ~province)
}

#placebo regressions for outcomes with statistically significant coefficients in the baseline specification
#placebo high quota implementation on women's representation 
placebo_high_fs <- run_placebo(
  treatment_panel_es, "womens_rep", treatment_years_high_es, HIGH_SHIFT,
  min_year = 1987, max_year = 2025,
  exclude_provinces = c("CABA")
)
summary(placebo_high_fs)
#with the implementation of a placebo high quota, women's representation increases by 2.10 pp, not statistically significant 

#placebo high quota implementation on housewife rate 
placebo_high_hw <- run_placebo(
  treatment_panel_es, "housewife_rate", treatment_years_high_es, HIGH_SHIFT,
  min_year = 1996, max_year = 2025,
)
summary(placebo_high_hw)
#with the implementation of a placebo high quota, housewife rate increases by 0.67 pp, not statistically significant 

#placebo low quota implementation on female LFP rate
placebo_low_lfp <- run_placebo(
  second_stage_low, "lfp_rate", treatment_years_low_es, LOW_SHIFT,
  min_year = 1990, max_year = 2003,
  exclude_provinces = c("Rio Negro"),
  exclude_cohorts   = c(1993)
)
summary(placebo_low_lfp)
#with the implementation of a placebo low quota, female LFP rate decreases by 0.04 pp, not statistically significant 

#robustness check 2.1: placebo outcome test with primary school completion rate (1996-2025)
clean_eph_early_placebo <- function(df) {
  df %>%
    rename_with(tolower) %>%
    select(-aglomerado) %>%
    rename(aglomerado = agloreal) %>%
    mutate(
      ch04       = as.integer(h13),
      birth_year = as.integer(format(as.Date(h11), "%Y")),
      ch06       = as.integer(ano4) - birth_year,
      ano4       = as.integer(ano4),
      aglomerado = as.integer(aglomerado),
      pondera    = as.numeric(pondera),
      estado     = as.integer(estado),
      p55  = as.integer(p55),
      p56  = suppressWarnings(as.integer(p56)),
      p58  = as.integer(p58),
      prim_complete = case_when(
        p55 == 3            ~ 0,
        is.na(p56) | p56 == 9 ~ NA_real_,
        p56 == 1 & p58 == 1 ~ 1,
        p56 >= 2            ~ 1,
        TRUE                ~ 0
      )
    ) %>%
    filter(
      ch04 == 2,
      ch06 >= 14,
      estado != 0
    ) %>%
    filter(!is.na(aglomerado), !is.na(pondera)) %>%
    dplyr::select(ano4, aglomerado, pondera, estado, prim_complete)
}
clean_eph_placebo <- function(df, year, quarter = 2) {
  df %>%
    mutate(across(where(is.labelled), as.numeric)) %>%
    rename_with(tolower) %>%
    filter(
      ch04 == 2,
      ch06 >= 14,
      estado != 0
    ) %>%
    mutate(
      ano4         = as.integer(year),
      quarter      = quarter,
      aglomerado   = as.integer(aglomerado),
      pondera      = as.numeric(pondera),
      estado       = as.integer(estado),
      nivel_ed     = as.integer(nivel_ed),
      nivel_ed     = ifelse(nivel_ed == 9, NA_integer_, nivel_ed),
      prim_complete = case_when(
        is.na(nivel_ed) ~ NA_real_,
        nivel_ed == 7   ~ 0,
        nivel_ed >= 2   ~ 1,
        TRUE            ~ 0
      )
    ) %>%
    filter(!is.na(aglomerado), !is.na(pondera)) %>%
    dplyr::select(ano4, aglomerado, pondera, estado, prim_complete)
}
#panels 
eph_panel_early_placebo <- suppressWarnings(
  bind_rows(lapply(eph_files_early, function(x) clean_eph_early_placebo(x$df)))
)
eph_panel_placebo <- bind_rows(lapply(eph_files, function(x) {
  clean_eph_placebo(x$df, x$year, x$quarter)
}))
eph_panel_full_placebo <- bind_rows(
  eph_panel_early_placebo,
  eph_panel_placebo
)
eph_panel_prov_placebo <- eph_panel_full_placebo %>%
  filter(!aglomerado %in% c(38, 91)) %>%
  left_join(aglo_to_province, by = "aglomerado") %>%
  filter(!is.na(provincia_cod)) %>%
  left_join(province_mapping, by = "provincia_cod") %>%
  filter(!is.na(province)) %>%
  group_by(province, ano4) %>%
  summarise(
    prim_rate = sum(pondera[prim_complete == 1], na.rm = TRUE) /
      sum(pondera[!is.na(prim_complete)], na.rm = TRUE) * 100,
    .groups = "drop"
  ) %>%
  rename(year = ano4)
second_stage_placebo <- treatment_panel %>%
  filter(year >= 1996) %>%
  left_join(eph_panel_prov_placebo, by = c("province", "year")) %>%
  filter(!is.na(province))

#regression: high quota implementation on placebo outcome female primary school attainment rate
twfe_placebo_prim <- feols(
  prim_rate ~ high_quota_implement | province + year,
  data    = second_stage_placebo %>% filter(!is.na(prim_rate)),
  cluster = ~province
)
summary(twfe_placebo_prim)
#with the implementation of a high quota, female primary school attainment rate decreases by 0.56 pp, not statistically significant

#robustness check 3: 2SLS and instrument strength
#identifies effect specifically through channel of increased women's representation
#same exclusions as in baseline specification

#2SLS regressions: low quota implementation on female labour market outcome variables (1990-2003)
#female unemployment rate
iv_low_unemp <- feols(
  unemp_rate ~ 1 | province + year | womens_rep ~ low_quota_implement,
  data    = second_stage_low %>%
    filter(!province %in% c("CABA", "Rio Negro"),  
           !is.na(unemp_rate), !is.na(womens_rep)),
  cluster = ~province
)
summary(iv_low_unemp)
#low quota is a weak instrument (F=6.89)
#H0 from WU-Hausman test cannot be rejected, so there is no evidence that women's representation is endogenous
#with the implementation of a low quota, female unemployment rate increases by 0.16 pp, not statistically significant

#female employment rate
iv_low_emp <- feols(
  emp_rate ~ 1 | province + year | womens_rep ~ low_quota_implement,
  data    = second_stage_low %>%
    filter(!province %in% c("CABA", "Rio Negro"),
           !is.na(emp_rate), !is.na(womens_rep)),
  cluster = ~province
)
summary(iv_low_emp)
#H0 from WU-Hausman test is rejected, so there is evidence for exogeneity in women's representation, but test reliability is undermined by weak instrument
#with the implementation of a low quota, female employment rate increases by 0.22 pp, not statistically significant

#female LFP rate
iv_low_lfp <- feols(
  lfp_rate ~ 1 | province + year | womens_rep ~ low_quota_implement,
  data    = second_stage_low %>%
    filter(!province %in% c("CABA", "Rio Negro"),
           !is.na(lfp_rate), !is.na(womens_rep)),
  cluster = ~province
)
summary(iv_low_lfp)
#H0 from WU-Hausman test is rejected, so there is evidence for exogeneity in women's representation, but test reliability is undermined by weak instrument
#with the implementation of a low quota, female LFP rate increases by 0.32 pp, not statistically significant

#female underemployment rate
iv_low_underemp <- feols(
  underemp_rate ~ 1 | province + year | womens_rep ~ low_quota_implement,
  data    = second_stage_low %>%
    filter(!province %in% c("CABA", "Rio Negro"),
           !is.na(underemp_rate), !is.na(womens_rep)),
  cluster = ~province
)
summary(iv_low_underemp)
#H0 from WU-Hausman test cannot be rejected, so there is no evidence that women's representation is endogenous
#with the implementation of a low quota, female underemployment rate increases by 0.25 pp, not statistically significant

#female overemployment rate
iv_low_overemp <- feols(
  overemp_rate ~ 1 | province + year | womens_rep ~ low_quota_implement,
  data    = second_stage_low %>%
    filter(!province %in% c("CABA", "Rio Negro"),
           !is.na(overemp_rate), !is.na(womens_rep)),
  cluster = ~province
)
summary(iv_low_overemp)
#H0 from WU-Hausman test cannot be rejected, so there is no evidence that women's representation is endogenous
#with the implementation of a low quota, female overemployment rate decreases by 0.19 pp, not statistically significant

#2SLS regressions: high quota implementation on female labour market outcome variables (1996-2025)
#female unemployment rate
iv_high_unemp_1996 <- feols(
  unemp_rate ~ 1 | province + year | womens_rep ~ high_quota_implement,
  data    = second_stage_high %>%
    filter(!province %in% c("CABA"),
           !is.na(unemp_rate), !is.na(womens_rep)),
  cluster = ~province
)
summary(iv_high_unemp_1996)
#strong instrument (F=102.57)
#H0 from WU-Hausman test is rejected, so there is evidence for exogeneity in women's representation, 2SLS approach is appropriate
#with the implementation of a high quota, female unemployment rate increases by 0.12 pp, not statistically significant

#female employment rate
iv_high_emp_1996 <- feols(
  emp_rate ~ 1 | province + year | womens_rep ~ high_quota_implement,
  data    = second_stage_high %>%
    filter(!province %in% c("CABA"),
           !is.na(emp_rate), !is.na(womens_rep)),
  cluster = ~province
)
summary(iv_high_emp_1996)
#H0 from WU-Hausman test cannot be rejected, so no evidence that women's representation is endogenous
#with the implementation of a high quota, female employment rate increases by 0.08 pp, not statistically significant

iv_high_lfp_1996 <- feols(
  lfp_rate ~ 1 | province + year | womens_rep ~ high_quota_implement,
  data    = second_stage_high %>%
    filter(!province %in% c("CABA"),
           !is.na(lfp_rate), !is.na(womens_rep)),
  cluster = ~province
)
summary(iv_high_lfp_1996)
#H0 from WU-Hausman test cannot be rejected, so no evidence that women's representation is endogenous
#with the implementation of a high quota, female LFP rate increases by 0.14 pp, not statistically significant

iv_high_housewife_1996 <- feols(
  housewife_rate ~ 1 | province + year | womens_rep ~ high_quota_implement,
  data    = second_stage_high %>%
    filter(!province %in% c("CABA"),
           !is.na(housewife_rate), !is.na(womens_rep)),
  cluster = ~province
)
summary(iv_high_housewife_1996)
#H0 from WU-Hausman test is rejected, so there is evidence for exogeneity in women's representation, 2SLS approach is appropriate
#with the implementation of a high quota, housewife rate decreases by 0.12 pp, statistically significant at the 5% level

iv_high_underemp_1996 <- feols(
  underemp_rate ~ 1 | province + year | womens_rep ~ high_quota_implement,
  data    = second_stage_high %>%
    filter(!province %in% c("CABA"),
           !is.na(underemp_rate), !is.na(womens_rep)),
  cluster = ~province
)
summary(iv_high_underemp_1996)
#H0 from WU-Hausman test is rejected, so there is evidence for exogeneity in women's representation, 2SLS approach is appropriate
#with the implementation of a high quota, female underemployment rate increases by 0.18 pp, not statistically significant

iv_high_overemp_1996 <- feols(
  overemp_rate ~ 1 | province + year | womens_rep ~ high_quota_implement,
  data    = second_stage_high %>%
    filter(!province %in% c("CABA"),
           !is.na(overemp_rate), !is.na(womens_rep)),
  cluster = ~province
)
summary(iv_high_overemp_1996)
#H0 from WU-Hausman test is rejected, so there is evidence for exogeneity in women's representation, 2SLS approach is appropriate
#with the implementation of a high quota, female overemployment rate decreases by 0.09 pp, not statistically significant

#robustness check 4: sample exclusion 
#exclude crisis years 2001-2002 
second_stage_high_nocrisis <- second_stage_high %>%
  filter(!year %in% c(2001, 2002))
second_stage_low_nocrisis <- second_stage_low %>%
  filter(!year %in% c(2001, 2002))
#coverage check
second_stage_high_nocrisis %>%
  summarise(
    n           = n(),
    n_provinces = n_distinct(province),
    years       = paste(min(year), max(year), sep = "-"),
    n_unemp     = sum(!is.na(unemp_rate)),
    n_emp       = sum(!is.na(emp_rate)),
    n_lfp       = sum(!is.na(lfp_rate)),
    n_housewife = sum(!is.na(housewife_rate)),
    n_underemp  = sum(!is.na(underemp_rate)),
    n_overemp   = sum(!is.na(overemp_rate))
  )

#regression: low quota implementation on female LFP rate with crisis year excluded (1990-2003; without 2001 and 2002)
twfe_low_lfp_nocrisis <- feols(
  lfp_rate ~ low_quota_implement | province + year,
  data    = second_stage_low_nocrisis %>%
    filter(!is.na(lfp_rate)),
  cluster = ~province
)
summary(twfe_low_lfp_nocrisis)
#with the implementation of a low quota, female LFP rate increases by 0.93 pp, not statistically significant

#regression: high quota implementation on housewife rate with crisis year excluded (1996-2025; without 2001 and 2002)
twfe_high_housewife_nocrisis <- feols(
  housewife_rate ~ high_quota_implement | province + year,
  data    = second_stage_high_nocrisis %>%
    filter(!is.na(housewife_rate)),
  cluster = ~province
)
summary(twfe_high_housewife_nocrisis)
#with the implementation of a high quota, housewife rate decreases by 1.12 pp, statistically significant at the 5% level

#regression: high quota implementation on female LFP rate with Buenos Aires Province excluded (1990-2003) 
twfe_low_lfp_noba <- feols(
  lfp_rate ~ low_quota_implement | province + year,
  data    = second_stage_low %>%  
    filter(!is.na(lfp_rate), year >= 1990,
           province != "Buenos Aires"),
  cluster = ~province
)
summary(twfe_low_lfp_noba)
#with the implementation of a low quota, female LFP rate increases by 1.06 pp, not statistically significant 

#regression: high quota implementation on housewife rate with Buenos Aires Province excluded (1996-2025) 
twfe_high_housewife_noba <- feols(
  housewife_rate ~ high_quota_implement | province + year,
  data    = second_stage_high %>%  
    filter(!is.na(housewife_rate), year >= 1996,
           province != "Buenos Aires"),
  cluster = ~province
)
summary(twfe_high_housewife_noba)
#with the implementation of a high quota, housewife rate decreases by 1.05 pp, statistically significant at the 5% level

#robustness check 5: wave selection sensitivity for high quota implementation on housewife rate 
#2020 and 2024 quarter substitutions 

#2020
eph_files_2020_q2 <- eph_files
eph_files_2020_q2[[18]] <- list(df = path_EH_2020, year = 2020, quarter = 2)
eph_files_2020_q3 <- eph_files
eph_files_2020_q3[[18]] <- list(df = path_EH_2020_3, year = 2020, quarter = 3)
eph_files_2020_q4 <- eph_files
eph_files_2020_q4[[18]] <- list(df = path_EH_2020_4, year = 2020, quarter = 4)

#province-level aggregation
build_eph_prov_panel <- function(eph_files, eph_panel_early) {
  eph_panel_late <- bind_rows(lapply(eph_files, function(x) {
    clean_eph_with_quarter(x$df, x$year, x$quarter)
  }))
  eph_panel_full_alt <- bind_rows(
    eph_panel_early,
    eph_panel_late %>% select(ano4, aglomerado, pondera,
                              estado, housewife,
                              underemp, overemp)
  )
  eph_panel_full_alt %>%
    filter(!aglomerado %in% c(38, 91)) %>%
    left_join(aglo_to_province, by = "aglomerado") %>%
    filter(!is.na(provincia_cod)) %>%
    left_join(province_mapping, by = "provincia_cod") %>%
    filter(!is.na(province)) %>%
    group_by(province, ano4) %>%
    summarise(
      unemp_rate     = sum(pondera[estado == 2], na.rm = TRUE) /
        sum(pondera[estado %in% c(1, 2)], na.rm = TRUE) * 100,
      emp_rate       = sum(pondera[estado == 1], na.rm = TRUE) /
        sum(pondera[estado %in% c(1, 2, 3)], na.rm = TRUE) * 100,
      lfp_rate       = sum(pondera[estado %in% c(1, 2)], na.rm = TRUE) /
        sum(pondera[estado %in% c(1, 2, 3)], na.rm = TRUE) * 100,
      housewife_rate = sum(pondera[housewife == 1], na.rm = TRUE) /
        sum(pondera, na.rm = TRUE) * 100,
      underemp_rate  = sum(pondera[underemp == 1], na.rm = TRUE) /
        sum(pondera[estado == 1], na.rm = TRUE) * 100,
      overemp_rate   = sum(pondera[overemp == 1], na.rm = TRUE) /
        sum(pondera[estado == 1], na.rm = TRUE) * 100,
      .groups        = "drop"
    ) %>%
    rename(year = ano4)
}

#province-level panels for each alternative quarter
eph_panel_prov_full_2020_q2 <- build_eph_prov_panel(eph_files_2020_q2, eph_panel_early)
eph_panel_prov_full_2020_q3 <- build_eph_prov_panel(eph_files_2020_q3, eph_panel_early)
eph_panel_prov_full_2020_q4 <- build_eph_prov_panel(eph_files_2020_q4, eph_panel_early)

#merge treatment panels with alternative 2020 quarters
second_stage_high_2020_q2 <- treatment_panel %>%
  filter(year >= 1996) %>%
  left_join(eph_panel_prov_full_2020_q2, by = c("province", "year")) %>%
  filter(!is.na(province))
second_stage_high_2020_q3 <- treatment_panel %>%
  filter(year >= 1996) %>%
  left_join(eph_panel_prov_full_2020_q3, by = c("province", "year")) %>%
  filter(!is.na(province))
second_stage_high_2020_q4 <- treatment_panel %>%
  filter(year >= 1996) %>%
  left_join(eph_panel_prov_full_2020_q4, by = c("province", "year")) %>%
  filter(!is.na(province))

#regressions: high quota implementation on housewife rate with 2020 alternative quarters (1996-2025)
run_housewife_model <- function(data) {
  feols(
    housewife_rate ~ high_quota_implement | province + year,
    data    = data %>% filter(!is.na(housewife_rate), year >= 1996),
    cluster = ~province
  )
}
housewife_2020_q2 <- run_housewife_model(second_stage_high_2020_q2)
housewife_2020_q3 <- run_housewife_model(second_stage_high_2020_q3)
housewife_2020_q4 <- run_housewife_model(second_stage_high_2020_q4)

#regressions: high quota implementation on housewife rate with 2020 alternative quarters (1996-2025)
#Q2
summary(housewife_2020_q2)
#with the implementation of a high quota, housewife rate decreases by 1.03 pp, statistically significant at the 5% level
#Q3
summary(housewife_2020_q3)
#with the implementation of a high quota, housewife rate decreases by 0.98 pp, statistically significant at the 5% level
#Q4
summary(housewife_2020_q4)
#with the implementation of a high quota, housewife rate decreases by 0.84 pp, statistically significant at the 10% level

#province with missing observation in Q3 
anti_join(
  eph_panel_prov_full_2020_q2 %>% filter(year == 2020) %>% select(province),
  eph_panel_prov_full_2020_q3 %>% filter(year == 2020) %>% select(province)
)
#Tierra del Fuego is missing one observation in Q3 2020

#2024
#Q4 2024  
eph_2024_q4_prov_full <- path_EH_2024_4 %>%
  mutate(across(where(is.labelled), as.numeric)) %>%
  rename_with(tolower) %>%
  filter(ch04 == 2, ch06 >= 14, estado != 0) %>%
  mutate(
    ano4       = 2024L,
    aglomerado = as.integer(aglomerado),
    pondera    = as.numeric(pondera),
    estado     = as.integer(estado),
    cat_inac   = suppressWarnings(as.integer(cat_inac)),
    intensi    = suppressWarnings(as.integer(intensi)),
    housewife  = case_when(
      estado == 3 & cat_inac == 4 ~ 1,
      estado == 3 & cat_inac != 4 ~ 0,
      estado != 3 ~ 0,
      TRUE ~ NA_real_
    ),
    underemp = case_when(
      estado == 1 & intensi == 1 ~ 1,
      estado == 1 & !is.na(intensi) & intensi != 1 ~ 0,
      TRUE ~ NA_real_
    ),
    overemp = case_when(
      estado == 1 & intensi == 3 ~ 1,
      estado == 1 & !is.na(intensi) & intensi != 3 ~ 0,
      TRUE ~ NA_real_
    )
  ) %>%
  filter(!is.na(aglomerado), !is.na(pondera), !aglomerado %in% c(38, 91)) %>%
  left_join(aglo_to_province, by = "aglomerado") %>%
  filter(!is.na(provincia_cod)) %>%
  left_join(province_mapping, by = "provincia_cod") %>%
  filter(!is.na(province)) %>%
  group_by(province, ano4) %>%
  summarise(
    unemp_rate     = sum(pondera[estado == 2], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2)], na.rm = TRUE) * 100,
    emp_rate       = sum(pondera[estado == 1], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2, 3)], na.rm = TRUE) * 100,
    lfp_rate       = sum(pondera[estado %in% c(1, 2)], na.rm = TRUE) /
      sum(pondera[estado %in% c(1, 2, 3)], na.rm = TRUE) * 100,
    housewife_rate = sum(pondera[housewife == 1], na.rm = TRUE) /
      sum(pondera, na.rm = TRUE) * 100,
    underemp_rate  = sum(pondera[underemp == 1], na.rm = TRUE) /
      sum(pondera[estado == 1], na.rm = TRUE) * 100,
    overemp_rate   = sum(pondera[overemp == 1], na.rm = TRUE) /
      sum(pondera[estado == 1], na.rm = TRUE) * 100,
    .groups        = "drop"
  ) %>%
  rename(year = ano4)

#Q4 instead of Q1 2024 
treatment_panel_2024q4_full <- treatment_panel_es %>%
  filter(year != 2024) %>%
  bind_rows(
    treatment_panel_es %>%
      filter(year == 2024) %>%
      select(-unemp_rate, -emp_rate, -lfp_rate,
             -housewife_rate, -underemp_rate, -overemp_rate) %>%
      left_join(
        eph_2024_q4_prov_full %>%
          select(province, year, unemp_rate, emp_rate, lfp_rate,
                 housewife_rate, underemp_rate, overemp_rate),
        by = c("province", "year")
      )
  )

#excluding 2024  
treatment_panel_no2024_full <- treatment_panel_es %>%
  mutate(
    housewife_rate = ifelse(year == 2024, NA_real_, housewife_rate)
  )
housewife_2024_q4 <- run_housewife_model(treatment_panel_2024q4_full)
housewife_2024_no <- run_housewife_model(treatment_panel_no2024_full)

#regressions: high quota implementation on housewife rate with 2024 alternative quarter or exclusion (1996-2025)
#Q4
summary(housewife_2024_q4)
#with the implementation of a high quota, housewife rate decreases by 1.00 pp, statistically significant at the 5% level
#2024 excluded
summary(housewife_2024_no)
#with the implementation of a high quota, housewife rate decreases by 1.08 pp, statistically significant at the 5% level

#robustness check 6: Goodman-Bacon decomposition and Callaway-Sant'Anna 
#add numeric province code
treatment_panel <- treatment_panel %>%
  left_join(province_mapping, by = "province")

#add first-treatment-year variables for CS
treatment_panel <- treatment_panel %>%
  group_by(province) %>%
  mutate(
    high_quota_first_year = ifelse(
      any(high_quota_implement == 1, na.rm = TRUE),
      min(year[high_quota_implement == 1], na.rm = TRUE),
      0
    ),
    low_quota_first_year = ifelse(
      any(low_quota_implement == 1, na.rm = TRUE),
      min(year[low_quota_implement == 1], na.rm = TRUE),
      0
    )
  ) %>%
  ungroup()

#Goodman-Bacon decomposition 
#same exclusion restrictions as in baseline 
#requires strongly balanced panel: drop provinces with missing years

#low quota: women's representation 
#check balance
bacon_data_lq_fs <- treatment_panel %>%
  filter(province != "CABA", year >= 1991, !is.na(womens_rep))
bacon_data_lq_fs %>%
  group_by(province) %>%
  summarise(n = n()) %>%
  dplyr::count(n)
#balanced panel: 23 provinces with 35 years of data

bacon_lq_fs <- bacon(
  formula = womens_rep ~ low_quota_implement,
  data = bacon_data_lq_fs,
  id_var = "province",
  time_var = "year"
)
print(bacon_lq_fs)
#earlier vs later treated: 14%, later vs earlier treated: 76%, treated vs untreated: 11%
#25% share of clean comparisons

#high quota: women's representation
#check balance
bacon_data_hq_fs <- treatment_panel %>%
  filter(province != "CABA", year >= 1991, !is.na(womens_rep))
bacon_data_hq_fs %>%
  group_by(province) %>%
  summarise(n = n()) %>%
  dplyr::count(n)
#balanced panel: 23 provinces with 35 years of data

bacon_hq_fs <- bacon(
  formula = womens_rep ~ high_quota_implement,
  data = bacon_data_hq_fs,
  id_var = "province",
  time_var = "year"
)
print(bacon_hq_fs)
#earlier vs later treated: 59%, later vs earlier treated: 19%, treated vs untreated: 22%
#81% share of clean comparisons

#high quota: housewife rate
#check balance
eph_panel_prov_full %>%
  filter(!is.na(housewife_rate)) %>%
  group_by(province) %>%
  summarise(n = n()) %>%
  dplyr::count(n)
#unbalanced banel: 23 provinces have 30 years, Rio Negro has 19 years of data and has to be excluded

bacon_data_hq_hw <- eph_panel_prov_full %>%
  filter(province != "Rio Negro", !is.na(housewife_rate)) %>%
  left_join(
    treatment_panel %>% select(province, year, high_quota_implement),
    by = c("province", "year")
  )
#verify merge 
names(bacon_data_hq_hw)
table(bacon_data_hq_hw$high_quota_implement, useNA = "always")
#no NAs
bacon_hq_hw <- bacon(
  formula = housewife_rate ~ high_quota_implement,
  data = bacon_data_hq_hw,
  id_var = "province",
  time_var = "year"
)
print(bacon_hq_hw)
#earlier vs later treated: 54%, later vs earlier treated: 22%, treated vs untreated: 24%
#78% share of clean comparisons

#low quota: female LFP rate 
#check balance
second_stage_low %>%
  filter(year >= 1991, !is.na(lfp_rate)) %>%
  group_by(province) %>%
  summarise(n = n()) %>%
  dplyr::count(n)
#unbalanced banel: 22 provinces have 13 years, Corrientes has 12 years of data and has to be excluded

bacon_data_lq_lfp <- second_stage_low %>%
  filter(year >= 1991, 
         province != "Corrientes",
         !is.na(lfp_rate))

#verify merge
names(bacon_data_lq_lfp)
table(bacon_data_lq_lfp$low_quota_implement, useNA = "always")
#no NAs

bacon_lq_lfp <- bacon(
  formula = lfp_rate ~ low_quota_implement,
  data = bacon_data_lq_lfp,
  id_var = "province",
  time_var = "year"
)
print(bacon_lq_lfp)
#earlier vs later treated: 29%, later vs earlier treated: 38%, treated vs untreated: 32%
#62% share of clean comparisons

#weighted average of components 
sum(bacon_hq_fs$estimate * bacon_hq_fs$weight)
#confirms decomposition

#Callaway-Sant'Anna estimation 
#low quota implementation of women's representation 
cs_lq_fs <- att_gt(
  yname = "womens_rep", tname = "year", idname = "provincia_cod",
  gname = "low_quota_first_year",
  data = treatment_panel %>% 
    filter(province != "CABA",
           !is.na(womens_rep), year >= 1991),
  control_group = "notyettreated", clustervars = "provincia_cod",
  est_method = "reg"
)
summary(aggte(cs_lq_fs, type = "simple", na.rm = TRUE))
#with the implementation of a low quota, women's representation decreases by 9.93 pp, not statistically significant

#low quota implementation of women's representation (Santiago del Estero excluded)
cs_lq_fs_noSDE <- att_gt(
  yname = "womens_rep", tname = "year", idname = "provincia_cod",
  gname = "low_quota_first_year",
  data = treatment_panel %>% 
    filter(province != "CABA", province != "Santiago del Estero",
           !is.na(womens_rep), year >= 1991),
  control_group = "notyettreated", clustervars = "provincia_cod",
  est_method = "reg"
)
summary(aggte(cs_lq_fs_noSDE, type = "simple", na.rm = TRUE))
#with the implementation of a low quota, women's representation increases by 4.33 pp, not statistically significant

#high quota implementation on women's representation 
cs_hq_fs <- att_gt(
  yname = "womens_rep", tname = "year", idname = "provincia_cod",
  gname = "high_quota_first_year",
  data = treatment_panel %>% 
    filter(province != "CABA", !is.na(womens_rep), year >= 1991,
           high_quota_first_year != 2002),
  control_group = "notyettreated", clustervars = "provincia_cod",
  est_method = "reg"
)
summary(aggte(cs_hq_fs, type = "simple", na.rm = TRUE))
#with the implementation of a high quota, women's representation increases by 13.58 pp, statistically significant

#low quota implementation on female LFP rate 
ml_cs_data <- second_stage_low %>%
  filter(!is.na(lfp_rate)) %>%
  left_join(province_mapping, by = "province") %>%
  left_join(
    treatment_panel %>% select(province, year, low_quota_first_year),
    by = c("province", "year")
  )
#check
table(is.na(ml_cs_data$provincia_cod))
table(is.na(ml_cs_data$low_quota_first_year))

cs_lq_lfp <- att_gt(
  yname = "lfp_rate",
  tname = "year",
  idname = "provincia_cod",
  gname = "low_quota_first_year",
  data = ml_cs_data,
  control_group = "notyettreated",
  clustervars = "provincia_cod",
  est_method = "reg"
)
agg_lq_lfp <- aggte(cs_lq_lfp, type = "simple", na.rm = TRUE)
summary(agg_lq_lfp)
#with the implementation of a low quota, female LFP rate increases by 0.40 pp, not statistically significant

#high quota implementation on housewife rate 
eph_cs_data <- eph_panel_prov_full %>%
  filter(!is.na(housewife_rate)) %>%
  left_join(province_mapping, by = "province") %>%
  left_join(
    treatment_panel %>% select(province, year, high_quota_first_year),
    by = c("province", "year")
  )
#check 
table(is.na(eph_cs_data$provincia_cod))
table(is.na(eph_cs_data$high_quota_first_year))

cs_hq_hw <- att_gt(
  yname = "housewife_rate",
  tname = "year",
  idname = "provincia_cod",
  gname = "high_quota_first_year",
  data = eph_cs_data,
  control_group = "notyettreated",
  clustervars = "provincia_cod",
  est_method = "reg"
)
agg_hq_hw <- aggte(cs_hq_hw, type = "simple", na.rm = TRUE)
summary(agg_hq_hw)
#with the implementation of a high quota, housewife rate decreases by 0.10 pp, not statistically significant

#Granara cross validation for women's representation panel (1989-2011)
#exclude CABA
gr <- path_granararaw %>%
  select(provincia = 1, ingreso = 5, salida = 6) %>%   
  mutate(provincia = str_trim(provincia)) %>%
  filter(!is.na(provincia), !is.na(ingreso), !is.na(salida)) %>%
  mutate(ingreso = as.integer(ingreso), salida = as.integer(salida))

#chamber size per province-year 
chamber_size <- function(prov, y) {
  fixed <- c("BUENOS AIRES"=92,"CBA"=60,"CATAMARCA"=41,"CHACO"=32,"CHUBUT"=27,
             "CORRIENTES"=26,"FORMOSA"=30,"JUJUY"=48,"LA PAMPA"=30,"MENDOZA"=48,
             "MISIONES"=40,"NEUQUEN"=35,"RIO NEGRO"=46,"SALTA"=60,"SAN JUAN"=34,
             "SAN LUIS"=43,"SANTA CRUZ"=24,"SANTA FE"=50,"TIERRA DEL FUEGO"=15)
  if (prov %in% names(fixed)) return(fixed[[prov]])
  if (prov == "CORDOBA")          return(if (y < 2001) 66 else 70)
  if (prov == "ENTRE RIOS")       return(if (y < 2008) 28 else 34)
  if (prov == "LA RIOJA")         return(if (y < 2008) 30 else 36)
  if (prov == "SGO. DEL ESTERO")  return(if (y < 1998) 45 else if (y < 2005) 50 else 40)
  if (prov == "TUCUMAN")          return(if (y < 2006) 40 else 49)
  NA_real_
}
years <- seq(1989, 2009, by = 2)

granara_shares <- expand_grid(provincia = unique(gr$provincia), year = years) %>%
  rowwise() %>%
  mutate(
    women_granara = sum(gr$provincia == provincia & gr$ingreso <= year & gr$salida > year),
    size          = chamber_size(provincia, year),
    share_granara = ifelse(is.na(size), NA, round(100 * women_granara / size, 1))
  ) %>%
  ungroup()

#harmonise province names 
my_shares <- femrep_long %>%
  filter(year %in% years) %>%
  select(Province, year, share_thesis = womens_rep)

#join and compare
comparison <- granara_shares %>%
  mutate(Province = recode(provincia,
                           "CBA" = "CABA", "CORDOBA" = "Cordoba",
                           "SGO. DEL ESTERO" = "Santiago del Estero",
                           "TIERRA DEL FUEGO" = "Tierra del Fuego",
                           "RIO NEGRO" = "Rio Negro", "ENTRE RIOS" = "Entre Rios",
                           "NEUQUEN" = "Neuquen", "TUCUMAN" = "Tucuman",
                           "SAN JUAN" = "San Juan", "SAN LUIS" = "San Luis",
                           "SANTA CRUZ" = "Santa Cruz", "SANTA FE" = "Santa Fe",
                           "LA RIOJA" = "La Rioja", "BUENOS AIRES" = "Buenos Aires",
                           "CATAMARCA"="Catamarca","CHACO"="Chaco","CHUBUT"="Chubut",
                           "CORRIENTES"="Corrientes","FORMOSA"="Formosa","JUJUY"="Jujuy","LA PAMPA" = "La Pampa",
                           "MENDOZA"="Mendoza","MISIONES"="Misiones","SALTA"="Salta")) %>%
  inner_join(my_shares, by = c("Province", "year")) %>%
  mutate(abs_diff = abs(share_granara - share_thesis)) %>%
  filter(!is.na(abs_diff)) %>%
  filter(Province != "CABA")          

comparison %>%
  summarise(n = n(),
            median_diff = median(abs_diff),
            within_5pp  = mean(abs_diff <= 5) * 100)
#252 observations are compared
#the observations differ by a median of 2.1 pp and 79% of the observations are within a 5 pp difference

#largest individual deviations 
comparison %>%
  arrange(desc(abs_diff)) %>%
  select(Province, year, share_thesis, share_granara, abs_diff) %>%
  head(15)
#Cordoba, La Rioja, Tierra del Fuego and Santiago del Estero show individual observations that differ largely

#deviations aggregated by province 
comparison %>%
  group_by(Province) %>%
  summarise(
    cells       = n(),
    mean_diff   = round(mean(abs_diff), 1),
    median_diff = round(median(abs_diff), 1),
    max_diff    = round(max(abs_diff), 1),
    within_5pp  = round(mean(abs_diff <= 5) * 100, 0)
  ) %>%
  arrange(desc(mean_diff)) %>%
  print(n=Inf)
#overall Cordoba, Santiago del Estero and La Rioja show the largest deviations overall
#THE END
