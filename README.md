
![Rendered
README](https://github.com/CEAUL/Dados_COVID-19_PT/workflows/Render%20README/badge.svg)

## Daily Portuguese COVID-19 Data

**Last updated: Tue 29 Sep 2020 (03:21:28 UTC \[+0000\])**

  - Data available from **26 Feb 2020** until **28 Sep 2020** (216
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
| Sat 19 Sep 2020 |               673.6 | 68025 (+849) | 20722 (+493) | 45404 (+351) |  1899 (+5) |
| Sun 20 Sep 2020 |               656.3 | 68577 (+552) | 21069 (+347) | 45596 (+192) | 1912 (+13) |
| Mon 21 Sep 2020 |               657.7 | 69200 (+623) | 21544 (+475) | 45736 (+140) |  1920 (+8) |
| Tue 22 Sep 2020 |               663.1 | 69663 (+463) | 21764 (+220) | 45974 (+238) |  1925 (+5) |
| Wed 23 Sep 2020 |               691.3 | 70465 (+802) | 22247 (+483) | 46290 (+316) |  1928 (+3) |
| Thu 24 Sep 2020 |               680.0 | 71156 (+691) | 22549 (+302) | 46676 (+386) |  1931 (+3) |
| Fri 25 Sep 2020 |               697.0 | 72055 (+899) | 23116 (+567) | 47003 (+327) |  1936 (+5) |
| Sat 26 Sep 2020 |               702.0 | 72939 (+884) | 23615 (+499) | 47380 (+377) |  1944 (+8) |
| Sun 27 Sep 2020 |               718.1 | 73604 (+665) | 24004 (+389) | 47647 (+267) |  1953 (+9) |
| Mon 28 Sep 2020 |               689.9 | 74029 (+425) | 24188 (+184) | 47884 (+237) |  1957 (+4) |

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
CV <- fread(here("data", "covid19pt_DSSG_Long.csv"))
# You can use the direct link:
# CV <- fread("https://raw.githubusercontent.com/CEAUL/Dados_COVID-19_PT/master/data/covid19pt_DSSG_Long.csv")

# Looking at the data:
tail(CV)
##          data   origVars   origType other symptoms sex ageGrpLower ageGrpUpper
## 1: 2020-09-23 vigilancia vigilancia                All                        
## 2: 2020-09-24 vigilancia vigilancia                All                        
## 3: 2020-09-25 vigilancia vigilancia                All                        
## 4: 2020-09-26 vigilancia vigilancia                All                        
## 5: 2020-09-27 vigilancia vigilancia                All                        
## 6: 2020-09-28 vigilancia vigilancia                All                        
##    ageGrp   region value valueUnits
## 1:        Portugal 40765      Count
## 2:        Portugal 41696      Count
## 3:        Portugal 42785      Count
## 4:        Portugal 43583      Count
## 5:        Portugal 44274      Count
## 6:        Portugal 44171      Count

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
## Warning: Removed 200 row(s) containing missing values (geom_path).
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
## 227: 2020-04-04      obitos    obitos_arsalentejo     0          -1
## 228: 2020-05-23      obitos      obitos_arscentro   230          -3
## 229: 2020-07-03      obitos      obitos_arscentro   248          -1
## 230: 2020-06-20      obitos              obitos_f   768          -1
## 231: 2020-05-21 transmissao transmissao_importada   767          -3
```
