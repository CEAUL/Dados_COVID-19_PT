
# Portuguese COVID-19 Data

## Source

For more information about the data and varaibles see
(<https://github.com/dssg-pt/covid19pt-data>)

The original data were downloaded from an API provide by VOST
(<https://covid19-api.vost.pt/Requests/get_entry/>)

## User Friendly version.

This repository intends to provide a user friendly CSV version of the
Portuguse COVID-19 data (updated daily - once automated). Download the
user friendly version
    from:

  - [covid19pt\_DSSG\_Long.csv](https://raw.githubusercontent.com/saghirb/Dados_COVID-19_PT/master/data/covid19pt_DSSG_Long.csv)

# Example Usage

## Read in the data

Using the `data.table` package to process the data.

``` r
# Load Libraries
library(data.table)
library(here)
## here() starts at /home/saghir/Documents/saghirb/Github/Dados_COVID-19_PT
library(ggplot2)
library(magrittr)


CV <- fread(here("data", "covid19pt_DSSG_Long.csv"))
# Convert data to a data object in dataset
CV[, data := as.Date(data, format = "%Y-%m-%d")]
```

## Overall Number of Deaths (daily) by Sex

``` r
CV[origType=="obitos" & sex %in% c("F", "M") & ageGrp==""] %>%
  ggplot(aes(x=data, y=dayChange, fill=as.factor(sex))) +
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

## Recorded Number of Confirmed COVID-19 Cases by Region

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
    y = "Number of Confirmed cases",
    colour = "Region")
## Warning: Transformation introduced infinite values in continuous y-axis
## Warning: Removed 96 row(s) containing missing values (geom_path).
```

<img src="README_figs/README-casesbyRegion-1.png" width="672" />
