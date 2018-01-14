# Plotting statistics {#plot_stats}

> "How beautiful the world was when one looked at it without searching, just looked, simply and innocently."
>
> --- Hermann Hesse, Siddartha
  
> "Facts are stubborn things, but statistics are pliable."
>
> --- Mark Twain



In this chapter we are going to learn some streamlined techniques for plotting our statistics within **`ggplot2`** figures. To do so we will again be making use of **`ggpubr`**. We will also load some of the SACTN temperature data to use for our examples.


```r
# Libraries
library(tidyverse)
library(ggpubr)

# Data
SACTN <- read_csv("data/SACTN_data.csv")
```

## New functions
We will be learning to use two new functions today. The first will be `compare_means()`, which is a function that compares means of two (t-test) or more (ANOVA) groups of values all in one convenient place. This function is used for statistical tests, but not for creating figures. The second function we will learn to use, `stat_compare_means()`, does much the same thing as `compare_means()` but is designed to be integrated directly into **`ggplot2`** code.

The `compare_means()` function uses the formula input we have already seen for other functions throughout R, such as the `lm()`. The line of code below shows how we would go about doing an ANOVA that investigates the differences between temperatures (°C) at different sites.


```r
compare_means(temp~site, data = SACTN, method = "anova")
```

```
R> # A tibble: 1 x 6
R>   .y.                          p                   p.adj p.fo… p.si… meth…
R>   <chr>                    <dbl>                   <dbl> <chr> <chr> <chr>
R> 1 temp                 2.55e⁻²⁰⁷               2.55e⁻²⁰⁷ <2e-… ****  Anova
```

How snazzy is that?! And this works just as well for two mean (t-test) comparisons. It also has built into it the necessary tests for non-parametric comparisons as well as paired tests but we won't show that explicitly here.


```r
compare_means(temp~site, data = filter(SACTN, site %in% c("Port Nolloth", "Muizenberg")), method = "t.test")
```

```
R> # A tibble: 1 x 8
R>   .y.   group1       group2                p       p.adj p.fo… p.si… meth…
R>   <chr> <chr>        <chr>             <dbl>       <dbl> <chr> <chr> <chr>
R> 1 temp  Port Nolloth Muizenberg    6.39e⁻¹¹⁸   6.39e⁻¹¹⁸ <2e-… ****  T-te…
```

This is great, but it is not new functionality, just drastically improved functionality. The second function introduced in this package is what is really going to make our lives easier. The first two lines in the following code chunk should look very familiar. We are creating a basic boxplot but with a twist. The third line of code, `stat_compare_means()`, will run an ANOVA for us "*in situ*" and automatically add the *p*-value to our boxplot.


```r
ggplot(data = SACTN, aes(x = site, y = temp)) +
  geom_boxplot(aes(fill = site), show.legend = F) +
  stat_compare_means(method = "anova")
```

<div class="figure">
<img src="07-plot_stats_files/figure-html/plot-stats-1-1.png" alt="Boxplot showing *p*-value result for an ANOVA comparing temperatures (°C) between sites." width="672" />
<p class="caption">(\#fig:plot-stats-1)Boxplot showing *p*-value result for an ANOVA comparing temperatures (°C) between sites.</p>
</div>

I find this to be a very impressive bit of code. The author of this function has devised a way to convince the rather unique **`ggplot2`** back end to do our dirty work for us and is able to use the x and y axes to calculate statistical analyses. And if that isn't enough, it then goes and puts it on our figure for us! Because this is all still happening within the confines of **`ggplot2`** code, everything can be changed as we desire. The following is just an example, not necessarily the best way to visualise this information.


```r
ggplot(data = SACTN, aes(x = site, y = temp)) +
  geom_boxplot(aes(fill  = site), show.legend = F) +
  stat_compare_means(method = "anova", # Choose stat, same as above
                     aes(label = paste0("p ", ..p.format..)), # Remove "Anova" text
                     label.x = 2) + # Set label position
  # The following two lines simply make the figure prettier
  labs(x = "Site", y = "Temperature (°C)") + # Clean up labels
  theme_bw() # Choose different theme
```

<div class="figure">
<img src="07-plot_stats_files/figure-html/plot-stats-2-1.png" alt="The same as the preceeding figure, but with minor touch ups." width="672" />
<p class="caption">(\#fig:plot-stats-2)The same as the preceeding figure, but with minor touch ups.</p>
</div>

## Further applications
As mentioned above, these functions may be used with paired tests, non-parametric tests, and multiple mean tests. These outputs have mates in the **`ggplot2`** sphere and so may be visualised with relative ease. Below we see an example of how to do this with a multiple mean (ANOVA) test.


```r
# First get a list of the different sites to be compared
SACTN_levels <- levels(as.factor(SACTN$site))

# Then manually construct a list of desired pairwise comparisons
my_comparisons <- list(c(SACTN_levels[1], SACTN_levels[2]), 
                       c(SACTN_levels[2], SACTN_levels[3]),
                       c(SACTN_levels[1], SACTN_levels[3]))

# And then we wack it all together
ggplot(data = SACTN, aes(x = site, y = temp)) +
  geom_boxplot(aes(fill  = site), show.legend = F) +
  # Calculate ANOVA for all sites
  stat_compare_means(method = "anova", 
                     label.x = 1.9, label.y = 33) +
  # Add pairwise comparisons p-value
  stat_compare_means(comparisons = my_comparisons,
                     label.y = c(26, 28, 30)) +
  # Perform t-tests between each group and the overall mean
    # This shows up as the asterisks above each box
  stat_compare_means(label = "p.signif", method = "t.test",
                     ref.group = ".all.") +
  # Add horizontal line at base mean
  geom_hline(yintercept = mean(SACTN$temp, na.rm = T), linetype = 2) + 
  # Pretty labels and theme
  labs(y = "Temp. (°C)", x = NULL) +
  theme_bw()
```

<div class="figure">
<img src="07-plot_stats_files/figure-html/plot-stats-3-1.png" alt="Boxplots showing a wealth of statistical information. Refer to the following text for a full description." width="672" />
<p class="caption">(\#fig:plot-stats-3)Boxplots showing a wealth of statistical information. Refer to the following text for a full description.</p>
</div>

The above figure, boxplots showing the distribution of temperatures (°C) for each site, contains a lot of densely packed information that we will now work through together. Firstly, the horizontal dashed line nearer the bottom shows what the overall mean temperature (°C) across all three time series is. Next, the little asterisks above each box show the significance value of the difference of this group (site) from the mean temperature (dashed line). Four asterisks means _p_<0.001. The pair wise comparisons of each site are shown with black brackets, the text on top of which show the _p_-values of those comparisons. lastly, the text at the very top of the figure shows the overall _p_-value for the ANOVA that compared all means against one another. Generally one would not want to show all of this information in one figure. This just serves as an example of how straightforward it is to do so.

For a more detailed explanation for how to perform more advanced comparisons of multiple groups (especially paired comparisons), and how to plot all of those results in a very cunning way, one may follow this link: <https://www.r-bloggers.com/add-p-values-and-significance-levels-to-ggplots/>.

## DIY figures

Today we learned the basics of **`ggplot2`**, how to facet, how to brew colours, and how to plot stats. Sjog, that's a lot of stuff to remember! Which is why we will now spend the rest of Day 2 putting our new found skills to use. Please group up as you see fit to produce your very own **`ggplot2`** figures. We've not yet learned how to manipulate/tidy up our data so it may be challenging to grab any ol' dataset and make a plan with it. To that end we recommend using the built in datasets in the **`datasets`** package. You are of course free to use whatever dataset you would like, including your own. The goal by the end of this session is to have created at least two figures (first prize for four figures) and join them together via faceting. We will be walking the room to help with any issues that may arise.