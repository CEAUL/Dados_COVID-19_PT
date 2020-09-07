
![Rendered
README](https://github.com/CEAUL/Dados_COVID-19_PT/workflows/Render%20README/badge.svg)

## Daily Portuguese COVID-19 Data

**Last updated: Mon 07 Sep 2020 (15:28:43 UTC \[+0000\])**

  - Data available from **26 Feb 2020** until **07 Sep 2020** (195
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

|            Date | New\_Cases | Total\_Cases |       Active |    Recovered |    Deaths |
| --------------: | ---------: | -----------: | -----------: | -----------: | --------: |
| Sat 29 Aug 2020 |      \+374 |        57448 | 13864 (+161) | 41766 (+210) | 1818 (+3) |
| Sun 30 Aug 2020 |      \+320 |        57768 | 14064 (+200) | 41885 (+119) | 1819 (+1) |
| Mon 31 Aug 2020 |      \+244 |        58012 | 14229 (+165) |  41961 (+76) | 1822 (+3) |
| Tue 01 Sep 2020 |      \+231 |        58243 |  14315 (+86) | 42104 (+143) | 1824 (+2) |
| Wed 02 Sep 2020 |      \+390 |        58633 | 14573 (+258) | 42233 (+129) | 1827 (+3) |
| Thu 03 Sep 2020 |      \+418 |        59051 | 14795 (+222) | 42427 (+194) | 1829 (+2) |
| Fri 04 Sep 2020 |      \+406 |        59457 | 15048 (+253) | 42576 (+149) | 1833 (+4) |
| Sat 05 Sep 2020 |      \+486 |        59943 | 15312 (+264) | 42793 (+217) | 1838 (+5) |
| Sun 06 Sep 2020 |      \+315 |        60258 | 15465 (+153) | 42953 (+160) | 1840 (+2) |
| Mon 07 Sep 2020 |      \+249 |        60507 | 15648 (+183) |  43016 (+63) | 1843 (+3) |

Change from previous day in brackets.

## Example Usage

### Read in the data

Using the `data.table` package to process the data.

``` r
# Load Libraries
library(data.table)
suppressPackageStartupMessages(library(here)) # library(here)

# Read in data as a data.frame and data.table object.
CV <- fread(here("data", "covid19pt_DSSG_Long.csv"))
# You can use the direct link:
# CV <- fread("https://raw.githubusercontent.com/CEAUL/Dados_COVID-19_PT/master/data/covid19pt_DSSG_Long.csv")

# Looking at the data:
tail(CV)
##          data   origVars   origType other symptoms sex ageGrpLower ageGrpUpper
## 1: 2020-09-02 vigilancia vigilancia                All                        
## 2: 2020-09-03 vigilancia vigilancia                All                        
## 3: 2020-09-04 vigilancia vigilancia                All                        
## 4: 2020-09-05 vigilancia vigilancia                All                        
## 5: 2020-09-06 vigilancia vigilancia                All                        
## 6: 2020-09-07 vigilancia vigilancia                All                        
##    ageGrp   region value valueUnits
## 1:        Portugal 33914      Count
## 2:        Portugal 34197      Count
## 3:        Portugal 34266      Count
## 4:        Portugal 34201      Count
## 5:        Portugal 34240      Count
## 6:        Portugal 34336      Count

# Order data by original variable name and date.
setkeyv(CV, c("origVars", "data"))

# Convert data to a data object in dataset and add a change from previous day variable.
CV[, data := as.Date(data, format = "%Y-%m-%d")][
  , dailyChange := value - shift(value, n=1, fill=NA, type="lag"), by = origVars][
    grepl("^sintomas", origVars), dailyChange := NA]
```

### Overall Number of Deaths (daily) by Sex

``` r
library(ggplot2)
library(magrittr)

# Change the ggplot theme.
theme_set(theme_bw())

CV[origType=="obitos" & sex %in% c("F", "M") & ageGrp==""] %>%
  ggplot(aes(x=data, y=dailyChange, fill=as.factor(sex))) +
  geom_bar(stat = "identity") +
  scale_x_date(date_labels = "%b-%Y") +
  theme(legend.position = "bottom") +
  labs(
    title = "COVID-19 Portugal: Number Daily Deaths",
    x = "Date",
    y = "Number of Deaths",
    fill = "Sex")
## Warning: Removed 56 rows containing missing values (position_stack).
```

<img src="README_figs/README-deathsbySex-1.png" width="672" />

### Recorded Number of Confirmed COVID-19 Cases by Region

``` r
CV[origType=="confirmados" & ageGrp=="" & region!="Portugal"] %>%
  ggplot(., aes(x=data, y=value, colour=region)) +
  geom_line() +
  scale_x_date(date_labels = "%b-%Y") +
  scale_y_log10() +
  theme(legend.position = "bottom") +
  labs(
    title = "COVID-19 Portugal: Number of Confirmed Cases",
    x = "Date",
    y = "Number of Confirmed Cases",
    colour = "Region")
## Warning: Transformation introduced infinite values in continuous y-axis
## Warning: Removed 179 row(s) containing missing values (geom_path).
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
##   1: 2020-03-08     cadeias   cadeias_transmissao     4          -1
##   2: 2020-06-13 confirmados     confirmados_0_9_f   423          -1
##   3: 2020-03-24 confirmados   confirmados_10_19_f    35          -1
##   4: 2020-03-24 confirmados   confirmados_40_49_f   224          -2
##   5: 2020-03-19 confirmados   confirmados_60_69_f    35         -14
##  ---                                                               
## 219: 2020-04-04      obitos    obitos_arsalentejo     0          -1
## 220: 2020-05-23      obitos      obitos_arscentro   230          -3
## 221: 2020-07-03      obitos      obitos_arscentro   248          -1
## 222: 2020-06-20      obitos              obitos_f   768          -1
## 223: 2020-05-21 transmissao transmissao_importada   767          -3
```
