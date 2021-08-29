# install.packages("lubridate")
install.packages("Quandl")
# install.packages("googlesheets4")
require(tidyverse)
require(Quandl)
require(lubridate)
require(googlesheets4)
# gs4_deauth()
require(googledrive)
drive_auth(path = "client_secret_734281512420-r1u6eramvot4c3lt2ksbn9qe1q5193o9.apps.googleusercontent.com.json",
           email = "joel@quantreports.com")

# install.packages("writexl")
# library(writexl)
# library(googleCloudRunner)

#--- GCP Setup ----

# cr_bucket_set("watchful-ripple-320400")
# 
# # --- Docker package ----
# 
# remotes::install_github("o2r-project/containerit")
# suppressPackageStartupMessages(library("containerit"))
# my_dockerfile <- containerit::dockerfile(from = utils::sessionInfo())
# print(my_dockerfile)
# 
# rmd_dockerfile <- containerit::dockerfile(from = "inst/demo.Rmd",
#                                           image = "rocker/verse:3.5.2",
#                                           maintainer = "o2r",
#                                           filter_baseimage_pkgs = TRUE)
# #> Detected API version '1.40' is above max version '1.39'; downgrading
# print(rmd_dockerfile)


rbaData <- NULL
apiKey <- "6xnM-wtV_zGKeyEWRB7H"

#---- Per Annum Percentages

pa1Perc <- 1.01^(1/12)-1
pa2Perc <- 1.02^(1/12)-1
pa3Perc <- 1.03^(1/12)-1
pa3_5Perc <- 1.035^(1/12)-1
pa4Perc <- 1.04^(1/12)-1
pa5Perc <- 1.05^(1/12)-1
pa6Perc <- 1.06^(1/12)-1
pa7Perc <- 1.07^(1/12)-1
pa8Perc <- 1.08^(1/12)-1
pa9Perc <- 1.09^(1/12)-1
pa10Perc <- 1.10^(1/12)-1

cashRateTarget <- Quandl('RBA/F01_FIRMMCRTD', type = "raw", api_key=apiKey) %>% as_tibble() 
names(cashRateTarget)[2] <- "CashRateT"



#---- RBA Cash Rate 

RBACashRate <- cashRateTarget %>%
  arrange(Date) %>%
  group_by(month_date=ceiling_date(Date, "month_date") -days(1)) %>%
  summarize(CashRateTarget = mean(CashRateT)) %>%
  mutate(RBACash = CashRateTarget * 1/12) %>% #RBA Cash Rate monthly
  mutate(RBACash_1 = CashRateTarget * 1/12 + pa1Perc) %>% #RBA Cash Rate + 1% per annum
  mutate(RBACash_2 = CashRateTarget * 1/12 + pa2Perc) %>%
  mutate(RBACash_3 = CashRateTarget * 1/12 + pa3Perc) %>%
  mutate(RBACash_4 = CashRateTarget * 1/12 + pa4Perc) %>%
  mutate(RBACash_5 = CashRateTarget * 1/12 + pa5Perc) %>%
  mutate(RBACash_6 = CashRateTarget * 1/12 + pa6Perc) %>%
  mutate(RBACash_7 = CashRateTarget * 1/12 + pa7Perc) %>%
  mutate(RBACash_8 = CashRateTarget * 1/12 + pa8Perc) %>%
  mutate(RBACash_9 = CashRateTarget * 1/12 + pa9Perc) %>%
  mutate(RBACash_10 = CashRateTarget * 1/12 + pa10Perc) %>%
  rename("Date" = month_date) %>%
  select(-CashRateTarget) 

#---- Bank Accepted Bills 1M 

BAB1M <- Quandl('RBA/F01_FIRMMBAB30D', type = "raw", api_key=apiKey) %>% as_tibble()
names(BAB1M)[2] <- "BABs_1M"

BAB1M <- BAB1M %>%
  arrange(Date) %>%
  group_by(month_date=ceiling_date(Date, "month_date") -days(1)) %>%
  summarise(BAB1Month = mean(BABs_1M)) %>%
  mutate(BABMonthly = BAB1Month * 1/12) %>%
  mutate(BAB1M_1 = BABMonthly + pa1Perc) %>%
  mutate(BAB1M_2 = BABMonthly + pa2Perc) %>%
  mutate(BAB1M_3 = BABMonthly + pa3Perc) %>%
  mutate(BAB1M_4 = BABMonthly + pa4Perc) %>%
  mutate(BAB1M_5 = BABMonthly + pa5Perc) %>%
  mutate(BAB1M_6 = BABMonthly + pa6Perc) %>%
  mutate(BAB1M_7 = BABMonthly + pa7Perc) %>%
  mutate(BAB1M_8 = BABMonthly + pa8Perc) %>%
  mutate(BAB1M_9 = BABMonthly + pa9Perc) %>%
  mutate(BAB1M_10 = BABMonthly + pa10Perc) %>%
  rename("Date" = month_date) %>%
  select(-BAB1Month)

rbaData <- left_join(RBACashRate, BAB1M)


#--- Consumer Price Index CPI 

CPI <- Quandl('RBA/G01_GCPIAGSAQP', type = "raw", api_key=apiKey) %>% as_tibble() 
names(CPI)[2] <- "CPI"

CPI <- CPI %>%
  select(Date, CPI) %>%
  arrange(Date) %>%
  filter(Date >= "1999-01-01") %>%
  mutate(CPI_0 = CPI * 1/3) %>%
  select(-CPI)

rbaData <- left_join(rbaData, CPI)

rbaData <- rbaData %>%
  fill(CPI_0, .direction = "down")

print(rbaData)

write_sheet(rbaData, ss = "https://docs.google.com/spreadsheets/d/1MyO49dzslAyMilo33we-cPE1jwMVoun2Evs2K67jMXc/edit?usp=sharing", 
            sheet = "output")

# write_xlsx(rbaData, "rbaData.xlsx")

