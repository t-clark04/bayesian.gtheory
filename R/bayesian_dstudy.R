#' Execute a Bayesian D-Study
#'
#' @param data A data frame containing data from a random, fully crossed two-facet design. Must have one or more columns for metrics of interest, one column for labeling subjects, and two columns for labeling facets.
#' @param col.scores The name of the column containing the metric of interest (i.e. scores, readings, etc.). Enter as a string.
#' @param col.subjects The name of the column containing the labels for the subjects. Enter as a string.
#' @param col.facet1 The name of the column containing the labels for the first facet. Enter as a string.
#' @param col.facet2 The name of the column containing the labels for the second facet. Enter as a string.
#' @param seq1 A sequence of integers defining the interval at which to test the first facet. Enter a vector, or use the seq() function directly.
#' @param seq2 A sequence of integers defining the interval at which to test the second facet. Enter a vector, or use the seq() function directly.
#' @param threshold A decimal between 0 and 1. Will be used to calculate the probability of the reliability coefficient being above the inputted threshold. 0.7 by default.
#' @param rounded The number of decimal places the reliability coefficients and probabilities should be rounded to. 3 by default.
#' @param probs A list containing two quantiles (between 0 and 1) at which to evaluate the reliability coefficients. Set to c(0.025, 0.975) by default.
#' @param warmup Number of iterations to use per chain as the burn-in period for MCMC sampling. 2000 by default.
#' @param iter Number of total iterations per chain (including warmup). 5000 by default.
#' @param chains Number of Markov chains. 4 by default.
#' @param cores Number of cores to use when executing chains in parallel. 4 by default.
#' @param adapt_delta A value between 0 and 1. A larger value slows down the sampler but decreases the number of divergent transitions. 0.995 by default.
#' @param max_treedepth Sets the maximum tree depth in the No U-Turn Sampler (NUTS). Set to 15 by default, but can be increased if tree depth is exceeded.
#'
#' @returns A data frame containing the sequence of values to be tested for facet 1 and facet 2, the lower and upper quantiles of the reliability coefficient specified by the user, the median of the reliability coefficient, and the probability of the coefficient being above the inputted threshold.
#' @export
#'
#' @examples
#'Person <- c(rep(1, 6), rep(2,6), rep(3,6), rep(4,6), rep(5,6))
#'Item <- c(rep(c(1,2,3), 10))
#'Occasion <- c(rep(c(1,1,1,2,2,2), 5))
#'Score <- c(2,6,7,2,5,5,4,5,6,6,7,5,5,5,4,5,4,5,5,9,8,5,7,7,4,3,5,4,5,6)
#'sample_data <- data.frame(Person, Item, Occasion, Score)
#'bayesian_dstudy(data = sample_data, col.scores = "Score", col.subjects = "Person", col.facet1 = "Item", col.facet2 = "Occasion", seq1 = seq(1,5,1), seq2 = seq(1,3,1), threshold = 0.5, warmup = 1000, iter = 4000, chains = 1)
bayesian_dstudy <- function(data, col.scores, col.subjects, col.facet1, col.facet2, seq1, seq2, threshold = 0.7,
                            rounded = 3, probs = c(0.025, 0.975), warmup = 2000, iter = 5000, chains = 4,
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


  # Renaming the columns to make them easier to work with.
  data <- data %>%
    dplyr::rename("Score" = col.scores, "Person" = col.subjects, "Item" = col.facet1, "Occasion" = col.facet2)

  # Setting the formula and running the brms model according to the user's specifications.
  formula1 <- Score ~ (1|Person) + (1|Item) + (1|Occasion) + (1|Person:Item) + (1|Person:Occasion) + (1|Item:Occasion)
  model <- brms::brm(formula = formula1, data = data, family = gaussian(), warmup = warmup,
               iter = iter, chains = chains, cores = cores, control = list(adapt_delta = adapt_delta,
                                                                           max_treedepth = max_treedepth))
  # Taking samples from the posterior distribution and selecting only the columns I need.
  samples <- brms::as_draws_df(model)
  suppressWarnings(var_df <- samples[2:8])

  # Calculating variance components.
  var_df <- var_df %>%
    dplyr::mutate(
      var_Person = sd_Person__Intercept^2,
      var_Item = sd_Item__Intercept^2,
      var_Occasion = sd_Occasion__Intercept^2,
      var_Person_Item = `sd_Person:Item__Intercept`^2,
      var_Person_Occasion = `sd_Person:Occasion__Intercept`^2,
      var_Item_Occasion = `sd_Item:Occasion__Intercept`^2,
      var_Error = sigma^2
    ) %>%
    dplyr::select(
      tidyselect::starts_with("var")
    )

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
        new_Item = var_Item/n_i,
        new_Occasion = var_Occasion/n_o,
        new_Person_Item = var_Person_Item/n_i,
        new_Person_Occasion = var_Person_Occasion/n_o,
        new_Item_Occasion = var_Item_Occasion/(n_i*n_o),
        new_Error = var_Error/(n_i*n_o),
        G_coef = new_Person/(new_Person + new_Item + new_Occasion + new_Person_Item +
                               new_Person_Occasion + new_Item_Occasion + new_Error)
      )
    ci <- stats::quantile(var_df$G_coef, probs = probs)
    lower <- unname(ci[1])
    final_df$Lower_Bound[i] <- round(lower, rounded)
    final_df$Median[i] <- round(stats::median(var_df$G_coef), rounded)
    upper <- unname(ci[2])
    final_df$Upper_Bound[i] <- round(upper, rounded)
    final_df$Placeholder[i] <- round(mean(var_df$G_coef > threshold), rounded)
  }
  names(final_df)[6] <- paste0("P(G > ", threshold, ")")
  return(final_df)
}
