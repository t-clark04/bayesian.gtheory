
<!-- README.md is generated from README.Rmd. Please edit that file -->

# bayesian.gtheory

<!-- badges: start -->

<!-- badges: end -->

The purpose of the `bayesian.gtheory` package is to provide an automated
method for executing D-studies from univariate Generalizability Theory
through a Bayesian framework. The package offers individual functions
for every possible random one-facet and two-facet study design,
returning both the G-study (i.e. variance components) and the D-study
for the inputted data. See the “Function Dictionary” section to
determine which function to use for your study design!

## Installation

You can install the development version of bayesian.gtheory from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("t-clark04/bayesian.gtheory", dependencies = TRUE, build_vignettes = TRUE)
```

**Note**: The `cmdstanr` package must also be installed prior to using
any functions in the `bayesian.gtheory` package. To install `cmdstanr`…

``` r
# First, run this line of code.
install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos")))
# Then, run this line.
cmdstanr::install_cmdstan(). 
# Finally, verify successful installation with this line. 
cmdstanr::cmdstan_version().
```

## Function Dictionary

| Function Name      | Study Design      |
|--------------------|-------------------|
| dstudy_crossed1()  | *p* x *i*         |
| dstudy_crossed2()  | *p* x *i* x *o*   |
| dstudy_nested1()   | *i* : *p*         |
| dstudy_nested2()   | *i* : *o* : *p*   |
| dstudy_p_nested1() | (*i* : *p*) x *o* |
| dstudy_p_nested2() | *p* x (*i* : *o*) |
| dstudy_p_nested3() | *i* : (*p* x *o*) |
| dstudy_p_nested4() | (*i* x *o*) : *p* |

In the study design column, *p* represents the objects of measurement,
and *i* and *o* are arbitrary facets.

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
combination! The function even returns each of the variance components
(known collectively as the G-study), as point estimates, credible
intervals, and percentages of the total variance.

``` r
# Loading in the package
library(bayesian.gtheory)

# Specifying some artificial data from a random P x I x O study design.
Person <- c(rep(1, 6), rep(2,6), rep(3,6), rep(4,6), rep(5,6))
Item <- c(rep(c(1,2,3), 10))
Occasion <- c(rep(c(1,1,1,2,2,2), 5))
Score <- c(6,6,7,6,5,5,1,3,1,2,2,2,5,5,4,5,4,5,10,9,8,10,10,10,5,6,6,6,5,6)

# Combining all of the data into one data frame.
sample_data <- data.frame(Person, Item, Occasion, Score)

# Running the bayesian_dstudy() function.
results <- dstudy_crossed2(data = sample_data, col.scores = "Score", col.subjects = "Person", col.facet1 = "Item", col.facet2 = "Occasion", seq1 = seq(1,5,1), seq2 = seq(1,3,1), facet.fixed = NULL, threshold = 0.7, warmup = 1000, iter = 4000, chains = 4, cores = 4)
```

``` r
kable(results$gstudy)
```

|                     | Lower_Bound | Median | Upper_Bound | Percent |
|:--------------------|------------:|-------:|------------:|--------:|
| var_Person          |       2.285 |  7.443 |      31.270 |    85.8 |
| var_Item            |       0.000 |  0.094 |       5.332 |     1.1 |
| var_Occasion        |       0.000 |  0.381 |      17.092 |     4.4 |
| var_Person_Item     |       0.000 |  0.048 |       0.532 |     0.6 |
| var_Person_Occasion |       0.001 |  0.176 |       2.368 |     2.0 |
| var_Item_Occasion   |       0.000 |  0.084 |       1.585 |     1.0 |
| var_Error           |       0.225 |  0.444 |       0.963 |     5.1 |

``` r
kable(results$dstudy)
```

| n_Item | n_Occasion | Lower_Bound | Median | Upper_Bound | P(G \> 0.7) |
|-------:|-----------:|------------:|-------:|------------:|------------:|
|      1 |          1 |       0.197 |  0.775 |       0.961 |       0.629 |
|      2 |          1 |       0.220 |  0.830 |       0.975 |       0.710 |
|      3 |          1 |       0.228 |  0.852 |       0.981 |       0.739 |
|      4 |          1 |       0.231 |  0.864 |       0.984 |       0.753 |
|      5 |          1 |       0.233 |  0.871 |       0.986 |       0.760 |
|      1 |          2 |       0.295 |  0.853 |       0.977 |       0.768 |
|      2 |          2 |       0.339 |  0.895 |       0.986 |       0.824 |
|      3 |          2 |       0.357 |  0.910 |       0.989 |       0.845 |
|      4 |          2 |       0.364 |  0.919 |       0.991 |       0.855 |
|      5 |          2 |       0.371 |  0.924 |       0.992 |       0.861 |
|      1 |          3 |       0.351 |  0.884 |       0.983 |       0.821 |
|      2 |          3 |       0.414 |  0.918 |       0.990 |       0.872 |
|      3 |          3 |       0.438 |  0.932 |       0.992 |       0.891 |
|      4 |          3 |       0.453 |  0.939 |       0.993 |       0.900 |
|      5 |          3 |       0.459 |  0.944 |       0.994 |       0.904 |

How cool is that! The user also could have specified prior distributions
for any or all of the variance components through the `set_prior()`
function in `brms`or set one of the facets in the study as fixed through
the `facet.fixed` parameter. However, the author decided to keep this
example simple by leaving the default (null) priors and the fully random
design.

## Notes

Thank you to Sven de Maeyer from the University of Antwerp for inspiring
this Bayesian G-Theory package! See his blog post at
<https://svendemaeyer.netlify.app/posts/2021-04-generalizability/>.

The median is used as the measure of center for both the variance
components and the reliability coefficients because these distributions
are rarely normal (or even symmetric). The most appropriate measure of
center for skewed distributions like these is the one which is most
resistant to outliers, which is the median.

Column names passed into the function must follow C++ naming conventions
(i.e. only letters, numbers, or underscores; no spaces or hyphens!).

The number of threads used for within-chain parallelization is set to 2
by default and cannot be changed. In general, the number of `cores`
multiplied by the number of `threads` should not exceed the number of
logical CPU cores in your operating system. Adjust the `cores` parameter
accordingly! To check how many logical cores your operating system has,
run `parallel::detectCores()` in the console.
