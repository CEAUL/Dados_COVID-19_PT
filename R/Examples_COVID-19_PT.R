# Some example usage for COVID-19 PT data
library(data.table)
library(here)
library(ggplot2)
library(magrittr)

CV <- fread(here("data", "covid19pt_DSSG_Long.csv"))

# Convert data to a data object in dataset
CV[, data := as.Date(data, format = "%Y-%m-%d")]

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

# Deaths by region and sex
CV[origType=="confirmados" & ageGrp=="" & region!="Portugal"] %>%
  ggplot(., aes(x=data, y=value, colour=region)) +
  geom_line() +
  scale_x_date(date_labels = "%b-%Y") +
  scale_y_log10() +
  theme(legend.position = "bottom")

# To be checked. Why do we have negative daily change?
CV[dayChange<0]
