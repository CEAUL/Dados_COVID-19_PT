
![Rendered
README](https://github.com/CEAUL/Dados_COVID-19_PT/workflows/Render%20README/badge.svg)

## Daily Portuguese COVID-19 Data

**Last updated: Mon 21 Sep 2020 (12:02:33 WEST \[+0100\])**

  - Data available from **26 Feb 2020** until **19 Sep 2020** (207
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

|            Date | Cases\_7\_Day\_Mean |        Cases |       Active |    Recovered |     Deaths |
| --------------: | ------------------: | -----------: | -----------: | -----------: | ---------: |
| Thu 10 Sep 2020 |               439.3 | 62126 (+585) | 16833 (+425) | 43441 (+157) |  1852 (+3) |
| Fri 11 Sep 2020 |               479.4 | 62813 (+687) | 17314 (+481) | 43644 (+203) |  1855 (+3) |
| Sat 12 Sep 2020 |               481.0 | 63310 (+497) | 17556 (+242) | 43894 (+250) |  1860 (+5) |
| Sun 13 Sep 2020 |               532.1 | 63983 (+673) | 18047 (+491) | 44069 (+175) |  1867 (+7) |
| Mon 14 Sep 2020 |               584.1 | 64596 (+613) | 18540 (+493) | 44185 (+116) |  1871 (+4) |
| Tue 15 Sep 2020 |               589.4 | 65021 (+425) | 18784 (+244) | 44362 (+177) |  1875 (+4) |
| Wed 16 Sep 2020 |               583.6 | 65626 (+605) | 19220 (+436) | 44528 (+166) |  1878 (+3) |
| Thu 17 Sep 2020 |               610.0 | 66396 (+770) | 19714 (+494) | 44794 (+266) | 1888 (+10) |
| Fri 18 Sep 2020 |               623.3 | 67176 (+780) | 20229 (+515) | 45053 (+259) |  1894 (+6) |
| Sat 19 Sep 2020 |               673.6 | 68025 (+849) | 20722 (+493) | 45404 (+351) |  1899 (+5) |

Change from previous day in brackets.

<img src="README_figs/README-plotNewCases-1.png" width="672" />

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
## 1: 2020-09-14 vigilancia vigilancia                All                        
## 2: 2020-09-15 vigilancia vigilancia                All                        
## 3: 2020-09-16 vigilancia vigilancia                All                        
## 4: 2020-09-17 vigilancia vigilancia                All                        
## 5: 2020-09-18 vigilancia vigilancia                All                        
## 6: 2020-09-19 vigilancia vigilancia                All                        
##    ageGrp   region value valueUnits
## 1:        Portugal 36758      Count
## 2:        Portugal 36955      Count
## 3:        Portugal 37287      Count
## 4:        Portugal 37804      Count
## 5:        Portugal 38721      Count
## 6:        Portugal 39388      Count

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
## Warning: Removed 191 row(s) containing missing values (geom_path).
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
## 223: 2020-04-04      obitos    obitos_arsalentejo     0          -1
## 224: 2020-05-23      obitos      obitos_arscentro   230          -3
## 225: 2020-07-03      obitos      obitos_arscentro   248          -1
## 226: 2020-06-20      obitos              obitos_f   768          -1
## 227: 2020-05-21 transmissao transmissao_importada   767          -3
```
