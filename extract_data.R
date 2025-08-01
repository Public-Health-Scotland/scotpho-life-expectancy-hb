###############################################.
## ScotPHO - Life expectancy - NHS Board ----
###############################################.

# Package installation should only be required to run once
# Data queried directly from SG opendata platform: statistics.gov
# install.packages("devtools")

# install the opendata scotland r package which communicates with the statistics.gov wesbite api
# devtools::install_github("datasciencescotland/opendatascot")

#install phs methods - with new posit workbench requires bespoke installation to ensure phsmethods package can be installed
#install.packages("gdata", repos = c("https://ppm.publichealthscotland.org/phs-cran/latest"))
#install.packages("phsmethods")

library(opendatascot) # to extract from statistics.gov
library(phsmethods)   # to add location names
library(readr)        # to write csv
library(dplyr)        # to get %>% operator
library(tidyr)      # pivot wider
# datasets <- ods_all_datasets() # to see available datasets on statistic.gov.scot

# Setting file permissions to anyone to allow writing/overwriting of project files
Sys.umask("006")

# UPDATE the analyst's folder - where data should be saved for shiny app to run
shiny_folder <- "/PHI_conf/ScotPHO/1.Analysts_space/Vicky/scotpho-life-expectancy-hb/shiny_app/data/"

# UPDATE data file location
data_folder <- "/PHI_conf/ScotPHO/Website/Topics/Life expectancy/202507_update/"

# parameters used to filter the opendata
simd <- c("all")
urban_rural <- c("all")
age_select <- "0-years" #warning this filter restricts dataset "0-years" and "90-years"

###############################################.
# Life expectancy data by HB
###############################################.

ods_structure("Life-Expectancy") # see structure and variables of this dataset

# date range for LE
date_range_le <- c("2001-2003", "2002-2004", "2003-2005", "2004-2006", "2005-2007",
                   "2006-2008", "2007-2009", "2008-2010", "2009-2011", "2010-2012",
                   "2011-2013", "2012-2014", "2013-2015", "2014-2016", "2015-2017", 
                   "2016-2018", "2017-2019", "2018-2020", "2019-2021", "2020-2022","2021-2023") # add most recent year

# extract data
le = ods_dataset("Life-Expectancy", refPeriod = date_range_le, geography = "hb",
                  urbanRuralClassification = urban_rural,
                  simdQuintiles = simd, age=age_select) %>%
  setNames(tolower(names(.))) %>%
  rename("areacode" = refarea, "year" = refperiod) %>% 
  filter(age == age_select) %>% # reapply filter even though its run in opendata extract it must be reapplied
  mutate(areaname = match_area(areacode),
         measure = "Life expectancy",
         sex = case_when(sex == "male" ~ "Male",
                         sex == "female" ~ "Female")) %>%
  select(c("year","areaname","areacode","measure", "sex", "measuretype", "value")) %>%
  pivot_wider(names_from="measuretype", values_from="value") %>%
  rename(value = count,
         lci = "95-lower-confidence-limit",
         uci = "95-upper-confidence-limit") |>
  arrange(year, areaname, sex)

#All data now in stats.gov.scot but leaving script below in case of delays(which have been common)
# 2020-2022 data released as provisional figures not available within stats.gov.scot
# sourced provisional figures from NRS website and manually formatted to allow December 2023 scotpho website update
# https://www.nrscotland.gov.uk/statistics-and-data/statistics/statistics-by-theme/life-expectancy/life-expectancy-in-scotland/life-expectancy-in-scotland-2020-2022
# excel data from fig 5 and fig 6 saved to PHS network folder
# 
# library(openxlsx)
# # open le data 
# le_2020to2022_hb <- read.xlsx("/PHI_conf/ScotPHO/Life Expectancy/Data/Source Data/NRS data/2020 to 2022 provisional life expectancy from NRS website.xlsx", sheet = 1) %>%
#   filter(substr(code,1,3) =="S08") %>%
#   select(areaname,year,measure,sex,le) %>%
#   rename(value=le, nhsboard=areaname)
# 
# # combine stats.gov data with t
# le <- rbind(le, le_2020to2022_hb) %>%   arrange(year, nhsboard, sex)


###############################################.
# Healthy life expectancy data by HB
###############################################.

#Read in hle data sourced from NRS/ONS publication
#csv file prepared in a the Scotland level repo

hle_data <- read.csv(paste0(data_folder, "hle_nhsboard.csv")) |>
  select(-areaname) |>
  mutate(areaname = match_area(areacode)) #match areanames as used by phs


# PRE-July 2025 calculation methodology change HLE data could be sourced from statistics.gov
# Leaving the syntax for data extraction but commented out in case the new data is made available in opendata tool in future
# or in case there is a need to source historic data.

# ods_structure("healthy-life-expectancy") # see structure and variables of this dataset
# 
# # date range for HLE
# date_range_hle <- c("2015-2017", "2016-2018", "2017-2019", "2018-2020", "2019-2021") # add most recent year
# 
# # extract data
# hle = ods_dataset("healthy-life-expectancy", refPeriod = date_range_hle, geography = "hb",
#                   urbanRuralClassification = urban_rural,
#                   simdQuintiles = simd, age=age_select) %>%
#   setNames(tolower(names(.))) %>%
#   rename("hb" = refarea, "year" = refperiod) %>% 
#   filter(age == age_select) %>%
#   mutate(nhsboard = match_area(hb),
#          measure = "Healthy life expectancy",
#          sex = case_when(sex == "male" ~ "Male",
#                          sex == "female" ~ "Female")) |> 
#   select(c("nhsboard","hb","year","sex","measuretype","measure", "value")) %>% 
#   pivot_wider(names_from="measuretype" ,values_from="value") |>
#   rename(value = count,
#          lci = "95-lower-confidence-limit",
#          uci = "95-upper-confidence-limit") |>
#   arrange(year, nhsboard, sex)


# combine datasets
le_hle <- rbind(le, hle_data) %>%
  mutate(value=round(value,2))

# save as csv
write_csv(le_hle, paste0(data_folder, "le_hle_hb.csv"))

# Save data to shiny_app folder
saveRDS(le_hle, file = paste0(shiny_folder,"le_hle_hb.rds"))

# END
