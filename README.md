
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bayesian.gtheory

<!-- badges: start -->

<!-- badges: end -->

The purpose of the `bayesian.gtheory` package is to provide an automated
method for executing D-studies from Generalizability Theory through a
Bayesian framework. More specifically, the `bayesian_dstudy` function
utilizes the `brms` package to carry out a reliability analysis for a
random, fully crossed two-facet study design.

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
analysis.

In regular (i.e. frequentist) Generalizability Theory, the result of
such a reliability analysis is given as a point estimate – the
G-coefficient (or phi) for absolute agreement. However, what if you
wanted the reliability to be given as an interval instead? And what if
you wanted to know the probability of the G-coefficient being above a
certain threshold for your study? With frequentist G-theory, that’s
impossible, but not with Bayesian!

The `bayesian_dstudy()` function calculates the G-coefficient for each
combination of the two facets specified by the user, returning the
result as both a point estimate (the median of the posterior
distribution) and a credible interval (with quantiles specified by the
user). Plus, the outputted data frame contains an explicit probability
statement for each facet combination, specifying the probability of the
G-coefficient being above an inputted threshold for that particular
combination!

``` r
# Loading in the package
library(bayesian.gtheory)

# Specifying some artificial data from a random P x I x O study design.
Person <- c(rep(1, 6), rep(2,6), rep(3,6), rep(4,6), rep(5,6))
Item <- c(rep(c(1,2,3), 10))
Occasion <- c(rep(c(1,1,1,2,2,2), 5))
Score <- c(2,6,7,2,5,5,4,5,6,6,7,5,5,5,4,5,4,5,5,9,8,5,7,7,4,3,5,4,5,6)

# Combining all of the data into one data frame.
sample_data <- data.frame(Person, Item, Occasion, Score)

# Running the bayesian_dstudy() function!
results <- bayesian_dstudy(data = sample_data, col.scores = "Score", col.subjects = "Person", col.facet1 = "Item", col.facet2 = "Occasion", seq1 = seq(1,5,1), seq2 = seq(1,3,1), threshold = 0.5, warmup = 1000, iter = 4000, chains = 4, cores = 4)
```

``` r
kable(results)
```

| n_Item | n_Occasion | Lower_Bound | Median | Upper_Bound | P(G \> 0.5) |
|-------:|-----------:|------------:|-------:|------------:|------------:|
|      1 |          1 |       0.000 |  0.093 |       0.632 |       0.060 |
|      2 |          1 |       0.000 |  0.138 |       0.744 |       0.122 |
|      3 |          1 |       0.001 |  0.167 |       0.795 |       0.162 |
|      4 |          1 |       0.001 |  0.186 |       0.824 |       0.190 |
|      5 |          1 |       0.001 |  0.203 |       0.845 |       0.214 |
|      1 |          2 |       0.000 |  0.126 |       0.713 |       0.102 |
|      2 |          2 |       0.001 |  0.192 |       0.811 |       0.186 |
|      3 |          2 |       0.001 |  0.234 |       0.854 |       0.239 |
|      4 |          2 |       0.001 |  0.264 |       0.878 |       0.272 |
|      5 |          2 |       0.001 |  0.288 |       0.893 |       0.300 |
|      1 |          3 |       0.000 |  0.143 |       0.750 |       0.124 |
|      2 |          3 |       0.001 |  0.222 |       0.839 |       0.224 |
|      3 |          3 |       0.001 |  0.273 |       0.877 |       0.279 |
|      4 |          3 |       0.001 |  0.310 |       0.898 |       0.322 |
|      5 |          3 |       0.001 |  0.338 |       0.912 |       0.355 |

How awesome is that!
