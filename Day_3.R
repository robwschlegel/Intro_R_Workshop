# Day_3.R

# AJ Smit
# A session showing how to use ggplot2 to produce nice maps.

# Load libraries ----------------------------------------------------------
library(tidyverse)


# Load data ---------------------------------------------------------------
load("data/south_africa_coast.RData")
load("data/sa_provinces.RData")
load("data/rast_annual.RData")
load("data/MUR.RData")
# load("data/MUR_low_res.RData")


# Ways of looking at the data ---------------------------------------------
names(sa_provinces)
head(rast_annual, 5)
glimpse(MUR)


# The colours -------------------------------------------------------------
# The colour pallette we will use for ocean temperature
cols11 <- c("#004dcd", "#0068db", "#007ddb", "#008dcf", "#009bbc",
            "#00a7a9", "#1bb298", "#6cba8f", "#9ac290", "#bec99a")



# Point plot --------------------------------------------------------------
ggplot(data = south_africa_coast, aes(x = lon, y = lat)) +
  geom_point() + theme_bw()



# Polygon -----------------------------------------------------------------
ggplot(data = south_africa_coast, aes(x = lon, y = lat, group = group)) +
  geom_polygon(colour ="salmon", fill = "pink") 


# Add provinces -----------------------------------------------------------
ggplot(data = south_africa_coast, aes(x = lon, y = lat, group = group)) +
  geom_polygon(colour ="salmon", fill = "pink") +
  geom_path(data = sa_provinces) +
  coord_equal(xlim = c(15, 34), 
              ylim = c(-36, -26), expand = 0)



# Add raster --------------------------------------------------------------
sst <- MUR

ggplot(data = south_africa_coast, aes(x = lon, y = lat)) +
  geom_raster(data = sst, aes(fill = bins)) +
  geom_polygon(colour ="salmon", fill = "grey70", aes(group = group)) +
  geom_path(data = sa_provinces, aes(group = group)) +
  geom_tile(data = rast_annual, aes(x = lon, y = lat, fill = bins), 
            colour = "white", size = 0.1) +
  scale_fill_manual("Temp. (°C)", values = cols11) +
  coord_equal(xlim = c(15, 34), 
              ylim = c(-36, -26), expand = 0) +
  # Put x axis labels on top of figure
  theme(axis.title = element_blank(), # Remove the axis labels
        legend.text = element_text(size = 7), # Change text size in legend
        legend.title = element_text(size = 7), # Change legend title text size
        legend.key.height = unit(0.3, "cm"), # Change size of legend
        legend.background = element_rect(colour = "white"), # Add legend background
        legend.justification = c(1, 0), # Change position of legend
        legend.position = c(0.55, 0.4) # Fine tune position of legend
  )



# Chapter 8: More mapping -------------------------------------------------
library(scales)
# install.packages(maps)  
# install.packages(sp)
library(maps)
library(sp)


# Setup -------------------------------------------------------------------
# Load the function for creating scale bars
source("functions/scale.bar.func.R")

# Load Africa shape
load("data/africa_coast.RData")

rm(MUR); rm(south_africa_coast); rm(sa_provinces); rm(rast_annual)
rm(sst)


# Map it! -----------------------------------------------------------------
ggplot() +
  borders() +
  coord_equal()

sa1 <- ggplot() +
  borders(regions = "South Africa", 
          colour = "black", fill = "grey70") + # Set colour and fill
  coord_equal(xlim = c(12, 36), ylim = c(-38, -22), expand = 0)
sa1


# Add stuff to graph ------------------------------------------------------
sa2 <- sa1 +
  annotate("text", label = "Atlantic\nOcean",
           x = 15, y = -34,
           angle = -45, size = 4, colour = "purple")



# Add scale ---------------------------------------------------------------
sa3 <- sa2 +
  scaleBar(lon = 22.2, lat = -33.1, distanceLon = 200, distanceLat = 50, 
           distanceLegend = 75, dist.unit = "km", arrow.length = 150, 
           arrow.distance = 95, arrow.North.size = 5)

