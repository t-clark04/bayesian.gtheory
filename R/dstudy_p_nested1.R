#' Execute a Partially Nested Bayesian D-Study -- (i:p) x o
#'
#' @param data A data frame containing data from a partially nested, two-facet design with one facet nested within subjects. Must have one or more columns for metrics of interest, one column for labeling subjects, and two columns for labeling facets.
#' @param col.scores The name of the column containing the metric of interest (i.e. scores, readings, etc.). Must follow C++ naming conventions (only letters, numbers, and underscores; no spaces or hyphens!). Enter as a string.
#' @param col.subjects The name of the column containing the labels for the subjects. Must follow C++ naming conventions (only letters, numbers, and underscores; no spaces or hyphens!).Enter as a string.
#' @param col.facet1 The name of the column containing the labels for the facet nested within subjects. Must follow C++ naming conventions (only letters, numbers, and underscores; no spaces or hyphens!). Enter as a string.
#' @param col.facet2 The name of the column containing the labels for the crossed facet. Must follow C++ naming conventions (only letters, numbers, and underscores; no spaces or hyphens!). Enter as a string.
#' @param seq1 A sequence of integers defining the interval at which to test the nested facet. Enter a vector, or use the seq() function directly.
#' @param seq2 A sequence of integers defining the interval at which to test the crossed facet. Enter a vector, or use the seq() function directly.
#' @param threshold A decimal between 0 and 1. Will be used to calculate the probability of the reliability coefficient being above the inputted threshold. 0.7 by default.
#' @param rounded The number of decimal places the variance components, reliability coefficients, and probabilities should be rounded to. 3 by default.
#' @param quantiles A list containing two quantiles (between 0 and 1) at which to evaluate the variance components and reliability coefficients. Set to c(0.025, 0.975) by default.
#' @param prior An optional set of prior distributions for the variance components, specified by the user through the set_prior() function in brms. To ensure correctly formatted priors, the user should first use the get_prior() function with the formula "col.scores ~ (1|col.facet2) + (1|col.facet2:col.subjects) + (1|col.subjects/col.facet1)". Type ?brms::set_prior in the console for more information. NULL by default.
#' @param warmup Number of iterations to use per chain as the burn-in period for MCMC sampling. 2000 by default.
#' @param iter Number of total iterations per chain (including warmup). 5000 by default.
#' @param chains Number of Markov chains. 4 by default.
#' @param cores Number of cores to use when executing chains in parallel. 4 by default. Note: The number of threads is set to 2 by default and cannot be changed. The number of cores times the number of threads should not exceed the number of logical CPU cores in your operating system. Adjust this parameter accordingly! To check how many logical CPU cores you have, run parallel::detectCores() in the console.
#' @param adapt_delta A value between 0 and 1. A larger value slows down the sampler but decreases the number of divergent transitions. 0.995 by default.
#' @param max_treedepth Sets the maximum tree depth in the No U-Turn Sampler (NUTS). Set to 15 by default, but can be increased if tree depth is exceeded.
#'
#' @returns Two dataframes. The gstudy dataframe contains the lower bound, median, and upper bound of the distributions for each of the variance components in the G-study (according to the quantiles set by the user in the quantiles argument). The dstudy dataframe contains the sequence of values to be tested for facet 1 and facet 2, the lower and upper quantiles of the reliability coefficient specified by the user, the median of the reliability coefficient, and the probability of the coefficient being above the inputted threshold.
#' @export
#'
#' @note The median is used as the measure of center for both the variance components and the reliability coefficients because these distributions are rarely normal (or even symmetric). The most appropriate measure of center for skewed distributions like these is the one which is most resistant to outliers, which is the median.
#' @note Thank you to Sven de Maeyer from the University of Antwerp for inspiring this Bayesian G-Theory package! See his blog post at https://svendemaeyer.netlify.app/posts/2021-04-generalizability/.
#'
#' @examples
#'Person <- c(rep(1, 6), rep(2,6), rep(3,6), rep(4,6), rep(5,6))
#'Item <- c(rep(c(1,2,3), 2), rep(c(4,5,6),2), rep(c(7,8,9),2), rep(c(10,11,12),2), rep(c(13,14,15),2))
#'Occasion <- c(rep(c(1,1,1,2,2,2), 5))
#'Score <- c(19,17,20,18,18,20,15,15,17,16,17,17,20,20,19,20,20,20,11,14,12,12,13,12,18,19,18,19,18,19)
#'sample_data <- data.frame(Person, Item, Occasion, Score)
#'dstudy_p_nested1(data = sample_data, col.scores = "Score", col.subjects = "Person", col.facet1 = "Item", col.facet2 = "Occasion", seq1 = seq(1,5,1), seq2 = seq(1,3,1), threshold = 0.5, warmup = 1000, iter = 4000, chains = 1)
dstudy_p_nested1 <- function(data, col.scores, col.subjects, col.facet1, col.facet2, seq1, seq2, threshold = 0.7,
                            rounded = 3, quantiles = c(0.025, 0.975), prior = NULL, warmup = 2000, iter = 5000, chains = 4,
                            cores = 4, adapt_delta = 0.995, max_treedepth = 15) {

  # Making sure the user entered real column names.
  if (!(col.scores) %in% colnames(data)) {
    stop(paste0("'", col.scores, "'", " is not a column in the data frame. Please check spelling."), call. = F)
  }
  else if (!(col.subjects) %in% colnames(data)) {
    stop(paste0("'", col.subjects, "'", " is not a column in the data frame. Please check spelling."), call. = F)
  }
  else if (!(col.facet1) %in% colnames(data)) {
    stop(paste0("'", col.facet1, "'", " is not a column in the data frame. Please check spelling."), call. = F)
  }
  else if (!(col.facet2) %in% colnames(data)) {
    stop(paste0("'", col.facet2, "'", " is not a column in the data frame. Please check spelling."), call. = F)
  }

  # Making sure the user numeric data for the scores column.
  if (!is.numeric(data[[col.scores]])) {
    stop("Scores data must be numeric!")
  }

  # Making sure the user specified positive integers for the two sequences.
  suppressWarnings(
    if (any(is.logical(seq1)) | any(is.na(as.integer(seq1))) | any(seq1 != as.integer(seq1)) | any(as.integer(seq1) <= 0)) {
      stop("'seq1' must only contain positive integers.", call. = F)
    }
    else if (any(is.logical(seq2)) | any(is.na(as.integer(seq2))) | any(seq2 != as.integer(seq2)) | any(as.integer(seq2) <= 0)) {
      stop("'seq2' must only contain positive integers.", call. = F)
    }
  )

  # Making sure the number of rounding digits is a positive integer as well.
  suppressWarnings(if (is.logical(rounded) | is.na(as.integer(rounded)) | rounded != as.integer(rounded) | as.integer(rounded) <= 0) {
    stop("'rounded' must be a positive integer.", call. = F)
  })

  # Setting the formula and running the brms model according to the user's specifications.
  formula1 <- glue::glue("{col.scores} ~ (1|{col.facet2}) + (1|{col.facet2}:{col.subjects}) + (1|{col.subjects}/{col.facet1})")
  model <- brms::brm(formula = formula1, data = data, family = gaussian(), prior = prior, warmup = warmup,
                     iter = iter, chains = chains, cores = cores, threads = brms::threading(2),
                     backend = "cmdstanr", control = list(adapt_delta = adapt_delta, max_treedepth = max_treedepth))

  # Taking samples from the posterior distribution and selecting only the columns I need.
  samples <- brms::as_draws_df(model)
  suppressWarnings(var_df <- samples[2:6])

  # Calculating variance components.
  var_df <- var_df %>%
    dplyr::mutate(
      var_Person = .[[glue::glue("sd_{col.subjects}__Intercept")]]^2,
      var_Occasion = .[[glue::glue("sd_{col.facet2}__Intercept")]]^2,
      var_Person_Occasion = .[[glue::glue("sd_{col.facet2}:{col.subjects}__Intercept")]]^2,
      var_Person_Item = .[[glue::glue("sd_{col.subjects}:{col.facet1}__Intercept")]]^2,
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
    variance_comps[i,2] <- round(stats::median(var_df[[i]]), rounded)
  }
  rownames(variance_comps) <- colnames(var_df)

  # Laying out the final data frame.
  final_df <- expand.grid(seq1, seq2)
  colnames(final_df) <- c(paste0("n_", col.facet1), paste0("n_", col.facet2))
  final_df$Lower_Bound <- 0
  final_df$Median <- 0
  final_df$Upper_Bound <- 0
  final_df$Placeholder <- 0

  # Iterate through each combination of facet values and calculate the median
  # and desired quantiles for the reliability coefficients. Then, calculate the
  # probability that the G-coefficient is greater than the inputted threshold.
  # Put all of these into the final data frame we created before.
  for (i in seq(1, nrow(final_df))) {
    n_i = final_df[i,1]
    n_o = final_df[i,2]
    var_df <- var_df %>%
      dplyr::mutate(
        new_Person = var_Person,
        new_Occasion = var_Occasion/n_o,
        new_Person_Item = var_Person_Item/n_i,
        new_Person_Occasion = var_Person_Occasion/n_o,
        new_Error = var_Error/(n_i*n_o),
        G_coef = new_Person/(new_Person + new_Occasion + new_Person_Item +
                               new_Person_Occasion + new_Error)
      )
    ci <- stats::quantile(var_df$G_coef, probs = quantiles)
    lower <- unname(ci[1])
    final_df$Lower_Bound[i] <- round(lower, rounded)
    final_df$Median[i] <- round(stats::median(var_df$G_coef), rounded)
    upper <- unname(ci[2])
    final_df$Upper_Bound[i] <- round(upper, rounded)
    final_df$Placeholder[i] <- round(mean(var_df$G_coef > threshold), rounded)
  }
  names(final_df)[6] <- paste0("P(G > ", threshold, ")")
  return(list(gstudy = variance_comps, dstudy = final_df))
}
