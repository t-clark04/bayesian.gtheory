
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
    #> Warning: There were 2 divergent transitions after warmup. See
    #> https://mc-stan.org/misc/warnings.html#divergent-transitions-after-warmup
    #> to find out why this is a problem and how to eliminate them.
    #> Warning: Examine the pairs() plot to diagnose sampling problems

``` r
kable(results)
```

| n_Item | n_Occasion | Lower_Bound | Median | Upper_Bound | P(G \> 0.5) |
|-------:|-----------:|------------:|-------:|------------:|------------:|
|      1 |          1 |       0.000 |  0.094 |       0.625 |       0.059 |
|      2 |          1 |       0.000 |  0.140 |       0.738 |       0.117 |
|      3 |          1 |       0.001 |  0.168 |       0.789 |       0.158 |
|      4 |          1 |       0.001 |  0.189 |       0.818 |       0.189 |
|      5 |          1 |       0.001 |  0.205 |       0.840 |       0.212 |
|      1 |          2 |       0.000 |  0.128 |       0.711 |       0.098 |
|      2 |          2 |       0.001 |  0.194 |       0.807 |       0.180 |
|      3 |          2 |       0.001 |  0.235 |       0.850 |       0.236 |
|      4 |          2 |       0.001 |  0.266 |       0.875 |       0.275 |
|      5 |          2 |       0.001 |  0.289 |       0.891 |       0.304 |
|      1 |          3 |       0.001 |  0.147 |       0.751 |       0.124 |
|      2 |          3 |       0.001 |  0.225 |       0.836 |       0.219 |
|      3 |          3 |       0.001 |  0.276 |       0.876 |       0.279 |
|      4 |          3 |       0.001 |  0.310 |       0.896 |       0.319 |
|      5 |          3 |       0.002 |  0.339 |       0.910 |       0.348 |

How awesome is that!
