###############################################.
## ScotPHO - Life expectancy - NHS Board ----
###############################################.

# Firstly, update the data in the 'HLE ScotPHO Web Section' folder (see below) - the
# data is extracted from the SG opendata platform.
# Then run this code to save the updated data file into analyst's folder for running the shiny app

# data queried directly from statistics.gov
# install the opendata scotland r package which communicates with the statistics.gov wesbite api
# install.packages("devtools")

devtools::install_github("datasciencescotland/opendatascot")

library(opendatascot) # to extract from statistics.gov
library(phsmethods)   # to add location names
library(readr)        # to write csv

# datasets <- ods_all_datasets() # to see available datasets on statistic.gov.scot
  
# UPDATE the analyst's folder - where data should be saved for shiny app to run
shiny_folder <- "/PHI_conf/ScotPHO/1.Analysts_space/Catherine/scotpho-life-expectancy-hb/shiny_app/data/"

# updated data file location
data_folder <- "/PHI_conf/ScotPHO/Life Expectancy/HLE ScotPHO Web Section/Scotland/"



# parameters used to filter the opendata
simd <- c("all")
urban_rural <- c("all")
age_select <- "0-years"


###############################################.
# Healthy life expectancy data by HB
###############################################.

ods_structure("healthy-life-expectancy") # see structure and variables of this dataset

# date range for HLE
date_range_hle <- c("2015-2017", "2016-2018", "2017-2019", "2018-2020") # add most recent year

# extract data
hle = ods_dataset("healthy-life-expectancy", refPeriod = date_range_hle, geography = "hb",
                  urbanRuralClassification = urban_rural,
                  simdQuintiles = simd, measureType = "count") %>%
  setNames(tolower(names(.))) %>%
  rename("hb" = refarea, "year" = refperiod) %>% 
  filter(age == age_select) %>% 
  mutate(measure = "Healthy life expectancy") %>% 
  mutate(nhsboard = match_area(hb),
         sex = case_when(sex == "male" ~ "Male",
                         sex == "female" ~ "Female")) %>% 
  select(c("nhsboard", "year", "measure", "value", "sex")) %>% 
  arrange(year, nhsboard, sex)


###############################################.
# Life expectancy data by HB
###############################################.

ods_structure("Life-Expectancy") # see structure and variables of this dataset

# date range for LE
date_range_le <- c("2001-2003", "2002-2004", "2003-2005", "2004-2006", "2005-2007",
                   "2006-2008", "2007-2009", "2008-2010", "2009-2011", "2010-2012",
                   "2011-2013", "2012-2014", "2013-2015", "2014-2016", "2015-2017", 
                   "2016-2018", "2017-2019", "2018-2020", "2019-2021") # add most recent year

# extract data
le = ods_dataset("Life-Expectancy", refPeriod = date_range_le, geography = "hb",
                  urbanRuralClassification = urban_rural,
                  simdQuintiles = simd, measureType = "count") %>%
  setNames(tolower(names(.))) %>%
  rename("hb" = refarea, "year" = refperiod) %>% 
  filter(age == age_select) %>% 
  mutate(measure = "Life expectancy") %>% 
  mutate(nhsboard = match_area(hb),
         sex = case_when(sex == "male" ~ "Male",
                         sex == "female" ~ "Female")) %>% 
  select(c("nhsboard", "year", "measure", "value", "sex")) %>% 
  arrange(year, nhsboard, sex)



# combine datasets
le_hle <- rbind(le, hle)

# save as csv
write_csv(le_hle, paste0(data_folder, "le_hle_hb.csv"))

# Save data to shiny_app folder
saveRDS(le_hle, file = paste0(shiny_folder,"le_hle_hb.rds"))

# END