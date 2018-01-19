# Day_1.R
# Aim: the practice R
# Objective: Do various data manipulations, analyses and graphs
# AJ Smit
# 15 January 2018
# 

# looking at the data
library(tidyverse)
laminaria <- read_csv("data/laminaria.csv")
head(laminaria, 20)
tail(laminaria, 7)
summary(laminaria)

glimpse(laminaria)
names(laminaria)

# What sites are available?
laminaria %>% 
  select(site) %>% 
  unique()

# selctig an filtering data
# Taking columns:

sub_sites <- c("Kommetjie", "Bordjiestif North", "Olifantsbos")

lam_sub <- laminaria %>% 
  select(region, site, blade_weight, blade_length, blade_thickness) %>% 
  filter(site %in% sub_sites) %>% 
  slice(10:15)

laminaria %>%
  filter(site == "Kommetjie" | site == "Bordjiestif North") 

laminaria %>%
  filter(site == "Kommetjie") %>%
  nrow()

laminaria %>%
  group_by(site) %>%
  summarise(tck_m = mean(blade_thickness, na.rm = TRUE),
            tck_sd = sd(blade_thickness, na.rm = TRUE),
            tck_min = min(blade_thickness),
            tck_max = max(blade_thickness))

ggplot(data = laminaria, aes(x = stipe_mass, y = stipe_length, group = site)) +
  geom_line(col = "salmon", fill = "white") +
  facet_wrap(~site, nrow = 4) +
  labs(x = "Stipe mass (kg)", y = "Stipe length (cm)") + theme_bw()
