bayesian_dstudy <- function(data, col.scores, col.subjects, col.facet1, col.facet2, seq1, seq2, threshold = 0.7,
                            rounded = 3, probs = c(0.025, 0.975), prior = NULL, warmup = 2000, iter = 5000, chains = 4,
                            cores = 4, adapt_delta = 0.995, max_treedepth = 15) {
  data <- data %>%
    rename("Score" = col.scores, "Person" = col.subjects, "Item" = col.facet1, "Occasion" = col.facet2)

  formula1 <- Score ~ (1|Person) + (1|Item) + (1|Occasion) + (1|Person:Item) + (1|Person:Occasion) + (1|Item:Occasion)
  model <- brm(formula = formula1, data = data, family = gaussian(), warmup = warmup, prior = prior,
               iter = iter, chains = chains, cores = cores, control = list(adapt_delta = adapt_delta,
                                                                           max_treedepth = max_treedepth))

  samples <- as_draws_df(model)

  var_df <- samples[2:8]

  var_df <- samples %>%
    select(matches("^(sd_|sigma)")) %>%
    mutate(
      var_Person = sd_Person__Intercept^2,
      var_Item = sd_Item__Intercept^2,
      var_Occasion = sd_Occasion__Intercept^2,
      var_Person_Item = `sd_Person:Item__Intercept`^2,
      var_Person_Occasion = `sd_Person:Occasion__Intercept`^2,
      var_Item_Occasion = `sd_Item:Occasion__Intercept`^2,
      var_Error = sigma^2
    ) %>%
    select(
      starts_with("var")
    )

  final_df <- expand.grid(seq1, seq2)
  colnames(final_df) <- c(paste0("n_", col.facet1), paste0("n_", col.facet2))
  final_df$Lower_Bound <- 0
  final_df$Median <- 0
  final_df$Upper_Bound <- 0
  final_df$Placeholder <- 0

  for (i in seq(1, nrow(final_df))) {
    n_i = final_df[i,1]
    n_o = final_df[i,2]
    var_df <- var_df %>%
      mutate(
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
    ci <- quantile(var_df$G_coef, probs = probs)
    lower <- unname(ci[1])
    final_df$Lower_Bound[i] <- round(lower, rounded)
    final_df$Median[i] <- round(median(var_df$G_coef), rounded)
    upper <- unname(ci[2])
    final_df$Upper_Bound[i] <- round(upper, rounded)
    final_df$Placeholder[i] <- round(mean(var_df$G_coef > threshold), rounded)
  }
  names(final_df)[6] <- paste0("P(G > ", threshold, ")")
  return(final_df)
}
