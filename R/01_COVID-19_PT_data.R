# Downloading, cleaning and making the Portuguese COVID-19 available in a user
# friend format.

# Load (attach) libraries
library(here)
library(jsonlite)
library(magrittr)
library(data.table)
library(RCurl)

##
## Download latest data
##

# The data source is originally from https://github.com/dssg-pt/covid19pt-data

# The API uses date formatted as DD-MM-YYYY (all numberic)
  stemUrl <- "https://covid19-api.vost.pt/Requests/get_entry/"

# The source data starts from 26th Feb 2020.
  startDay <-  as.Date("2020-02-26", format = "%Y-%m-%d")
  endDay <- Sys.Date()
  cvDayYMD <- format(seq(startDay, endDay, by="days"), "%Y-%m-%d")
  cvDayDMY <- format(seq(startDay, endDay, by="days"), "%d-%m-%Y")

  # Directory to store the raw JSON data.
  rawDataDir <- "data-raw"

  # Creating a dataset to track downloads and existing JSON files.
  covidPT <-  as.data.table(cvDayDMY, cvDayYMD)[
    , cvURL := paste0(stemUrl, cvDayDMY)][
    , jsonFile := paste0(cvDayYMD, "_covid19pt-DSSG.json")][
    , existsURL := url.exists(cvURL)][
    , existsJSON := file.exists(here(rawDataDir, jsonFile))]

  cat("\n << QC Check (1) >> \n")
  covidPT[, .(N=.N), .(existsURL, existsJSON)]

  # Download the JSON files that are not available.
  dlJSON <- covidPT[existsURL==TRUE & existsJSON==FALSE]

  if (dim(dlJSON)[1]!=0){
    download.file(dlJSON$cvURL, destfile = here("data-raw", dlJSON$jsonFile))
  } else {message("Raw JSON data up to date")}

  # QC:: Update tracking dataset to confirm available files and empty files
  covidPT[, existsRaw := file.exists(here(rawDataDir, jsonFile))][
    , fileSize := file.size(here(rawDataDir, jsonFile))][
    , emptyFile := ifelse(fileSize == 0, "Empty", "Not Empty")]

  cat("\n << QC Check (2) >> \n")
  covidPT[, .(N=.N), .(existsURL, existsRaw, emptyFile)]

##
##  Part 2: Cleaning the data to make it user friendly
##
  # Use the downloaded raw json data.
  rawFiles <- list.files(path=here(rawDataDir), full.names = TRUE)

  allDays <- lapply(rawFiles, fromJSON, simplifyVector = TRUE) %>%
    rbindlist(., fill = TRUE, idcol = TRUE) %>%
    lapply(., as.character) %>%
    as.data.table(.)

 cvpt <- melt(allDays,
              id = c(".id", "data", "data_dados"),
              variable.name = "origVars",
              value.name = "count",
              variable.factor = FALSE,
              value.factor = FALSE)
  # List of regions to be used later.
  #_# QC ISSUE: Alentejo has two codings "alentejo", "arsalentejo".
  regionsList <- c("arsnorte", "arscentro", "arslvt", "alentejo", "arsalentejo",
                   "arsalgarve", "acores", "madeira", "estrangeiro")

  cvpt[, origType := tstrsplit(origVars, "_", fixed=TRUE, keep = 1)][
    # Create variable for sex ("F", "M" & "All")
    , sex := ifelse(grepl("_f$|_m$", origVars),
                    toupper(substring(origVars, nchar(origVars))), "All")][
    # Create age group variables.
    grepl("[0-9]", origVars)
      , c("ageGrpLower", "ageGrpUpper") := tstrsplit(origVars, "_", fixed=TRUE, keep = 2:3)][
    grepl("desconhecidos", origVars)
        , `:=` (ageGrpLower = "desconhecidos", ageGrpUpper = "desconhecidos")][
    # Create variables for region
    , tempRegion := tstrsplit(origVars, "_", fixed=TRUE, keep = 2)][
    , `:=` (region = ifelse(tempRegion %in% regionsList, tempRegion, "Portugal"),
            tempRegion = NULL)][
    # Create a variable for symptoms
    origType=="sintomas", symptoms := gsub("_", " ", gsub("sintomas_", "", origVars))][
    # Other types not cover above
    region=="Portugal" & is.na(symptoms) & sex=="All" & origVars!=origType, other := origVars][
    # Convert count to numeric
    , value := as.numeric(count)][
    , .(.id, data, data_dados, origVars, origType, sex, ageGrpLower, ageGrpUpper,
        region, symptoms, other, value)]

  cv <- dcast(cvpt,
              .id + data + data_dados + sex + ageGrpLower + ageGrpUpper + region + symptoms + other ~ origType,
              value.var = c("value"))

  # Write the date to CSV files
  fwrite(cv, file = here("data", "covid19pt_DSSG.csv"))
  fwrite(cvpt, file = here("data", "covid19pt_DSSG_Long.csv"))



### Test zone
  # oVars <- sort(unique(cvpt$origVars))
  # oVars[grepl("[0-9]", oVars)]

  # checkData <- cvpt[, .(N=.N), .(origVars, origType, ageGrpLower, ageGrpUpper, sex, region, symptoms, other)][
  #   order(origVars)]
  #
  # c2 <- checkData[region=="Portugal" & is.na(symptoms) & sex=="All"]
