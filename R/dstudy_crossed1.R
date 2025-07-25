#' Execute a One-Faceted Crossed Bayesian D-Study
#'
#' @param data A data frame containing data from a random, fully crossed one-facet design. Must have one or more columns for metrics of interest, one column for labeling subjects, and one column for labeling the facet.
#' @param col.scores The name of the column containing the metric of interest (i.e. scores, readings, etc.). Must follow C++ naming conventions (only letters, numbers, and underscores; no spaces or hyphens!). Enter as a string.
#' @param col.subjects The name of the column containing the labels for the subjects. Must follow C++ naming conventions (only letters, numbers, and underscores; no spaces or hyphens!). Enter as a string.
#' @param col.facet The name of the column containing the labels for the facet. Must follow C++ naming conventions (only letters, numbers, and underscores; no spaces or hyphens!). Enter as a string.
#' @param seq A sequence of integers defining the interval at which to test the facet. Enter a vector, or use the seq() function directly.
#' @param threshold A decimal between 0 and 1. Will be used to calculate the probability of the reliability coefficient being above the inputted threshold. 0.7 by default.
#' @param rounded The number of decimal places the variance components, reliability coefficients, and probabilities should be rounded to. 3 by default.
#' @param quantiles A list containing two quantiles (between 0 and 1) at which to evaluate the variance components and the reliability coefficients. Set to c(0.025, 0.975) by default.
#' @param prior An optional set of prior distributions for the variance components, specified by the user through the set_prior() function in brms. To ensure correctly formatted priors, the user should first use the get_prior() function with the formula "col.scores ~ (1|col.subjects) + (1|col.facet)". Type ?brms::set_prior in the console for more information. NULL by default.
#' @param warmup Number of iterations to use per chain as the burn-in period for MCMC sampling. 2000 by default.
#' @param iter Number of total iterations per chain (including warmup). 5000 by default.
#' @param chains Number of Markov chains. 4 by default.
#' @param cores Number of cores to use when executing chains in parallel. 4 by default. Note: The number of threads is set to 2 by default and cannot be changed. The number of cores times the number of threads should not exceed the number of logical CPU cores in your operating system. Adjust this parameter accordingly! To check how many logical CPU cores you have, run parallel::detectCores() in the console.
#' @param adapt_delta A value between 0 and 1. A larger value slows down the sampler but decreases the number of divergent transitions. 0.995 by default.
#' @param max_treedepth Sets the maximum tree depth in the No U-Turn Sampler (NUTS). Set to 15 by default, but can be increased if tree depth is exceeded.
#'
#' @returns Two dataframes. The gstudy dataframe contains the lower bound, median, and upper bound of the distributions for each of the variance components in the G-study (according to the quantiles set by the user in the quantiles argument), as well as the percent of the total variance caused by each component. The dstudy dataframe contains the sequence of values to be tested for the facet, the lower and upper quantiles of the reliability coefficient specified by the user, the median of the reliability coefficient, and the probability of the coefficient being above the inputted threshold.
#' @export
#'
#' @details This function uses the "cmdstanr" backend for communication with STAN, so installation of the 'cmdstanr' package is required. To install 'cmdstanr', first run install.packages("cmdstanr", repos = c("https://mc-stan.org/r-packages/", getOption("repos"))), and then run cmdstanr::install_cmdstan(). To verify installation, run cmdstanr::cmdstan_version().
#'
#' @note The median is used as the measure of center for both the variance components and the reliability coefficients because these distributions are rarely normal (or even symmetric). The most appropriate measure of center for skewed distributions like these is the one which is most resistant to outliers, which is the median.
#' @note Thank you to Sven de Maeyer from the University of Antwerp for inspiring this Bayesian G-Theory package! See his blog post at https://svendemaeyer.netlify.app/posts/2021-04-generalizability/.
#'
#' @examples
#'suppressMessages(suppressWarnings({
#'Person <- c(rep(1, 3), rep(2,3), rep(3,3), rep(4,3), rep(5,3))
#'Item <- c(rep(c(1,2,3), 5))
#'Score <- c(6,6,7,4,5,4,5,5,4,10,9,9,4,3,5)
#'sample_data <- data.frame(Person, Item, Score)
#'dstudy_crossed1(data = sample_data, col.scores = "Score",
#'                col.subjects = "Person", col.facet = "Item",
#'                seq = seq(1,5,1), threshold = 0.7, warmup = 1000,
#'                iter = 4000, chains = 1)
#'}))
dstudy_crossed1 <- function(data, col.scores, col.subjects, col.facet, seq, threshold = 0.7,
                            rounded = 3, quantiles = c(0.025, 0.975), prior = NULL, warmup = 2000, iter = 5000, chains = 4,
                            cores = 4, adapt_delta = 0.995, max_treedepth = 15) {

  # Making sure the user has 'cmdstanr' installed.
  if (!requireNamespace("cmdstanr", quietly = TRUE)) {
    stop("The 'cmdstanr' package is required to run this function. Please check the help file for installation instructions.")
  }

  # Making sure the user entered real column names.
  if (!(col.scores) %in% colnames(data)) {
    stop(paste0("'", col.scores, "'", " is not a column in the data frame. Please check spelling."), call. = F)
  }
  else if (!(col.subjects) %in% colnames(data)) {
    stop(paste0("'", col.subjects, "'", " is not a column in the data frame. Please check spelling."), call. = F)
  }
  else if (!(col.facet) %in% colnames(data)) {
    stop(paste0("'", col.facet1, "'", " is not a column in the data frame. Please check spelling."), call. = F)
  }

  # Making sure the user numeric data for the scores column.
  if (!is.numeric(data[[col.scores]])) {
    stop("Scores data must be numeric!")
  }

  # Making sure the user specified positive integers for the sequence.
  suppressWarnings(
    if (any(is.logical(seq)) | any(is.na(as.integer(seq))) | any(seq != as.integer(seq)) | any(as.integer(seq) <= 0)) {
      stop("'seq1' must only contain positive integers.", call. = F)
    }
  )

  # Making sure the number of rounding digits is a positive integer as well.
  suppressWarnings(if (is.logical(rounded) | is.na(as.integer(rounded)) | rounded != as.integer(rounded) | as.integer(rounded) <= 0) {
    stop("'rounded' must be a positive integer.", call. = F)
  })

  # Setting the formula and running the brms model according to the user's specifications.
  formula1 <- glue::glue("{col.scores} ~ (1|{col.subjects}) + (1|{col.facet})")
  model <- brms::brm(formula = formula1, data = data, family = stats::gaussian(), prior = prior, warmup = warmup,
                     iter = iter, chains = chains, cores = cores, threads = brms::threading(2), backend = "cmdstanr",
                     control = list(adapt_delta = adapt_delta, max_treedepth = max_treedepth))

  # Taking samples from the posterior distribution and selecting only the columns I need.
  samples <- brms::as_draws_df(model)
  suppressWarnings(var_df <- samples[2:4])

  # Calculating variance components.
  var_df <- var_df %>%
    dplyr::mutate(
      var_Person = .[[glue::glue("sd_{col.subjects}__Intercept")]]^2,
      var_Item = .[[glue::glue("sd_{col.facet}__Intercept")]]^2,
      var_Error = sigma^2
    ) %>%
    dplyr::select(
      tidyselect::starts_with("var")
    )

  # Laying out the final variance components dataframe.
  variance_comps <- data.frame(0,0,0)
  colnames(variance_comps) <- c("Lower_Bound", "Median", "Upper_Bound")
  for (i in seq(1, ncol(var_df))) {
    vci <- stats::quantile(var_df[[i]], probs = quantiles)
    variance_comps[i, 1] <- round(unname(vci[1]), rounded)
    variance_comps[i,3] <- round(unname(vci[2]), rounded)
    median <- round(stats::median(var_df[[i]]), rounded)
    variance_comps[i,2] <- median
  }
  variance_comps <- variance_comps %>%
    dplyr::mutate(Percent = round((Median/sum(Median))*100, 1))
  rownames(variance_comps) <- colnames(var_df)

  # Laying out the final D-study data frame.
  final_df <- expand.grid(seq)
  colnames(final_df) <- paste0("n_", col.facet)
  final_df$Lower_Bound <- 0
  final_df$Median <- 0
  final_df$Upper_Bound <- 0
  final_df$Placeholder <- 0

  # Iterate through each facet values and calculate the median
  # and desired quantiles for the reliability coefficients. Then, calculate the
  # probability that the G-coefficient is greater than the inputted threshold.
  # Put all of these into the final data frame we created before.
  for (i in seq(1, nrow(final_df))) {
    n_i = final_df[i,1]
    var_df <- var_df %>%
      dplyr::mutate(
        new_Person = var_Person,
        new_Item = var_Item/n_i,
        new_Error = var_Error/(n_i),
        G_coef = new_Person/(new_Person + new_Item + new_Error)
      )
    ci <- stats::quantile(var_df$G_coef, probs = quantiles)
    lower <- unname(ci[1])
    final_df$Lower_Bound[i] <- round(lower, rounded)
    final_df$Median[i] <- round(stats::median(var_df$G_coef), rounded)
    upper <- unname(ci[2])
    final_df$Upper_Bound[i] <- round(upper, rounded)
    final_df$Placeholder[i] <- round(mean(var_df$G_coef > threshold), rounded)
  }
  names(final_df)[5] <- paste0("P(G > ", threshold, ")")
  return(list(gstudy = variance_comps, dstudy = final_df))
}
