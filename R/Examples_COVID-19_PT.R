# Some example usage for COVID-19 PT data
library(data.table)
library(here)
library(ggplot2)
library(magrittr)

# Change the ggplot theme.
theme_set(theme_bw())

# Read in data as a data.frame and data.table object.
CV <- fread(here("data", "covid19pt_DSSG_Long.csv"))

# Order data by original variable name and date.
setkeyv(CV, c("origVars", "data"))

# Convert data to a data object in dataset and add a change from previous day variable.
CV[, data := as.Date(data, format = "%Y-%m-%d")][
  , dayChange := value - shift(value, n=1, fill=NA, type="lag"), by = origVars][
  grepl("^sintomas", origVars), dayChange := NA]

# Overall number of Deaths (cumulative)
CV[origVars=="obitos" & sex=="All"] %>%
  ggplot(aes(x=data, y=value)) +
  geom_line() +
  scale_x_date(date_labels = "%b-%Y")

# Overall number of Deaths (daily) by Sex
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

# Overall number of Deaths (daily) by Age Group
CV[origType=="obitos" & sex %in% c("F", "M") & ageGrp!=""] %>%
  ggplot(aes(x=data, y=dayChange, fill=as.factor(ageGrp))) +
  geom_bar(stat = "identity") +
  scale_x_date(date_labels = "%b-%Y") +
  theme(legend.position = "bottom") +
  facet_grid(sex~.) +
  labs(
    title = "COVID-19 Portugal: Number Daily Deaths",
    x = "Date",
    y = "Number of Deaths",
    fill = "Age Group")


# Deaths by age group and sex
CV[origType=="obitos" & sex %in% c("F", "M") & ageGrp!=""] %>%
  ggplot(aes(x=data, y=value, colour=ageGrp)) +
  geom_line() +
  scale_x_date(date_labels = "%b-%Y") +
  scale_y_log10() +
  facet_grid(sex~.) +
  theme(legend.position = "bottom")

# Recorded number of COVID-19 cases by Region
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

# What is the maximum number of deaths on any given day by region.
CV[origType=="obitos" & ageGrp=="" & region!="Portugal",
   .(max=max(dayChange, na.rm=TRUE)), .(region)]

# What is the maximum number of reported cases on any given day by region.
CV[origType=="confirmados" & ageGrp=="" & region!="Portugal",
   .(max=max(dayChange, na.rm=TRUE)), .(region)]


# To be checked. Why do we have negative daily change?
CV[dayChange<0]
