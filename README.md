
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bayesian.gtheory

<!-- badges: start -->

<!-- badges: end -->

The purpose of the `bayesian.gtheory` package is to provide an automated
method for executing D-studies from Generalizability Theory through a
Bayesian framework. More specifically, the `bayesian_dstudy` function
utilizes the `brms` package to carry out a reliability analysis for a
random, fully crossed two-facet study designs.

## Installation

You can install the development version of bayesian.gtheory from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("t-clark04/bayesian.gtheory")
```

## Usage

Let’s say you did a study in which you gave five different students a
test with 3 different items on it, and you gave them that test on two
separate occasions. You want to know the reliability with which you
could generalize to each student’s true score by averaging over x number
of items and y number of occasions. This is called a reliability
analysis. In regular (i.e. frequentist) Generalizability Theory, the
reliability of such a generalization is given as a point estimate – the
G-coefficient (or phi) for absolute agreement. However, what if you
wanted the reliability to be given as an interval instead? And what if
you wanted to know the probability of the G-coefficient being above a
certain threshold for your study? With frequentist G-theory, that’s
impossible, but not with Bayesian! The `bayesian_dstudy()` function
calculates the G-coefficient for each combination of the two facets
specified by the user, returning the result as both a point estimate
(the median of posterior distribution) and a credible interval (with
quantiles specified by the user). Plus, the outputted data frame
contains an explicit probability statement for each facet combination,
specifying the probability of the G-coefficient being above an inputted
threshold for that particular study design!

``` r
library(bayesian.gtheory)

Person <- c(rep(1, 6), rep(2,6), rep(3,6), rep(4,6), rep(5,6))
Item <- c(rep(c(1,2,3), 10))
Occasion <- c(rep(c(1,1,1,2,2,2), 5))
Score <- c(2,6,7,2,5,5,4,5,6,6,7,5,5,5,4,5,4,5,5,9,8,5,7,7,4,3,5,4,5,6)

sample_data <- data.frame(Person, Item, Occasion, Score)

results <- bayesian_dstudy(data = sample_data, col.scores = "Score", col.subjects = "Person", col.facet1 = "Item", col.facet2 = "Occasion", seq1 = seq(1,5,1), seq2 = seq(1,3,1), threshold = 0.5, warmup = 1000, iter = 4000, chains = 4, cores = 4)
#> Compiling Stan program...
#> WARNING: Rtools is required to build R packages, but is not currently installed.
#> 
#> Please download and install the appropriate version of Rtools for 4.4.0 from
#> https://cran.r-project.org/bin/windows/Rtools/.
#> Trying to compile a simple C file
#> WARNING: Rtools is required to build R packages, but is not currently installed.
#> 
#> Please download and install the appropriate version of Rtools for 4.4.0 from
#> https://cran.r-project.org/bin/windows/Rtools/.
#> Start sampling
#> Warning: There were 2 divergent transitions after warmup. See
#> https://mc-stan.org/misc/warnings.html#divergent-transitions-after-warmup
#> to find out why this is a problem and how to eliminate them.
#> Warning: Examine the pairs() plot to diagnose sampling problems
```

``` r
kable(results)
```

| n_Item | n_Occasion | Lower_Bound | Median | Upper_Bound | P(G \> 0.5) |
|-------:|-----------:|------------:|-------:|------------:|------------:|
|      1 |          1 |       0.000 |  0.093 |       0.614 |       0.055 |
|      2 |          1 |       0.000 |  0.139 |       0.728 |       0.118 |
|      3 |          1 |       0.001 |  0.168 |       0.781 |       0.160 |
|      4 |          1 |       0.001 |  0.189 |       0.815 |       0.188 |
|      5 |          1 |       0.001 |  0.205 |       0.833 |       0.211 |
|      1 |          2 |       0.000 |  0.127 |       0.698 |       0.097 |
|      2 |          2 |       0.001 |  0.194 |       0.798 |       0.185 |
|      3 |          2 |       0.001 |  0.237 |       0.842 |       0.237 |
|      4 |          2 |       0.001 |  0.268 |       0.867 |       0.273 |
|      5 |          2 |       0.001 |  0.294 |       0.883 |       0.299 |
|      1 |          3 |       0.000 |  0.146 |       0.739 |       0.126 |
|      2 |          3 |       0.001 |  0.225 |       0.830 |       0.220 |
|      3 |          3 |       0.001 |  0.276 |       0.870 |       0.278 |
|      4 |          3 |       0.001 |  0.314 |       0.890 |       0.318 |
|      5 |          3 |       0.001 |  0.343 |       0.904 |       0.351 |

How awesome is that!
