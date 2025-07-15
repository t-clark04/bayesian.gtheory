#' Execute a One-Faceted Bayesian D-Study
#'
#' @param data A data frame containing data from a random, fully crossed one-facet design. Must have one or more columns for metrics of interest, one column for labeling subjects, and one column for labeling the facet.
#' @param col.scores The name of the column containing the metric of interest (i.e. scores, readings, etc.). Enter as a string.
#' @param col.subjects The name of the column containing the labels for the subjects. Enter as a string.
#' @param col.facet The name of the column containing the labels for the facet. Enter as a string.
#' @param seq A sequence of integers defining the interval at which to test the facet. Enter a vector, or use the seq() function directly.
#' @param threshold A decimal between 0 and 1. Will be used to calculate the probability of the reliability coefficient being above the inputted threshold. 0.7 by default.
#' @param rounded The number of decimal places the reliability coefficients and probabilities should be rounded to. 3 by default.
#' @param probs A list containing two quantiles (between 0 and 1) at which to evaluate the reliability coefficients. Set to c(0.025, 0.975) by default.
#' @param prior An optional set of prior distributions for the variance components, specified by the user through the set_prior() function in brms. To ensure correctly formatted priors, the user should first use the get_prior() function with the formula "col.scores ~ (1|col.subjects) + (1|col.facet)". Type ?brms::set_prior in the console for more information. NULL by default.
#' @param warmup Number of iterations to use per chain as the burn-in period for MCMC sampling. 2000 by default.
#' @param iter Number of total iterations per chain (including warmup). 5000 by default.
#' @param chains Number of Markov chains. 4 by default.
#' @param cores Number of cores to use when executing chains in parallel. 4 by default.
#' @param adapt_delta A value between 0 and 1. A larger value slows down the sampler but decreases the number of divergent transitions. 0.995 by default.
#' @param max_treedepth Sets the maximum tree depth in the No U-Turn Sampler (NUTS). Set to 15 by default, but can be increased if tree depth is exceeded.
#'
#' @returns A data frame containing the sequence of values to be tested for the facet, the lower and upper quantiles of the reliability coefficient specified by the user, the median of the reliability coefficient, and the probability of the coefficient being above the inputted threshold.
#' @export
#'
#' @examples
#'Person <- c(rep(1, 3), rep(2,3), rep(3,3), rep(4,3), rep(5,3))
#'Item <- c(rep(c(1,2,3), 5))
#'Score <- c(2,6,7,4,5,6,5,5,4,5,9,8,4,3,5)
#'sample_data <- data.frame(Person, Item, Score)
#'bayesian_dstudy1(data = sample_data, col.scores = "Score", col.subjects = "Person", col.facet = "Item", seq = seq(1,5,1), threshold = 0.5, warmup = 1000, iter = 4000, chains = 1)
bayesian_dstudy1 <- function(data, col.scores, col.subjects, col.facet, seq, threshold = 0.7,
                            rounded = 3, probs = c(0.025, 0.975), prior = NULL, warmup = 2000, iter = 5000, chains = 4,
                            cores = 4, adapt_delta = 0.995, max_treedepth = 15) {

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
  formula1 <- glue::glue("`{col.scores}` ~ (1|`{col.subjects}`) + (1|`{col.facet}`)")
  model <- brms::brm(formula = formula1, data = data, family = gaussian(), prior = prior, warmup = warmup,
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

  # Laying out the final data frame.
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
    ci <- stats::quantile(var_df$G_coef, probs = probs)
    lower <- unname(ci[1])
    final_df$Lower_Bound[i] <- round(lower, rounded)
    final_df$Median[i] <- round(stats::median(var_df$G_coef), rounded)
    upper <- unname(ci[2])
    final_df$Upper_Bound[i] <- round(upper, rounded)
    final_df$Placeholder[i] <- round(mean(var_df$G_coef > threshold), rounded)
  }
  names(final_df)[5] <- paste0("P(G > ", threshold, ")")
  return(final_df)
}
