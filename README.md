
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

results <- bayesian_dstudy(data = sample_data, col.scores = "Score", col.subjects = "Person", col.facet1 = "Item", col.facet2 = "Occasion", seq1 = seq(1,5,1), seq2 = seq(1,3,1), threshold = 0.5, warmup = 1000, iter = 4000, chains = 1)
#> Compiling Stan program...
#> WARNING: Rtools is required to build R packages, but is not currently installed.
#> 
#> Please download and install the appropriate version of Rtools for 4.4.0 from
#> https://cran.r-project.org/bin/windows/Rtools/.
#> Trying to compile a simple C file
#> Running "C:/PROGRA~1/R/R-44~1.0/bin/x64/Rcmd.exe" SHLIB foo.c
#> using C compiler: 'gcc.exe (GCC) 13.2.0'
#> gcc  -I"C:/PROGRA~1/R/R-44~1.0/include" -DNDEBUG   -I"C:/Users/t_cla/AppData/Local/R/win-library/4.4/Rcpp/include/"  -I"C:/Users/t_cla/AppData/Local/R/win-library/4.4/RcppEigen/include/"  -I"C:/Users/t_cla/AppData/Local/R/win-library/4.4/RcppEigen/include/unsupported"  -I"C:/Users/t_cla/AppData/Local/R/win-library/4.4/BH/include" -I"C:/Users/t_cla/AppData/Local/R/win-library/4.4/StanHeaders/include/src/"  -I"C:/Users/t_cla/AppData/Local/R/win-library/4.4/StanHeaders/include/"  -I"C:/Users/t_cla/AppData/Local/R/win-library/4.4/RcppParallel/include/" -DRCPP_PARALLEL_USE_TBB=1 -I"C:/Users/t_cla/AppData/Local/R/win-library/4.4/rstan/include" -DEIGEN_NO_DEBUG  -DBOOST_DISABLE_ASSERTS  -DBOOST_PENDING_INTEGER_LOG2_HPP  -DSTAN_THREADS  -DUSE_STANC3 -DSTRICT_R_HEADERS  -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION  -D_HAS_AUTO_PTR_ETC=0  -include "C:/Users/t_cla/AppData/Local/R/win-library/4.4/StanHeaders/include/stan/math/prim/fun/Eigen.hpp"  -std=c++1y    -I"C:/RBuildTools/4.4/x86_64-w64-mingw32.static.posix/include"     -O2 -Wall  -mfpmath=sse -msse2 -mstackrealign  -c foo.c -o foo.o
#> cc1.exe: warning: command-line option '-std=c++14' is valid for C++/ObjC++ but not for C
#> In file included from C:/Users/t_cla/AppData/Local/R/win-library/4.4/RcppEigen/include/Eigen/Core:19,
#>                  from C:/Users/t_cla/AppData/Local/R/win-library/4.4/RcppEigen/include/Eigen/Dense:1,
#>                  from C:/Users/t_cla/AppData/Local/R/win-library/4.4/StanHeaders/include/stan/math/prim/fun/Eigen.hpp:22,
#>                  from <command-line>:
#> C:/Users/t_cla/AppData/Local/R/win-library/4.4/RcppEigen/include/Eigen/src/Core/util/Macros.h:679:10: fatal error: cmath: No such file or directory
#>   679 | #include <cmath>
#>       |          ^~~~~~~
#> compilation terminated.
#> make: *** [C:/PROGRA~1/R/R-44~1.0/etc/x64/Makeconf:289: foo.o] Error 1
#> WARNING: Rtools is required to build R packages, but is not currently installed.
#> 
#> Please download and install the appropriate version of Rtools for 4.4.0 from
#> https://cran.r-project.org/bin/windows/Rtools/.
#> Start sampling
#> 
#> SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 1).
#> Chain 1: 
#> Chain 1: Gradient evaluation took 8.2e-05 seconds
#> Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0.82 seconds.
#> Chain 1: Adjust your expectations accordingly!
#> Chain 1: 
#> Chain 1: 
#> Chain 1: Iteration:    1 / 4000 [  0%]  (Warmup)
#> Chain 1: Iteration:  400 / 4000 [ 10%]  (Warmup)
#> Chain 1: Iteration:  800 / 4000 [ 20%]  (Warmup)
#> Chain 1: Iteration: 1001 / 4000 [ 25%]  (Sampling)
#> Chain 1: Iteration: 1400 / 4000 [ 35%]  (Sampling)
#> Chain 1: Iteration: 1800 / 4000 [ 45%]  (Sampling)
#> Chain 1: Iteration: 2200 / 4000 [ 55%]  (Sampling)
#> Chain 1: Iteration: 2600 / 4000 [ 65%]  (Sampling)
#> Chain 1: Iteration: 3000 / 4000 [ 75%]  (Sampling)
#> Chain 1: Iteration: 3400 / 4000 [ 85%]  (Sampling)
#> Chain 1: Iteration: 3800 / 4000 [ 95%]  (Sampling)
#> Chain 1: Iteration: 4000 / 4000 [100%]  (Sampling)
#> Chain 1: 
#> Chain 1:  Elapsed Time: 4.348 seconds (Warm-up)
#> Chain 1:                7.408 seconds (Sampling)
#> Chain 1:                11.756 seconds (Total)
#> Chain 1:
```

``` r

kable(results)
```

| n_Item | n_Occasion | Lower_Bound | Median | Upper_Bound | P(G \> 0.5) |
|-------:|-----------:|------------:|-------:|------------:|------------:|
|      1 |          1 |       0.000 |  0.092 |       0.619 |       0.059 |
|      2 |          1 |       0.000 |  0.140 |       0.733 |       0.113 |
|      3 |          1 |       0.000 |  0.167 |       0.787 |       0.153 |
|      4 |          1 |       0.000 |  0.184 |       0.816 |       0.184 |
|      5 |          1 |       0.001 |  0.202 |       0.836 |       0.209 |
|      1 |          2 |       0.000 |  0.127 |       0.696 |       0.098 |
|      2 |          2 |       0.000 |  0.193 |       0.800 |       0.182 |
|      3 |          2 |       0.001 |  0.236 |       0.844 |       0.235 |
|      4 |          2 |       0.001 |  0.268 |       0.869 |       0.276 |
|      5 |          2 |       0.001 |  0.290 |       0.886 |       0.301 |
|      1 |          3 |       0.000 |  0.146 |       0.742 |       0.126 |
|      2 |          3 |       0.001 |  0.225 |       0.832 |       0.212 |
|      3 |          3 |       0.001 |  0.278 |       0.870 |       0.277 |
|      4 |          3 |       0.001 |  0.313 |       0.892 |       0.317 |
|      5 |          3 |       0.001 |  0.341 |       0.906 |       0.348 |

How awesome is that!
