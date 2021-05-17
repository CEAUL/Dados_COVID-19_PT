
![Rendered
README](https://github.com/CEAUL/Dados_COVID-19_PT/workflows/Render%20README/badge.svg)

## Daily Portuguese COVID-19 Data

**Last updated: Mon 17 May 2021 (03:26:20 UTC \[+0000\])**

  - Data available from **26 Feb 2020** until **16 May 2021** (446
    days).

### Download User Friendly Version

  - Download the user friendly data from:
    **[covid19pt\_DSSG\_Long.csv](https://raw.githubusercontent.com/CEAUL/Dados_COVID-19_PT/master/data/covid19pt_DSSG_Long.csv)**
    or use the following direct link in your program:
      - <https://raw.githubusercontent.com/CEAUL/Dados_COVID-19_PT/master/data/covid19pt_DSSG_Long.csv>
  - **Variables**
      - `data`: Date (Portuguese spelling).
      - `origVars`: Variable name taken from source data.
      - `origType`: Orginal variable count type.
      - `other`: Other types of `origVars`.
      - `symptoms`: Recorded COVID-19 symptoms.
      - `sex`: Gender (`F` - Females, `M` - Males, `All` - Females &
        Males).
      - `ageGrp`: Age groups in years (`desconhecidos` - unknown).
      - `ageGrpLower`: Lower limit of age group (useful for sorting).
      - `ageGrpUpper`: Upper limit of age group.
      - `region`: Portuguese Regions
      - `value`: Numeric value.
      - `valueUnits`: Units for the variable `value`.

<br>

  - Download the original unprocessed data (json to CSV) from:
    **[covid19pt\_DSSG\_Orig.csv](https://raw.githubusercontent.com/CEAUL/Dados_COVID-19_PT/master/data/covid19pt_DSSG_Orig.csv)**

### Source

For more information about the data and variables see:
**<https://github.com/dssg-pt/covid19pt-data>**

The original data were downloaded from an API provide by VOST
**<https://covid19-api.vost.pt/Requests/get_entry/>**

### Summary: Last 10 (available) Days

|            Date | Cases (7 Day Mean) | Active Cases | Deaths (7 Day Mean) |
| --------------: | -----------------: | -----------: | ------------------: |
| Fri 07 May 2021 |        377 (337.0) |        22421 |            1 ( 2.1) |
| Sat 08 May 2021 |        406 (330.1) |        22260 |            2 ( 2.1) |
| Sun 09 May 2021 |        324 (329.3) |        22313 |            1 ( 2.1) |
| Mon 10 May 2021 |        158 (326.1) |        22102 |            1 ( 2.3) |
| Tue 11 May 2021 |        268 (327.6) |        21708 |            1 ( 1.9) |
| Wed 12 May 2021 |        485 (341.6) |        21874 |            4 ( 2.1) |
| Thu 13 May 2021 |        436 (350.6) |        21969 |            1 ( 1.6) |
| Fri 14 May 2021 |        450 (361.0) |        22095 |            0 ( 1.4) |
| Sat 15 May 2021 |        469 (370.0) |        22171 |            7 ( 2.1) |
| Sun 16 May 2021 |        334 (371.4) |        22275 |            1 ( 2.1) |

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
## 40582: 2021-05-12 vigilancia vigilancia All        Portugal 19618      Count
## 40583: 2021-05-13 vigilancia vigilancia All        Portugal 19111      Count
## 40584: 2021-05-14 vigilancia vigilancia All        Portugal 18967      Count
## 40585: 2021-05-15 vigilancia vigilancia All        Portugal 18793      Count
## 40586: 2021-05-16 vigilancia vigilancia All        Portugal 18808      Count

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
  scale_y_continuous(labels = scales::number_format(big.mark = ",")) +
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
  scale_y_log10(labels = scales::number_format(big.mark = ",")) +
  theme(legend.position = "bottom") +
  labs(
    title = "COVID-19 Portugal: Number of Confirmed Cases by Region",
    x = "",
    y = "Number of Confirmed Cases",
    caption = paste0("Updated on: ", format(Sys.time(), "%a %d %b %Y (%H:%M:%S %Z [%z])")),
    colour = "Region")
## Warning: Transformation introduced infinite values in continuous y-axis
## Warning: Removed 430 row(s) containing missing values (geom_path).
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
##            data    origType              origVars    value dailyChange
##   1: 2020-05-12      ativos                ativos 23737.00     -249.00
##   2: 2020-05-16      ativos                ativos 23785.00     -280.00
##   3: 2020-05-17      ativos                ativos 23182.00     -603.00
##   4: 2020-05-18      ativos                ativos 21548.00    -1634.00
##   5: 2020-05-22      ativos                ativos 21321.00     -862.00
##  ---                                                                  
## 633: 2021-04-30          rt           rt_nacional     0.98       -0.02
## 634: 2021-05-03          rt           rt_nacional     0.96       -0.02
## 635: 2021-05-05          rt           rt_nacional     0.95       -0.01
## 636: 2021-05-07          rt           rt_nacional     0.92       -0.03
## 637: 2020-05-21 transmissao transmissao_importada   767.00       -3.00
```
