
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bayesian.gtheory

<!-- badges: start -->

<!-- badges: end -->

The purpose of the `bayesian.gtheory` package is to provide an automated
method for executing D-studies from Generalizability Theory through a
Bayesian framework. The `dstudy_crossed1()` and \``dstudy_crossed2()`
functions carry out reliability analysis for a random, fully crossed
study design with one and two facets, respectively. Furthermore, the
`dstudy_p_nested1()` function returns the reliability analysis for a
fully random, partially nested (i:p) x o design, and the
`dstudy_p_nested2()` function works for a fully random, partially nested
p x (i:o) design.

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
G-coefficient for absolute agreement (or $`\Phi`$). However, what if you
wanted the reliability to be given as an interval instead? And what if
you wanted to know the probability of the G-coefficient being above a
certain threshold for your study? With frequentist G-theory, that’s
impossible, but not with Bayesian!

The `dstudy_crossed2()` function calculates the G-coefficient for each
combination of the two facets specified by the user, returning the
result as both a point estimate (the median of the posterior
distribution) and a credible interval (with quantiles specified by the
user). Plus, the outputted data frame contains an explicit probability
statement for each facet combination, specifying the probability of the
G-coefficient being above an inputted threshold for that particular
combination! The user even has the option of specifying prior
distributions for any or all of the variance components through the
`set_prior()` function in `brms`, but the author decided to keep this
example simple by leaving the default (null) priors.

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

# Running the bayesian_dstudy() function.
results <- dstudy_crossed2(data = sample_data, col.scores = "Score", col.subjects = "Person", col.facet1 = "Item", col.facet2 = "Occasion", seq1 = seq(1,5,1), seq2 = seq(1,3,1), threshold = 0.5, warmup = 1000, iter = 4000, chains = 4, cores = 4)
```

``` r
kable(results)
```

| n_Item | n_Occasion | Lower_Bound | Median | Upper_Bound | P(G \> 0.5) |
|-------:|-----------:|------------:|-------:|------------:|------------:|
|      1 |          1 |       0.000 |  0.090 |       0.622 |       0.061 |
|      2 |          1 |       0.000 |  0.132 |       0.735 |       0.115 |
|      3 |          1 |       0.000 |  0.158 |       0.789 |       0.158 |
|      4 |          1 |       0.001 |  0.177 |       0.821 |       0.187 |
|      5 |          1 |       0.001 |  0.191 |       0.842 |       0.208 |
|      1 |          2 |       0.000 |  0.122 |       0.702 |       0.100 |
|      2 |          2 |       0.001 |  0.185 |       0.804 |       0.178 |
|      3 |          2 |       0.001 |  0.225 |       0.847 |       0.231 |
|      4 |          2 |       0.001 |  0.255 |       0.873 |       0.265 |
|      5 |          2 |       0.001 |  0.276 |       0.890 |       0.294 |
|      1 |          3 |       0.000 |  0.140 |       0.741 |       0.123 |
|      2 |          3 |       0.001 |  0.215 |       0.833 |       0.214 |
|      3 |          3 |       0.001 |  0.265 |       0.873 |       0.271 |
|      4 |          3 |       0.001 |  0.300 |       0.893 |       0.310 |
|      5 |          3 |       0.001 |  0.327 |       0.907 |       0.340 |

How cool is that!

Thank you to Sven de Maeyer from the University of Antwerp for inspiring
this Bayesian G-Theory package! See his blog post at
<https://svendemaeyer.netlify.app/posts/2021-04-generalizability/>.

Note: Column names passed into the function must follow C++ naming
conventions (i.e. only letters, numbers, or underscores; no spaces or
hyphens!). Furthermore, the number of threads used for within-chain
parallelization is set to 2 by default and cannot be changed. In
general, the number of `cores` multiplied by the number of `threads`
should not exceed the number of logical CPU cores in your operating
system. Adjust the `cores` parameter accordingly! To check how many
logical cores your operating system has, run parallel::detectCores() in
the console.
