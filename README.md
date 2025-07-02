
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
```

``` r
kable(results)
```

| n_Item | n_Occasion | Lower_Bound | Median | Upper_Bound | P(G \> 0.5) |
|-------:|-----------:|------------:|-------:|------------:|------------:|
|      1 |          1 |       0.000 |  0.090 |       0.612 |       0.057 |
|      2 |          1 |       0.000 |  0.134 |       0.729 |       0.116 |
|      3 |          1 |       0.000 |  0.165 |       0.785 |       0.158 |
|      4 |          1 |       0.000 |  0.186 |       0.815 |       0.190 |
|      5 |          1 |       0.001 |  0.202 |       0.836 |       0.212 |
|      1 |          2 |       0.000 |  0.123 |       0.701 |       0.098 |
|      2 |          2 |       0.001 |  0.186 |       0.802 |       0.182 |
|      3 |          2 |       0.001 |  0.230 |       0.846 |       0.236 |
|      4 |          2 |       0.001 |  0.260 |       0.872 |       0.274 |
|      5 |          2 |       0.001 |  0.285 |       0.887 |       0.302 |
|      1 |          3 |       0.000 |  0.142 |       0.739 |       0.123 |
|      2 |          3 |       0.001 |  0.217 |       0.833 |       0.218 |
|      3 |          3 |       0.001 |  0.266 |       0.871 |       0.278 |
|      4 |          3 |       0.001 |  0.305 |       0.893 |       0.321 |
|      5 |          3 |       0.001 |  0.333 |       0.908 |       0.349 |

How awesome is that!
