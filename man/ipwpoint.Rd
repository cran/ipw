\name{ipwpoint}
\Rdversion{1.1}
\alias{ipwpoint}

\title{Estimate Inverse Probability Weights (Point Treatment)}

\description{Estimate inverse probability weights to fit marginal structural models in a point treatment situation. The exposure for which we want to estimate the causal effect can be binomial, multinomial, ordinal or continuous. Both stabilized and unstabilized weights can be estimated.}

\usage{
ipwpoint(exposure, family, link, numerator = NULL, denominator,
         data, trunc = NULL, ...)
}

\arguments{
\item{exposure}{a vector, representing the exposure variable of interest. Both numerical and categorical variables can be used. A binomial exposure variable should be coded using values \code{0}/\code{1}.}
\item{family}{is used to specify a family of link functions, used to model the relationship between the variables in \code{numerator} or \code{denominator} and \code{exposure}, respectively. Alternatives are \code{"binomial"},\code{"multinomial"}, \code{"ordinal"} and \code{"gaussian"}. A specific link function is then chosen using the argument \code{link}, as explained below. Regression models are fitted using \code{\link{glm}}, \code{\link{multinom}}, \code{\link{polr}} or \code{\link{glm}}, respectively.}
\item{link}{specifies the link function between the variables in \code{numerator} or \code{denominator} and \code{exposure}, respectively. For \code{family = "binomial"} (fitted using \code{\link{glm}}) alternatives are \code{"logit"}, \code{"probit"}, \code{"cauchit"}, \code{"log"} and \code{"cloglog"}. For \code{family = "multinomial"} this argument is ignored, and multinomial logistic regression models are always used (fitted using \code{\link{multinom}}). For \code{family = }\code{"ordinal"} (fitted using \code{\link{polr}}) alternatives are \code{"logit"}, \code{"probit"}, \code{"cauchit"}, and \code{"cloglog"}. For \code{family = "gaussian"} this argument is ignored, and a linear regression model with identity link is always used (fitted using \code{\link{glm}}).}
\item{numerator}{is a formula, specifying the right-hand side of the model used to estimate the elements in the numerator of the inverse probability weights. When left unspecified, unstabilized weights with a numerator of 1 are estimated.}
\item{denominator}{is a formula, specifying the right-hand side of the model used to estimate the elements in the denominator of the inverse probability weights. This typically includes the variables specified in the numerator model, as well as confounders for which to correct.}
\item{data}{is a dataframe containing \code{exposure} and the variables used in \code{numerator} and \code{denominator}.}
\item{trunc}{optional truncation percentile (0-0.5). E.g. when \code{trunc = 0.01}, the left tail is truncated to the 1st percentile, and the right tail is truncated to the 99th percentile.When specified, both un-truncated and truncated weights are returned.}
\item{...}{are further arguments passed to the function that is used to estimate the numerator and denominator models (the function is chosen using \code{family}).}
}

\details{
For each unit under observation, this function computes an inverse probability weight, which is the ratio of two probabilities:
\itemize{
\item the numerator contains the probability of the observed exposure level given observed values of stabilization factors (usually a set of baseline covariates). These probabilities are estimated using the model regressing \code{exposure} on the terms in \code{numerator}, using the link function indicated by \code{family} and \code{link}.
\item the denominator contains the probability of the observed exposure level given the observed values of a set of confounders, as well as the stabilization factors in the numerator. These probabilities are estimated using the model regressing \code{exposure} on the terms in \code{denominator}, using the link function indicated by \code{family} and \code{link}.}

When the models from which the elements in the numerator and denominator are predicted are correctly specified, and there is no unmeasured confounding, weighting the observations by the inverse probability weights adjusts for confounding of the effect of the exposure of interest. On the weighted dataset a marginal structural model can then be fitted, quantifying the causal effect of the exposure on the outcome of interest.

With \code{numerator} specified, stabilized weights are computed, otherwise unstabilized weighs with a numerator of 1 are computed. With a continuous exposure, using \code{family = "gaussian"}, weights are computed using the ratio of predicted densities. Therefore, for \code{family = "gaussian"} only stabilized weights can be used, since unstabilized weights would have infinity variance.
}

\value{
A list containing the following elements:
\item{ipw.weights }{is a vector containing inverse probability weights for each unit under observation. This vector is returned in the same order as the measurements contained in \code{data}, to facilitate merging.}
\item{weights.trunc }{is a vector containing truncated inverse probability weights for each unit under observation. This vector is only returned when \code{trunc} is specified.}
\item{call }{is the original function call to \code{ipwpoint}.}
\item{num.mod }{is the numerator model, only returned when \code{numerator} is specified.}
\item{den.mod }{is the denominator model.}
}

\section{Missing values}{Currently, the \code{exposure} variable and the variables used in \code{numerator} and \code{denominator} should not contain missing values.}

\references{
Cole, S.R. & Hernán, M.A. (2008). Constructing inverse probability weights for marginal structural models. \emph{American Journal of Epidemiology}, \bold{168}(6), 656-664.

Robins, J.M., Hernán, M.A. & Brumback, B.A. (2000). Marginal structural models and causal inference in epidemiology. \emph{Epidemiology}, \bold{11}, 550-560.

Van der Wal W.M. & Geskus R.B. (2011). ipw: An R Package for Inverse  Probability Weighting. \emph{Journal of Statistical Software}, \bold{43}(13), 1-23. \doi{10.18637/jss.v043.i13}.
}

\author{Willem M. van der Wal \email{willem@vanderwalresearch.com}, Ronald B. Geskus \email{rgeskus@oucru.org}}

\seealso{\code{\link{basdat}}, \code{\link{haartdat}}, \code{\link{ipwplot}}, \code{\link{ipwpoint}}, \code{\link{ipwtm}}, \code{\link{timedat}}, \code{\link{tstartfun}}.}

\examples{
#Simulate data with continuous confounder and outcome, binomial exposure.
#Marginal causal effect of exposure on outcome: 10.
n <- 1000
simdat <- data.frame(l = rnorm(n, 10, 5))
a.lin <- simdat$l - 10
pa <- exp(a.lin)/(1 + exp(a.lin))
simdat$a <- rbinom(n, 1, prob = pa)
simdat$y <- 10*simdat$a + 0.5*simdat$l + rnorm(n, -10, 5)
simdat[1:5,]

#Estimate ipw weights.
temp <- ipwpoint(
   exposure = a,
   family = "binomial",
   link = "logit",
   numerator = ~ 1,
   denominator = ~ l,
   data = simdat)
summary(temp$ipw.weights)

#Plot inverse probability weights
graphics.off()
ipwplot(weights = temp$ipw.weights, logscale = FALSE,
   main = "Stabilized weights", xlim = c(0, 8))

#Examine numerator and denominator models.
summary(temp$num.mod)
summary(temp$den.mod)

#Paste inverse probability weights
simdat$sw <- temp$ipw.weights

#Marginal structural model for the causal effect of a on y
#corrected for confounding by l using inverse probability weighting
#with robust standard error from the survey package.
require("survey")
msm <- (svyglm(y ~ a, design = svydesign(~ 1, weights = ~ sw,
   data = simdat)))
coef(msm)
confint(msm)


## Not run: 
#Compute basic bootstrap confidence interval .
#require(boot)
#boot.fun <- function(dat, index){
#   coef(glm(
#       formula = y ~ a,
#       data = dat[index,],
#       weights = ipwpoint(
#           exposure = a,
#           family = "gaussian",
#           numerator = ~ 1,
#           denominator = ~ l,
#           data = dat[index,])$ipw.weights))[2]
#   }
#bootres <- boot(simdat, boot.fun, 499);bootres
#boot.ci(bootres, type = "basic")

## End(Not run)

}

\keyword{htest}
\keyword{models}
