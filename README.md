
![Rendered
README](https://github.com/CEAUL/Dados_COVID-19_PT/workflows/Render%20README/badge.svg)

## Daily Portuguese COVID-19 Data

**Last updated: Tue 13 Oct 2020 (16:11:48 UTC \[+0000\])**

  - Data available from **26 Feb 2020** until **12 Oct 2020** (230
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

|            Date | Cases\_7\_Day\_Mean |         Cases |        Active |    Recovered |     Deaths |
| --------------: | ------------------: | ------------: | ------------: | -----------: | ---------: |
| Sat 03 Oct 2020 |               758.3 |  78247 (+963) |  26407 (+465) | 49845 (+486) | 1995 (+12) |
| Sun 04 Oct 2020 |               792.4 |  79151 (+904) |  26939 (+532) | 50207 (+362) | 2005 (+10) |
| Mon 05 Oct 2020 |               836.6 |  79885 (+734) |  27413 (+474) | 50454 (+247) | 2018 (+13) |
| Tue 06 Oct 2020 |               799.3 |  80312 (+427) |  27568 (+155) | 50712 (+258) | 2032 (+14) |
| Wed 07 Oct 2020 |               816.3 |  81256 (+944) |  28179 (+611) | 51037 (+325) |  2040 (+8) |
| Thu 08 Oct 2020 |               876.9 | 82534 (+1278) |  28967 (+788) | 51517 (+480) | 2050 (+10) |
| Fri 09 Oct 2020 |               949.1 | 83928 (+1394) |  29702 (+735) | 52164 (+647) | 2062 (+12) |
| Sat 10 Oct 2020 |              1046.7 | 85574 (+1646) | 30704 (+1002) | 52803 (+639) |  2067 (+5) |
| Sun 11 Oct 2020 |              1073.3 | 86664 (+1090) |  31397 (+693) | 53187 (+384) | 2080 (+13) |
| Mon 12 Oct 2020 |              1146.9 | 87913 (+1249) |  32321 (+924) | 53498 (+311) | 2094 (+14) |

Change from previous day in brackets.

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

# Looking at the data:
tail(CVPT)
##          data   origVars   origType other symptoms sex ageGrpLower ageGrpUpper
## 1: 2020-10-07 vigilancia vigilancia                All                        
## 2: 2020-10-08 vigilancia vigilancia                All                        
## 3: 2020-10-09 vigilancia vigilancia                All                        
## 4: 2020-10-10 vigilancia vigilancia                All                        
## 5: 2020-10-11 vigilancia vigilancia                All                        
## 6: 2020-10-12 vigilancia vigilancia                All                        
##    ageGrp   region value valueUnits
## 1:        Portugal 46023      Count
## 2:        Portugal 46182      Count
## 3:        Portugal 47721      Count
## 4:        Portugal 47602      Count
## 5:        Portugal 48413      Count
## 6:        Portugal 48844      Count

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

### Overall Number of Deaths (daily) by Sex

``` r
library(ggplot2)
library(magrittr)

# Change the ggplot theme.
theme_set(theme_bw())
obMF <- CV[origType=="obitos" & sex %chin% c("M", "F") & ageGrp=="" & region == "Portugal"]
obAll <- CV[origType=="obitos" & sex %chin% c("All") & ageGrp=="" & region == "Portugal"][ 
  , sex := NA]

obMF %>% 
  ggplot(aes(x=data, y=dailyChange, fill = sex)) +
  geom_bar(stat = "identity") +
  geom_line(data = obAll, aes(x = data, y = mean7Day), group=1) +
  scale_x_date(date_breaks = "1 months",
               date_labels = "%b-%y",
               limits = c(min(cvwd$data2, na.rm = TRUE), NA)) +
  theme(legend.position = "bottom") +
  labs(
    title = "COVID-19 Portugal: Number Daily Deaths with 7 Day Rolling Mean",
    x = "",
    y = "Number of Deaths",
    fill = "Sex",
    colour = "",
    caption = paste0("Updated on: ", format(Sys.time(), "%a %d %b %Y (%H:%M:%S %Z [%z])"))
    )
## Warning: Removed 64 rows containing missing values (position_stack).
## Warning: Removed 7 row(s) containing missing values (geom_path).
```

<img src="README_figs/README-deathsbySex-1.png" width="672" />

### Recorded Number of Confirmed COVID-19 Cases by Region

``` r
CV[origType=="confirmados" & ageGrp=="" & region!="Portugal"] %>%
  ggplot(., aes(x=data, y=value, colour=region)) +
  geom_line() +
  scale_x_date(date_breaks = "1 months",
               date_labels = "%b-%y",
               limits = c(min(cvwd$data2, na.rm = TRUE), NA)) +
  scale_y_log10() +
  theme(legend.position = "bottom") +
  labs(
    title = "COVID-19 Portugal: Number of Confirmed Cases",
    x = "",
    y = "Number of Confirmed Cases",
    caption = paste0("Updated on: ", format(Sys.time(), "%a %d %b %Y (%H:%M:%S %Z [%z])")),
    colour = "Region")
## Warning: Transformation introduced infinite values in continuous y-axis
## Warning: Removed 214 row(s) containing missing values (geom_path).
```

<img src="README_figs/README-casesbyRegion-1.png" width="672" />

### Recorded Number of Confirmed COVID-19 Cases by Age Group and Sex

``` r
CV[origType=="confirmados" & !(ageGrp %chin% c("", "desconhecidos"))] %>%
  ggplot(., aes(x=data, y=value, colour = ageGrp)) +
  geom_line() +
  facet_grid(sex~.) +
  scale_x_date(date_breaks = "2 months",
               date_labels = "%b-%y",
               limits = c(min(cvwd$data2, na.rm = TRUE), NA)) +
  scale_y_log10(limits = c(10, 10000)) +
  theme(legend.position = "right") +
  labs(
    title = "COVID-19 Portugal: Number of Confirmed Cases",
    x = "",
    y = "Number of Confirmed Cases",
    caption = paste0("Updated on: ", format(Sys.time(), "%a %d %b %Y (%H:%M:%S %Z [%z])")),
    colour = "")
## Warning: Transformation introduced infinite values in continuous y-axis
## Warning: Removed 54 row(s) containing missing values (geom_path).
```

<img src="README_figs/README-casesbyAgeSex-1.png" width="672" />

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
##   1: 2020-03-08     cadeias   cadeias_transmissao     4          -1
##   2: 2020-06-13 confirmados     confirmados_0_9_f   423          -1
##   3: 2020-03-24 confirmados   confirmados_10_19_f    35          -1
##   4: 2020-03-24 confirmados   confirmados_40_49_f   224          -2
##   5: 2020-03-19 confirmados   confirmados_60_69_f    35         -14
##  ---                                                               
## 233: 2020-04-04      obitos    obitos_arsalentejo     0          -1
## 234: 2020-05-23      obitos      obitos_arscentro   230          -3
## 235: 2020-07-03      obitos      obitos_arscentro   248          -1
## 236: 2020-06-20      obitos              obitos_f   768          -1
## 237: 2020-05-21 transmissao transmissao_importada   767          -3
```
