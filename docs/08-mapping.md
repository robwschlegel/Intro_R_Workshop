# Mapping with **`ggplot2`** {#mapping}

> "There's no map to human behaviour."
>
> --- Bjork
  
> "Here be dragons"
> 
> --- Unknown



Yesterday we learned how to create **`ggplot2`** figures, change their aesthetics, labels, colour palettes, and facet/grid them. Now we are going to look at how to create maps. 

Most of the work that we perform as environmental/biological scientists involves going out to a location and sampling information there. Sometimes only once, and sometimes over a period of time. All of these different sampling methods lend themselves to different types of figures. One of those, collection of data at different points, is best shown with maps. As we will see over the course of the day, creating maps in **`ggplot2`** is very straight forward and enjoys extensive native support. For that reason we are going to have plenty of time to also learn how to do some more advanced things. Our goal is to produce something similar to the figure below.

<div class="figure">
<img src="figures/map_complete.png" alt="The goal for today." width="1050" />
<p class="caption">(\#fig:map-goal)The goal for today.</p>
</div>

Before we begin let's go ahead and load the packages we will need, as well as the several dataframes required to make the final product.


```r
# Load libraries
library(tidyverse)
library(ggpubr)

# Load data
load("data/south_africa_coast.Rdata")
load("data/sa_provinces.RData")
load("data/site_list.Rdata")
load("data/rast_annual.Rdata")
load("data/rast_aug.Rdata")
load("data/rast_feb.Rdata")
load("data/MUR.Rdata")

# The colour pallette we will use for ocean temperature
cols11 <- c("#004dcd", "#0068db", "#007ddb", "#008dcf", "#009bbc",
            "#00a7a9", "#1bb298", "#6cba8f", "#9ac290", "#bec99a")
```

## A new concept?

The idea of creating a map in R may be daunting to some, but remember that a basic map is nothing more than a simple figure with an x and y axis. We tend to think of maps as different from other scientific figures, whereas in reality they are created the exact same way. Let's compare a dot plot of the chicken weight data against a dot plot of the coastline of South Africa.

Chicken dots:


```r
ggplot(data = ChickWeight, aes(x = Time, y = weight)) +
  geom_point()
```

<div class="figure">
<img src="08-mapping_files/figure-html/map-point-1-1.png" alt="Dot plot of chicken weight data." width="672" />
<p class="caption">(\#fig:map-point-1)Dot plot of chicken weight data.</p>
</div>

South African coast dots:


```r
ggplot(data = south_africa_coast, aes(x = lon, y = lat)) +
  geom_point()
```

<div class="figure">
<img src="08-mapping_files/figure-html/map-point-2-1.png" alt="Dot plot off South African coast." width="672" />
<p class="caption">(\#fig:map-point-2)Dot plot off South African coast.</p>
</div>

Does that look familiar? Notice how the x and y axis tick labels look the same as any map you would see in an atlas. This is because they are. But this isn't a great way to create a map. Rather it is better to represent the land mass with a polygon. With **`ggplot2`** this is a simple task. In fact, there is already a global map built into the package.

## Built in maps

In the previous section we saw how to create a map of South Africa using a shape files we had saved on our computer. We are now going to learn how to use the shape files that are found within the **`tidyverse`**.


```r
ggplot() +
  borders() + # The global shape file
  coord_equal() # Equal sizing for lon/lat 
```

<div class="figure">
<img src="08-mapping_files/figure-html/map-world-1.png" alt="The built in global shape file." width="672" />
<p class="caption">(\#fig:map-world)The built in global shape file.</p>
</div>

Jikes! It's as simple as that to load a map of the whole planet. Usually we are not going to want to make a map of the entire planet, so let's see how to focus on just South Africa. 


```r
ggplot() +
  borders(regions = "South Africa", 
          colour = "black", fill = "grey70") + # Set colour and fill
  coord_equal()
```

<div class="figure">
<img src="08-mapping_files/figure-html/map-SA-1-1.png" alt="Built in map of South Africa." width="672" />
<p class="caption">(\#fig:map-SA-1)Built in map of South Africa.</p>
</div>

Surprisingly, the international borders for South Africa do not account for Swaziland. That is an error. We also see in the above map that the exclusion of the southern African countries bordering on South Africa give it the appearance of an island. Marion Island is also giving us issues. This isn't great, so let's consider a different option for selecting the area around South Africa.


```r
south_africa <- ggplot() +
  borders(fill = "grey70", colour = "black") +
  coord_equal(xlim = c(15, 34), ylim = c(-36, -26), expand = 0) # Define lon/lat extent
south_africa
```

<div class="figure">
<img src="08-mapping_files/figure-html/map-SA-2-1.png" alt="A better way to get the map of South Africa." width="672" />
<p class="caption">(\#fig:map-SA-2)A better way to get the map of South Africa.</p>
</div>

That is a very tidy looking map of South(ern) Africa without needing to load any files.

## Creating a map

Now that we have seen that a map is nothing more than a bunch of dots and shapes on specific points along the x and y axes we are going to look at the steps we would take to build a more complex map. Don't worry if this seems daunting at first. We are going to take this step by step and ensure that each step is made clear along the way. Remember that in order to add something to a **`ggplot2`** figure we use a `+`. Because we already created our base map, `south_africa`, we will now simply add new lines of code to this base that we created.

The first thing we will add will be the province borders as seen in \@ref(fig:map-goal). Notice how we only add one more line of code to do this. The one hiccup here is that because the built in map has different names for the x and y axes than our data, we need to specifiy the `aes()` values for each new geom we add.


```r
south_africa +
  geom_path(data = sa_provinces, aes(x = lon, y = lat, group = group)) # The province borders
```

<div class="figure">
<img src="08-mapping_files/figure-html/map-province-1.png" alt="The map of South Africa. Now with province borders!" width="672" />
<p class="caption">(\#fig:map-province)The map of South Africa. Now with province borders!</p>
</div>

This is starting to look pretty fancy, but it would be nicer if there was some colour involved. So let's add the ocean temperature. Again, this will only require one more line of code. Starting to see a pattern? But what is different this time and why?


```r
south_africa +
  geom_raster(data = MUR, aes(fill = bins, x = lon, y = lat)) + # The ocean temperatures
  geom_path(data = sa_provinces, aes(x = lon, y = lat, group = group))
```

<div class="figure">
<img src="08-mapping_files/figure-html/map-MUR-1.png" alt="Ocean temperature (°C) visualised as an ice cream spill." width="672" />
<p class="caption">(\#fig:map-MUR)Ocean temperature (°C) visualised as an ice cream spill.</p>
</div>

That looks... odd. Why do the colours look like someone melted a big bucket of ice cream in the ocean? This is because the colours you see in this figure are the default colours for discrete values in **`ggplot2`**. If we want to change them we may do so easily by adding yet one more line of code.


```r
south_africa +
  geom_raster(data = MUR, aes(fill = bins, x = lon, y = lat)) +
  geom_path(data = sa_provinces, aes(x = lon, y = lat, group = group)) +
  scale_fill_manual("Temp. (°C)", values = cols11) # Set the colour palette
```

<div class="figure">
<img src="08-mapping_files/figure-html/map-colour-1.png" alt="Ocean temperatures (°C) around South Africa." width="672" />
<p class="caption">(\#fig:map-colour)Ocean temperatures (°C) around South Africa.</p>
</div>

There's a colour palette that would make Jacques Cousteau swoon. When we set the colour palette for a figure in **`ggplot2`** we must use that colour palette for all other instances of those types of values, too. What this means is that any other discrete values that will be filled in, like the ocean colour above, must use the same colour palette (there are some technical exceptions to this rule that we will not cover in this course). We normally want **`ggplot2`** to use consistent colour palettes anyway, but it is important to note that this constraint exists. Let's see what we mean. Next we will add the coastal pixels to our figure with one more line of code. We won't change anything else. Note how **`ggplot2`** changes the colour of the coastal pixels to match the ocean colour automatically. Let's also add some points to highlight major cities while we are at it.


```r
south_africa +
  geom_raster(data = MUR, aes(fill = bins, x = lon, y = lat)) +
  geom_path(data = sa_provinces, aes(x = lon, y = lat, group = group)) +
  geom_tile(data = rast_annual, aes(x = lon, y = lat, fill = bins), 
            colour = "white", size = 0.1) + # The coastal temperature values
  geom_point(data = site_list, alpha = 0.4,
             aes(x = lon, y = lat)) + # Coastal city locations
  scale_fill_manual("Temp. (°C)", values = cols11)
```

<div class="figure">
<img src="08-mapping_files/figure-html/map-raster-1.png" alt="Map of SOuth Africa showing *in situ* temeperatures (°C) as pixels along the coast." width="672" />
<p class="caption">(\#fig:map-raster)Map of SOuth Africa showing *in situ* temeperatures (°C) as pixels along the coast.</p>
</div>

We used `geom_tile()` instead of `geom_rast()` to add the coastal pixels above so that we could add those little white boxes around them. This figure is looking pretty great now. And it only took a few rows of code to put it all together! The last step is to add several more lines of code that will control for all of the little things we want to change about the appearance of the figure. Each little thing that is changed below is annotated for your convenience.


```r
fig_top <- south_africa +
  geom_raster(data = MUR, aes(fill = bins, x = lon, y = lat)) +
  geom_path(data = sa_provinces, aes(x = lon, y = lat, group = group)) +
  geom_tile(data = rast_annual, aes(x = lon, y = lat, fill = bins), 
            colour = "white", size = 0.1) +
  geom_point(data = site_list, alpha = 0.4,
             aes(x = lon, y = lat)) +
  scale_fill_manual("Temp. (°C)", values = cols11) +
  scale_x_continuous(position = "top") + # Put x axis labels on top of figure
  theme(axis.title = element_blank(), # Remove the axis labels
        legend.text = element_text(size = 7), # Change text size in legend
        legend.title = element_text(size = 7), # Change legend title text size
        legend.key.height = unit(0.3, "cm"), # Change size of legend
        legend.background = element_rect(colour = "white"), # Add legend background
        legend.justification = c(1, 0), # Change position of legend
        legend.position = c(0.55, 0.4) # Fine tune position of legend
        )
fig_top
```

<div class="figure">
<img src="08-mapping_files/figure-html/map-final-1.png" alt="The cleaned up map of South Africa. Resplendent with coastal and ocean temperatures (°C)." width="672" />
<p class="caption">(\#fig:map-final)The cleaned up map of South Africa. Resplendent with coastal and ocean temperatures (°C).</p>
</div>

That is a very clean looking map and is going to serve as the top half of the figure we are putting together today. For the bottom half we are now going to look at how to create a ribbon in **`ggplot2`**.

## A ribbon for your troubles

For the bottom portion of our figure we want to add a ribbon that shows the mean temperature along the coast, as well as the coldest (August) and warmest (February) months of the year. This allows us to visualise what the range of temperatures along the coast are.


```r
ggplot(data = rast_annual, aes(x = index, y = temp)) +
  geom_ribbon(aes(ymin = rast_aug$temp, ymax = rast_feb$temp), fill = "grey80") +
  geom_point(aes(colour = temp), size = 0.6)
```

<div class="figure">
<img src="08-mapping_files/figure-html/ribbon-base-1.png" alt="An 'out-of-the-box' ribbon geom of seasonal *in situ* temperatures (°C) along the coast of South Africa." width="672" />
<p class="caption">(\#fig:ribbon-base)An 'out-of-the-box' ribbon geom of seasonal *in situ* temperatures (°C) along the coast of South Africa.</p>
</div>

That looks pretty good already. But let's change the colour of the points so that they match the map we are using.


```r
ggplot(data = rast_annual, aes(x = index, y = temp)) +
  geom_ribbon(aes(ymin = rast_feb$temp, ymax = rast_aug$temp), fill = "grey80") +
  geom_point(aes(colour = temp), size = 0.6) +
  scale_colour_gradientn("Temp. (°C)", limits = c(10, 30), colours = cols11, 
                         breaks = seq(12, 28, 4))
```

<div class="figure">
<img src="08-mapping_files/figure-html/ribbon-colour-1.png" alt="The same ribbon but with the correct colour scale." width="672" />
<p class="caption">(\#fig:ribbon-colour)The same ribbon but with the correct colour scale.</p>
</div>

Notice that whereas the colours look the same, for this ribbon we are using temperature (°C) as a continuous variable and not a discrete variable. This is why we have to provide the 'break' information in the line that changes the colours for our ribbon. The next thing we want to do is change the labels for the x and y axes and remove the legend. Because we are going to have a legend in the top half of the figure, we don't need one for the bottom half.


```r
ggplot(data = rast_annual, aes(x = index, y = temp)) +
  geom_ribbon(aes(ymin = rast_feb$temp, ymax = rast_aug$temp), fill = "gray80") +
  geom_point(aes(colour = temp), size = 0.6) +
  scale_colour_gradientn("Temp. (°C)", limits = c(10, 30), colours = cols11, 
                         breaks = seq(12, 28, 4)) +
  guides(colour = FALSE) + # Remove the legend
  labs(x = "", y = "Temperature (°C)") + # Change the x and y axis label
  scale_y_continuous(breaks = seq(14, 26, 3), 
                     expand = c(0, 0)) + # Change the y axis ticks
  scale_x_continuous(breaks = site_list$index2, 
                     labels = site_list$site, expand = c(0, 0)) # Change x axis ticks
```

<div class="figure">
<img src="08-mapping_files/figure-html/ribbon-axes-1.png" alt="A ribbon with some apparent issues." width="672" />
<p class="caption">(\#fig:ribbon-axes)A ribbon with some apparent issues.</p>
</div>

It may look like we have taken a step backward, but we are about to sort everything out in a very nice way. To do this we will need to manipulate the minutia of the figure using `theme()`. Again, we will label each line to add clarity to the process.


```r
fig_bottom <- ggplot(data = rast_annual, aes(x = index, y = temp)) +
  geom_ribbon(aes(ymin = rast_feb$temp, ymax = rast_aug$temp), fill = "gray80") +
  geom_point(aes(colour = temp), size = 0.6) +
  scale_colour_gradientn("Temp. (°C)", limits = c(10, 30), colours = cols11, 
                         breaks = seq(12, 28, 4)) +
  guides(colour = FALSE) +
  labs(x = "", y = "Temperature (°C)") +
  scale_y_continuous(breaks = seq(14, 26, 3), 
                     expand = c(0, 0)) +
  scale_x_continuous(breaks = site_list$index2, 
                     labels = site_list$site, expand = c(0, 0)) +
  theme(panel.background = element_blank(), # Remove the panel background
        panel.border = element_blank(), # Remove the panel border
        plot.background = element_blank(), # Remove the background
        panel.grid.major.x = element_line(colour = "black", 
                                          linetype = "dotted", 
                                          size = 0.2), # Change the x axis gridlines
        panel.grid.major.y = element_line(colour = NA), # Remove the y axis gridlines
        axis.text.x = element_text(angle = 90, 
                                   hjust = 1, 
                                   vjust = 0.5, 
                                   size = 7), # Change the x axis labels
        axis.text.y = element_text(size = 7), # Change the y axis labels
        axis.title.y = element_text(size = 8) # Change y axis title size 
        )
fig_bottom
```

<div class="figure">
<img src="08-mapping_files/figure-html/ribbon-final-1.png" alt="The finished ribbon." width="672" />
<p class="caption">(\#fig:ribbon-final)The finished ribbon.</p>
</div>

And there we have it. This is a very nice ribbon figure showing the annual range of temperatures along the coast of South Africa. But it relies on the map figure to be complete.

## Combining figures

We learned yesterday how to combine figures with **`ggpubr`** so that all of the figures in the grid were an equal size. In this instance however we want the map panel of our figure to be twice as high as the ribbon panel. In order to do so we will use the `heights` argument to change the relative height of each row in our grid.


```r
# Create an object that contains all of the map data
final <- ggarrange(fig_top, fig_bottom, 
                   nrow = 2,
                   heights = c(2,1)) # Adjust heights of the rows
final
```

<div class="figure">
<img src="08-mapping_files/figure-html/map-grid-1.png" alt="The finished product." width="672" />
<p class="caption">(\#fig:map-grid)The finished product.</p>
</div>

<!-- Why is the top panel slightly narrower than the bottom panel? This is because we used `coord_equal()` to constrain the lon/lat extent in our map. Whereas this may produce maps that are aesthetically pleasing, it can have unintended consequences.  -->

Finally, let's save the fruits of our labours.


```r
ggsave(plot = final, "figures/map_complete.pdf")
```




