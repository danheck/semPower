
#' sempower.compromise
#'
#' Performs a compromise power analysis, i.e. determines the critical chi-square along with the implied alpha and beta, given a specified alpha/beta ratio, effect, N, and df
#'
#' @param effect effect size specifying the discrepancy between H0 and H1
#' @param effect.measure type of effect, one of "RMSEA", "Mc", "GammaHat", "GFI", AGFI", "F0"
#' @param abratio the ratio of alpha to beta
#' @param N the number of observations
#' @param df the model degrees of freedom
#' @param p the number of observed variables, required for effect.measure = "GammaHat", "GFI",  and "AGFI"
#' @param SigmaHat model implied covariance matrix
#' @param Sigma population covariance matrix
#' @return list
#' @examples
#' \dontrun{
#' cp.ph <- sempower.compromise(effect = .08, effect.measure = "RMSEA", abratio = 1, N = 250, df = 200)
#' summary(cp.ph)
#' }
#' @export
semPower.compromise  <- function(effect = NULL, effect.measure = NULL,
                                 abratio = 1,
                                 N = NULL, df = NULL, p = NULL,
                                 SigmaHat = NULL, Sigma = NULL){


  validateInput('compromise', effect = effect, effect.measure = effect.measure,
                alpha = NULL, beta = NULL, power = NULL, abratio = abratio,
                N = N, df = df, p = p,
                SigmaHat = SigmaHat, Sigma = Sigma)


  if(!is.null(SigmaHat)){ # sufficient to check for on NULL matrix; primary validity check is in validateInput
    effect.measure <- 'F0'
    p <- ncol(SigmaHat)
  }

  fmin <- getF(effect, effect.measure, df, p, SigmaHat, Sigma)
  fit <- getIndices.F(fmin, df, p, SigmaHat, Sigma)
  ncp <- getNCP(fmin, N)
  log.abratio <- log(abratio)

  if(ncp >= 1e5)
    warning('ncp is larger than 1e5, this is going to cause trouble')


  # determine max/min chi for valid alpha/beta prob
  max <- min <- NA
  # central chi always gives reusult up to 1e-320
  max <- qchisq(log(1e-320), df, lower=F, log.p = T)

  # non-central chi accuracy is usaually lower, depending on df and ncp
  pmin <- -Inf
  testp <- 1e-320
  while(is.infinite(pmin)){
    testp <- testp * 10
    testv <- max(log(1e-320), (log.abratio + log(testp)))
    min <- qchisq(testv, df,  ncp , log.p = T)
    pmin <- pchisq(min, df, ncp, log.p = T) # beta
  }

  # cannot determine critchi when implied errors are too small
  bPrecisionWarning <- (min > max)

  if(!bPrecisionWarning){
    # rough estm
    start <- df + ncp/3
    chiCritOptim <- optim(par = c(start), fn = getErrorDiff,
                          df=df, ncp=ncp, log.abratio = log.abratio,
                          method='L-BFGS-B', lower=min, upper=max)

    chiCrit <- chiCritOptim$par
    impliedAlpha <- pchisq(chiCrit, df, lower=F)
    impliedBeta <- pchisq(chiCrit, df, ncp)
    impliedAbratio <- impliedAlpha/impliedBeta
    impliedPower <- 1-impliedBeta

  }else{
    chiCrit <- 0
    impliedAlpha <- 0
    impliedBeta <- 0
    impliedAbratio <- 1
    impliedPower <- 1
  }


  result <- list(
    type = "post-hoc-compromise",
    desiredAbratio = abratio,
    chiCrit = chiCrit,
    impliedAlpha = impliedAlpha,
    impliedBeta = impliedBeta,
    impliedAbratio = impliedAbratio,
    impliedPower = impliedPower,
    ncp = ncp,
    fmin = fmin,
    effect = effect,
    effect.measure = effect.measure,
    N = N,
    df = df,
    p = p,
    rmsea = fit$rmsea,
    mc = fit$mc,
    gfi = fit$gfi,
    agfi = fit$agfi,
    srmr = fit$srmr,
    cfi = fit$cfi,
    max = max,
    min = min,
    bPrecisionWarning = bPrecisionWarning
  )

  class(result) <- "semPower.compromise"

  result
}


#' getErrorDiff
#'
#' determine the squared log-difference between alpha and beta error given a certain chi-square value from central chi-square(df) and a non-central chi-square(df, ncp) distribution.
#'
#' @param critChiSquare evaluated chi-squared value
#' @param df the model degrees of freedom
#' @param ncp the non-centrality parameter
#' @param log.abratio log(alpha/beta)
#' @return squared difference between alpha and beta on a log scale
#' @examples
#' \dontrun{
#' errorDiff <- get.error.diff(critChiSquare = 300, df = 200, ncp = 600)
#' errorDiff
#' }
#' @export
#'
getErrorDiff <- function(critChiSquare, df, ncp, log.abratio){

  alpha <- pchisq(critChiSquare, df, lower=F, log=T)
  beta <- pchisq(critChiSquare, df, ncp, log=T)

  if(is.infinite(beta) || is.infinite(alpha)){

    warning('alpha or beta is too small')
    diff <- 0

  }else{

    diff <- (alpha - (log.abratio+beta))^2     # note log scale

  }

  diff
}


#

#' summary.sempower.compromise
#'
#' provide summary of compromise post-hoc power analyses
#' @param result result object from semPower.compromise.posthoc
#' @export
summary.semPower.compromise <- function(object, ...){

  out.table <- getFormattedResults('compromise', object)

  cat("\n semPower: Compromise power analysis\n")

  if(object$bPrecisionWarning)
    cat("\n\n WARNING: Alpha and/or Beta are smaller than 1e-240. Cannot determine critical Chi-Square exactly due to machine precision.")

  print(out.table, row.names = F, right = F)


}


############### UNIT TESTS

# result <- semPower.compromise(effect = .015, effect.measure = "RMSEA", abratio = 1, N = 1000, df = 200)
#
# cp.ph <- semPower.compromise(effect = .015, effect.measure = "RMSEA", abratio = 1, N = 1000, df = 200)
# # summary(cp.ph)
# summary.semPower.compromise(cp.ph)
#
# cp.ph <- semPower.compromise(effect = .05, effect.measure = "RMSEA", abratio = .2, N = 1000, df = 200, p =10)
# # summary(cp.ph)
# summary.semPower.compromise(cp.ph)
#
# cp.ph <- semPower.compromise(effect = .05, effect.measure = "RMSEA", abratio = 1, N = 5000, df = 2000)
# # summary(cp.ph)
# summary.semPower.compromise(cp.ph)


