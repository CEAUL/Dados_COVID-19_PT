
![Rendered
README](https://github.com/CEAUL/Dados_COVID-19_PT/workflows/Render%20README/badge.svg)

## Daily Portuguese COVID-19 Data

**Last updated: Fri 09 Apr 2021 (13:56:04 WEST \[+0100\])**

-   Data available from **26 Feb 2020** until **08 Apr 2021** (408
    days).

### Download User Friendly Version

-   Download the user friendly data from:
    **[covid19pt\_DSSG\_Long.csv](https://raw.githubusercontent.com/CEAUL/Dados_COVID-19_PT/master/data/covid19pt_DSSG_Long.csv)**
    or use the following direct link in your program:
    -   <https://raw.githubusercontent.com/CEAUL/Dados_COVID-19_PT/master/data/covid19pt_DSSG_Long.csv>
-   **Variables**
    -   `data`: Date (Portuguese spelling).
    -   `origVars`: Variable name taken from source data.
    -   `origType`: Orginal variable count type.
    -   `other`: Other types of `origVars`.
    -   `symptoms`: Recorded COVID-19 symptoms.
    -   `sex`: Gender (`F` - Females, `M` - Males, `All` - Females &
        Males).
    -   `ageGrp`: Age groups in years (`desconhecidos` - unknown).
    -   `ageGrpLower`: Lower limit of age group (useful for sorting).
    -   `ageGrpUpper`: Upper limit of age group.
    -   `region`: Portuguese Regions
    -   `value`: Numeric value.
    -   `valueUnits`: Units for the variable `value`.

<br>

-   Download the original unprocessed data (json to CSV) from:
    **[covid19pt\_DSSG\_Orig.csv](https://raw.githubusercontent.com/CEAUL/Dados_COVID-19_PT/master/data/covid19pt_DSSG_Orig.csv)**

### Source

For more information about the data and variables see:
**<https://github.com/dssg-pt/covid19pt-data>**

The original data were downloaded from an API provide by VOST
**<https://covid19-api.vost.pt/Requests/get_entry/>**

### Summary: Last 10 (available) Days

|            Date | Cases (7 Day Mean) | Active Cases | Deaths (7 Day Mean) |
|----------------:|-------------------:|-------------:|--------------------:|
| Tue 30 Mar 2021 |        389 (413.3) |        26757 |            2 ( 7.3) |
| Wed 31 Mar 2021 |        617 (419.3) |        26664 |            3 ( 6.1) |
| Thu 01 Apr 2021 |        592 (443.4) |        26543 |           11 ( 6.4) |
| Fri 02 Apr 2021 |        548 (452.0) |        26339 |            9 ( 7.0) |
| Sat 03 Apr 2021 |        280 (442.9) |        26294 |            7 ( 6.9) |
| Sun 04 Apr 2021 |        193 (418.3) |        26134 |            4 ( 6.0) |
| Mon 05 Apr 2021 |        159 (396.9) |        25966 |            6 ( 6.0) |
| Tue 06 Apr 2021 |        874 (466.1) |        25944 |            2 ( 6.0) |
| Wed 07 Apr 2021 |        663 (472.7) |        25847 |            3 ( 6.0) |
| Thu 08 Apr 2021 |        602 (474.1) |        25839 |            9 ( 5.7) |

<img src="README_figs/README-plotNewCases-1.png" width="672" />

## Example Usage

### Read in the data

Using the `data.table` package to process the data.

``` r
# Load Libraries
library(data.table)
library(here)

# Read in data as a data.frame and data.table object.
CVPT <- fread(here("data", "covid19pt_DSSG_Long.csv"))
# You can use the direct link:
# CV <- fread("https://raw.githubusercontent.com/CEAUL/Dados_COVID-19_PT/master/data/covid19pt_DSSG_Long.csv")

# Looking at the key variables in the original long dataset.
CVPT[, .(data, origVars, origType, sex, ageGrp, region, value, valueUnits)]
##              data   origVars   origType sex ageGrp   region value valueUnits
##     1: 2020-02-26     ativos     ativos All        Portugal    NA           
##     2: 2020-02-27     ativos     ativos All        Portugal    NA           
##     3: 2020-02-28     ativos     ativos All        Portugal    NA           
##     4: 2020-02-29     ativos     ativos All        Portugal    NA           
##     5: 2020-03-01     ativos     ativos All        Portugal    NA           
##    ---                                                                      
## 37124: 2021-04-04 vigilancia vigilancia All        Portugal 16960      Count
## 37125: 2021-04-05 vigilancia vigilancia All        Portugal 15928      Count
## 37126: 2021-04-06 vigilancia vigilancia All        Portugal 14842      Count
## 37127: 2021-04-07 vigilancia vigilancia All        Portugal 15787      Count
## 37128: 2021-04-08 vigilancia vigilancia All        Portugal 16182      Count

# Order data by original variable name and date.
setkeyv(CVPT, c("origVars", "data"))

# Convert data to a data object in dataset and add a change from previous day variable.
# Added a 7 day rolling average for origVars (except for symptoms). 
# Columns `data` is date in Portuguese.
CV <- CVPT[, data := as.Date(data, format = "%Y-%m-%d")][
  , dailyChange := value - shift(value, n=1, fill=NA, type="lag"), by = origVars][
    grepl("^sintomas", origVars), dailyChange := NA][
  , mean7Day := fifelse(origVars %chin% c("ativos", "confirmados", "obitos", "recuperados"), 
                         frollmean(dailyChange, 7), as.numeric(NA))]
```

### Overall Number of Deaths (daily)

``` r
library(ggplot2)
library(magrittr)

# Change the ggplot theme.
theme_set(theme_bw())
# Data error prevents by sex plot.
# obMF <- CV[origType=="obitos" & sex %chin% c("M", "F") & ageGrp=="" & region == "Portugal"]
obAll <- CV[origType=="obitos" & sex %chin% c("All") & ageGrp=="" & region == "Portugal"][ 
  , sex := NA]

obAll %>% 
  ggplot(aes(x = data, y = dailyChange)) +
  geom_bar(stat = "identity", fill = "grey75") +
  geom_line(data = obAll, aes(x = data, y = mean7Day), group=1, colour = "brown") +
  scale_x_date(date_breaks = "2 months",
               date_labels = "%b-%y",
               limits = c(min(cvwd$data2, na.rm = TRUE), NA)) +
  scale_y_continuous(breaks = seq(0, max(obAll[, dailyChange], na.rm = TRUE) + 50, 50)) +
  theme(legend.position = "bottom") +
  labs(
    title = "COVID-19 Portugal: Number Daily Deaths with 7 Day Rolling Mean",
    x = "",
    y = "Number of Deaths",
    colour = "",
    fill = "",
    caption = paste0("Updated on: ", format(Sys.time(), "%a %d %b %Y (%H:%M:%S %Z [%z])"))
    )
## Warning: Removed 1 rows containing missing values (position_stack).
## Warning: Removed 7 row(s) containing missing values (geom_path).
```

<img src="README_figs/README-deathsbySex-1.png" width="672" />

### Recorded Number of Confirmed COVID-19 Cases by Age Group

``` r
CV[origType=="confirmados" & !(ageGrp %chin% c("", "desconhecidos"))][
  , .(valueFM = sum(value)), .(data, ageGrp)] %>%
  ggplot(., aes(x=data, y=valueFM, colour = ageGrp)) +
  geom_line() +
  scale_x_date(date_breaks = "2 months",
               date_labels = "%b-%y",
               limits = c(min(cvwd$data2, na.rm = TRUE), NA)) +
  scale_y_continuous() +
  theme(legend.position = "bottom") +
  labs(
    title = "COVID-19 Portugal: Number of Confirmed Cases by Age Group",
    x = "",
    y = "Number of Confirmed Cases",
    caption = paste0("Updated on: ", format(Sys.time(), "%a %d %b %Y (%H:%M:%S %Z [%z])")),
    colour = "Age Group")
## Warning: Removed 54 row(s) containing missing values (geom_path).
```

<img src="README_figs/README-casesbyAgeSex-1.png" width="672" />

### Recorded Number of Confirmed COVID-19 Cases by Region

``` r
CV[origType=="confirmados" & ageGrp=="" & region!="Portugal"] %>%
  ggplot(., aes(x=data, y=value, colour=region)) +
  geom_line() +
  scale_x_date(date_breaks = "2 months",
               date_labels = "%b-%y",
               limits = c(min(cvwd$data2, na.rm = TRUE), NA)) +
  scale_y_log10() +
  theme(legend.position = "bottom") +
  labs(
    title = "COVID-19 Portugal: Number of Confirmed Cases by Region",
    x = "",
    y = "Number of Confirmed Cases",
    caption = paste0("Updated on: ", format(Sys.time(), "%a %d %b %Y (%H:%M:%S %Z [%z])")),
    colour = "Region")
## Warning: Transformation introduced infinite values in continuous y-axis
## Warning: Removed 392 row(s) containing missing values (geom_path).
```

<img src="README_figs/README-casesbyRegion-1.png" width="672" />

<hr>

## Issues & Notes

### Use and interpret with care.

The data are provided as is. Any quality issues or errors in the source
data will be reflected in the user friend data.

Please **create an issue** to discuss any errors, issues, requests or
improvements.

### Calculated change between days can be negative (`dailyChange`).

``` r
CV[dailyChange<0 & !(origType %in% c("vigilancia", "internados"))][
  , .(data, origType, origVars, value, dailyChange)]
##            data    origType              origVars value dailyChange
##   1: 2020-05-12      ativos                ativos 23737        -249
##   2: 2020-05-16      ativos                ativos 23785        -280
##   3: 2020-05-17      ativos                ativos 23182        -603
##   4: 2020-05-18      ativos                ativos 21548       -1634
##   5: 2020-05-22      ativos                ativos 21321        -862
##  ---                                                               
## 541: 2020-04-04      obitos    obitos_arsalentejo     0          -1
## 542: 2020-10-25      obitos     obitos_arsalgarve    25         -10
## 543: 2020-05-23      obitos      obitos_arscentro   230          -3
## 544: 2020-07-03      obitos      obitos_arscentro   248          -1
## 545: 2020-05-21 transmissao transmissao_importada   767          -3
```
