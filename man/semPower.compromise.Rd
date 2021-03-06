% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/compromise.R
\name{semPower.compromise}
\alias{semPower.compromise}
\title{sempower.compromise}
\usage{
semPower.compromise(effect = NULL, effect.measure = NULL, abratio = 1, N,
  df, p = NULL, SigmaHat = NULL, Sigma = NULL)
}
\arguments{
\item{effect}{effect size specifying the discrepancy between H0 and H1}

\item{effect.measure}{type of effect, one of "F0","RMSEA", "Mc", "GFI", AGFI"}

\item{abratio}{the ratio of alpha to beta}

\item{N}{the number of observations}

\item{df}{the model degrees of freedom}

\item{p}{the number of observed variables, required for effect.measure = "GammaHat", "GFI",  and "AGFI"}

\item{SigmaHat}{model implied covariance matrix. Use in conjuntion with Sigma to define effect and effect.measure.}

\item{Sigma}{population covariance matrix. Use in conjuntion with SigmaHat to define effect and effect.measure.}
}
\value{
list
}
\description{
Performs a compromise power analysis, i.e. determines the critical chi-square along with the implied alpha and beta, given a specified alpha/beta ratio, effect, N, and df
}
\examples{
\dontrun{
cp.ph <- semPower.compromise(effect = .08, effect.measure = "RMSEA", abratio = 1, N = 250, df = 200)
summary(cp.ph)
}
}
