# Mapping with style {#mapping_style}

> "How beautiful the world was when one looked at it without searching, just looked, simply and innocently."
>
> --- Hermann Hesse, Siddartha
  
> “You can’t judge a book by it’s cover but you can sure sell a bunch of books if you have a good one.”
>
> --- Jayce O’Neal



Now that we have learned the basics of creating a beautiful map in **`ggplot2`** it is time to look at some of the more particular things we will need to make our maps extra stylish. There are also a few more things we need to learn how to do before our maps can be truly publication quality.

If we have not yet loaded the **`tidyverse`** let's do so.


```r
# Load libraries
library(tidyverse)
library(scales)

# Load the function for creating scale bars
source("functions/scale.bar.func.R")

# Load Africa shape
load("data/africa_coast.RData")
```

## Default maps

In order to access the default maps included with the **`tidyverse`** we will use the function `borders()`.


```r
ggplot() +
  borders() + # The global shape file
  coord_equal() # Equal sizing for lon/lat 
```

<div class="figure">
<img src="08-mapping_style_files/figure-html/maps-world-1.png" alt="The built in global shape file." width="672" />
<p class="caption">(\#fig:maps-world)The built in global shape file.</p>
</div>

Jikes! It's as simple as that to load a map of the whole planet. Usually we are not going to want to make a map of the entire planet, so let's see how to focus on just South Africa. 


```r
ggplot() +
  borders(regions = "South Africa", 
          colour = "black", fill = "grey70") + # Set colour and fill
  coord_equal()
```

<div class="figure">
<img src="08-mapping_style_files/figure-html/maps-SA-1-1.png" alt="Built in map of South Africa." width="672" />
<p class="caption">(\#fig:maps-SA-1)Built in map of South Africa.</p>
</div>

We see in the above map that the exclusion of the southern African countries bordering on South Africa give it the appearance of an island. Marion Island is also giving us issues. This isn't great, so let's consider a different option for selecting the area around South Africa.


```r
sa_1 <- ggplot() +
  borders(fill = "grey70", colour = "black") +
  coord_equal(xlim = c(12, 36), ylim = c(-38, -22), expand = 0) # Force lon/lat extent
sa_1
```

<div class="figure">
<img src="08-mapping_style_files/figure-html/maps-SA-2-1.png" alt="A better way to get the map of South Africa." width="672" />
<p class="caption">(\#fig:maps-SA-2)A better way to get the map of South Africa.</p>
</div>

That is a very tidy looking map of South(ern) Africa without needing to load any files.

## Specific labels

A map is almost always going to need some labels and other visual cues. We saw in the previous section how to add site labels. The following code chunk shows how this differs if we want to add just one label at a time. This can be useful if ecah label needs to be different from all other labels for whatever reason. We may also see that the text labels we are creating have `\n` in them. When R sees these two characters together like this it reads this as an instruction to returndown a line. Let's run the code to make sure we see what this means.


```r
sa_2 <- sa_1 +
  annotate("text", label = "Atlantic\nOcean", x = 15.1, y = -32.0, 
           size = 5.0, angle = 30, colour = "navy") +
  annotate("text", label = "Indian\nOcean", x = 33.2, y = -34.2, 
           size = 5.0, angle = 330, colour = "springgreen")
sa_2
```

<div class="figure">
<img src="08-mapping_style_files/figure-html/maps-labels-1.png" alt="Map of southern Africa with specific labels." width="672" />
<p class="caption">(\#fig:maps-labels)Map of southern Africa with specific labels.</p>
</div>

## Scale bars

With our fancy labels added, let's insert a scale bar next. There is no default scale bar function in the **`tidyverse`** unfortunately, rather we will need to import one that has been created by a kind Samaritan. It is a bit finicky and often requires a bit of trial and error to get it to look exactly the way one wants. On the plus side, this also means we have a lot of control over the appearance of the scale bar.


```r
sa_3 <- sa_2 +
    scaleBar(lon = 22.2, lat = -33.1, distanceLon = 200, distanceLat = 50, 
             distanceLegend = 75, dist.unit = "km", arrow.length = 150, 
             arrow.distance = 95, arrow.North.size = 5)
sa_3
```

<div class="figure">
<img src="08-mapping_style_files/figure-html/maps-scale-1.png" alt="Map of southern Africa with labels and a scale bar." width="672" />
<p class="caption">(\#fig:maps-scale)Map of southern Africa with labels and a scale bar.</p>
</div>

## Insetting

In order to inset a smaller map inside of a larger map we must first create the smaller map. Let's make a map of Africa as a demonstration. The built in shape files that come with the **`tidyverse`** are not terribly useful for creating the outline of a given continent, so we will use the shape file of Africa that we already have saved on our computer. See if you can determine what each line of code is doing.


```r
africa_map <- ggplot(data = africa_coast, aes(x = lon, y = lat)) +
  geom_polygon(aes(group = group), colour = "black", fill = "grey70") +
  borders(regions = "South Africa", colour = "black", fill = "black",
          ylim = c(-34, -28)) +
  annotate("text", x = 15, y = 15, label = "AFRICA", size = 4.5) +
  geom_rect(aes(xmin = 12, xmax =  36, ymin = -38, ymax = -22),
            fill = NA, colour = "red") +
  coord_equal() +
  theme_void() +
  theme(panel.background = element_rect(fill = "white", colour = "black"))
africa_map
```

<div class="figure">
<img src="08-mapping_style_files/figure-html/maps-mini-1.png" alt="A quick map of Africa to be insetted in our southern Africa map." width="672" />
<p class="caption">(\#fig:maps-mini)A quick map of Africa to be insetted in our southern Africa map.</p>
</div>

And now to inset this map of Africa into our map of southern Africa we will need to learn how to create a 'grob'. This is very simple and does not require any extra work on our part. Remember that **`ggplot2`** objects are different from normal objects (i.e. dataframes), and that they have their own way of storing and accessing data. In order to convert any sort of thing into a format that ggplot understands we convert it into a grob, as shown below. Once converted, we may then plop it onto our figure/map wherever we please. Both of these steps are accomplished with the single function `annotation_custom()`. This is also a good way to add logos or any other sort of image to a map/figure. You can really go completely bananas. It's even possible to add GIFs. Such happy. Much excite. Very wonderment.


```r
sa_4 <- sa_3 +
  annotation_custom(grob = ggplotGrob(africa_map),
                    xmin = 21.3, xmax = 27.3,
                    ymin = -30, ymax = -24)
sa_4
```

<div class="figure">
<img src="08-mapping_style_files/figure-html/maps-inset-1.png" alt="Map of southern Africa, with labels, scale bar, and an inset map of Africa." width="672" />
<p class="caption">(\#fig:maps-inset)Map of southern Africa, with labels, scale bar, and an inset map of Africa.</p>
</div>

## Rounding it out

There are a lot of exciting things going on in our figure now. To round out our adventures in mapping let's tweak the lon/alt labels to a more prestigious convention. There are two ways to do this. One of which requires us to install the **`scales`** package. Don't worry, its's a small one!


```r
sa_final <- sa_4 +
  scale_x_continuous(breaks = seq(16, 32, 4),
                     labels = scales::unit_format("°E", sep = ""),
                     position = "bottom") +
  scale_y_continuous(breaks = seq(-36, -24, 4),
                     labels = c("36.0°S", "32.0°S", "28.0°S", "24.0°S"),
                     position = "right") +
  labs(x = "", y = "")
sa_final
```

<div class="figure">
<img src="08-mapping_style_files/figure-html/maps-final-1.png" alt="The final map with all of the bells and whistles." width="672" />
<p class="caption">(\#fig:maps-final)The final map with all of the bells and whistles.</p>
</div>

And lastly we save the fruits of our labours.


```r
ggsave(plot = sa_final, filename = "figures/southern_africa_final.pdf", 
       height = 6, width = 8)
```