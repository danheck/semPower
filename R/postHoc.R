
#' semPower.postHoc
#'
#' determine power (1-beta error) given alpha, df, and effect
#'
#' @param effect effect size specifying the discrepancy between H0 and H1
#' @param effect.measure type of effect, one of "RMSEA", "Mc", "GammaHat", "GFI", AGFI", "F0"
#' @param alpha alpha error
#' @param N the number of observations
#' @param df the model degrees of freedom
#' @param p the number of observed variables, required for effect.measure = "GammaHat", "GFI",  and "AGFI"
#' @param SigmaHat model implied covariance matrix
#' @param Sigma population covariance matrix
#' @return list
#' @examples
#' \dontrun{
#' power <- semPower.postHoc(effect = .05, effect.measure = "RMSEA", alpha = .05, N = 250, df = 200)
#' power
#' power <- semPower.postHoc(N = 1000, df = 5, SigmaHat = diag(4), Sigma = cov(matrix(rnorm(4*1000),  ncol=4)))
#' power
#' }
#' @export
semPower.postHoc <- function(effect = NULL, effect.measure = NULL, alpha = .05,
                             N = NULL, df = NULL, p = NULL,
                             SigmaHat = NULL, Sigma = NULL){

  validateInput('post-hoc', effect = effect, effect.measure = effect.measure,
                alpha = alpha, beta = NULL, power = NULL, abratio = NULL,
                N = N, df = df, p = p,
                SigmaHat = SigmaHat, Sigma = Sigma)

  if(!is.null(SigmaHat)){ # sufficient to check for on NULL matrix; primary validity check is in validateInput
    effect.measure <- 'F0'
    p <- ncol(SigmaHat)
  }

  fmin <- getF(effect, effect.measure, df, p, SigmaHat, Sigma)
  fit <- getIndices.F(fmin, df, p, SigmaHat, Sigma)
  ncp <- getNCP(fmin, N)

  beta <- pchisq(qchisq(alpha, df, lower.tail = F), df, ncp=ncp)
  power <- pchisq(qchisq(alpha, df, lower.tail = F), df, ncp=ncp, lower.tail = F)
  impliedAbratio <- alpha/beta


  result <- list(
    type = "post-hoc",
    alpha = alpha,
    beta = beta,
    power = power,
    impliedAbratio = impliedAbratio,
    ncp = ncp,
    fmin = fmin,
    effect = effect,
    effect.measure = effect.measure,
    N = N,
    df = df,
    p = p,
    chiCrit = qchisq(alpha, df,ncp = 0, lower.tail = F),
    rmsea = fit$rmsea,
    mc = fit$mc,
    gfi = fit$gfi,
    agfi = fit$agfi,
    srmr = fit$srmr,
    cfi = fit$cfi
  )

  class(result) <- "semPower.postHoc"
  result

}



#' semPower.postHoc.summary
#'
#' provide summary of post-hoc power analyses
#' @param result result object from semPower.posthoc
#' @export
summary.semPower.postHoc <- function(object, ...){

  out.table <- getFormattedResults('post-hoc', object)

  cat("\n semPower: Post-hoc power analysis\n")

  print(out.table, row.names = F, right = F)


}



############### UNIT TESTS

# pa.ph <- semPower.postHoc(effect = .015, effect.measure = "RMSEA", alpha = .05, N = 1000, df = 200)
# # summary(pa.ph)
# summary.semPower.postHoc(pa.ph)
#
# pa.ph <- semPower.postHoc(effect = .15, effect.measure = "RMSEA", alpha = .05, N = 1000, df = 200)
# # summary(pa.ph)
# summary.semPower.postHoc(pa.ph)
#
# pa.ph <- semPower.postHoc(effect = .00001, effect.measure = "RMSEA", alpha = .05, N = 10, df = 200)
# # summary(pa.ph)
# summary.semPower.postHoc(pa.ph)
#
# pa.ph <- semPower.postHoc(N = 1000, df = 5, SigmaHat = cov(matrix(rnorm(4*1000), ncol=4)), Sigma = cov(matrix(rnorm(4*1000),  ncol=4)))
# # summary(pa.ph)
# summary.semPower.postHoc(pa.ph)