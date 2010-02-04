\name{ipwpoint}
\Rdversion{1.1}
\alias{ipwpoint}
%- Also NEED an '\alias' for EACH other topic documented here.

\title{Estimate Inverse Probability Weights (Point Treatment)}

\description{Estimate inverse probability weights to fit marginal structural models in a point treatment situation. The exposure for which we want to estimate the causal effect can be binomial, multinomial, ordinal or continuous. Both stabilized and unstabilized weights can be estimated.}

\usage{
ipwpoint(exposure, family, link, numerator = NULL, denominator, data,
         trim = NULL, ...)
}

\arguments{
\item{exposure}{a vector, representing the exposure variable of interest. Both numerical and factor variables can be used. A binomial exposure variable should be coded using values \code{0}/\code{1}.}
\item{family}{is used to specify a family of link functions, used to model the relationship between the variables in \code{numerator} or \code{denominator} and \code{exposure}, respectively. Valid alternatives are \code{"binomial"},\code{"multinomial"}, \code{"ordinal"} and \code{"gaussian"}. A specific link function is then chosen using the argument \code{link}, as explained below. Regression models are fitted using \code{\link{glm}}, \code{\link{multinom}}, \code{\link{polr}} or \code{\link{glm}}, respectively.}
\item{link}{specifies the link function between the variables in \code{numerator} or \code{denominator} and \code{exposure}, respectively. For \code{family="binomial"} (fitted using \code{\link{glm}}) valid alternatives are \code{"logit"}, \code{"probit"}, \code{"cauchit"}, \code{"log"} and \code{"cloglog"}. For \code{family="multinomial"} this argument is ignored, and multinomial logistic regression models are always used (fitted using \code{\link{multinom}}). For \code{family="ordinal"} (fitted using \code{\link{polr}}) valid alternatives are \code{"logit"}, \code{"probit"}, \code{"cauchit"}, and \code{"cloglog"}. For \code{family="gaussian"} this argument is ignored, and a linear regression model with identity link is always used (fitted using \code{\link{glm}}).}
\item{numerator}{specifies the right-hand side of the model used to estimate the elements in the numerator of the inverse probability weights. When left unspecified, unstabilized weights, with a numerator of 1, are estimated.}
\item{denominator}{specifies the right-hand side of the model used to estimate the elements in the denominator of the inverse probability weights. Typically includes the variables specified in the numerator model, as well as confounders for which to correct.}
\item{data}{is a dataframe containing \code{exposure} and the variables used in \code{numerator} and \code{denominator}.}
\item{trim}{is an optional trim percentile (\code{0-0.5}). When specified, both untrimmed and trimmed weights are returned.}
\item{...}{are further arguments passed to the functions used to estimate the numerator and denominator models (see \code{family} and \code{link}).}
}

\details{
For each unit under observation, this function computes an inverse probability weight, which is the ratio of two probabilities:
\itemize{
\item the numerator contains the probability of the observed exposure level given observed values of stabilization factors (usually a set of baseline covariates). These probabilities are estimated using the model regressing \code{exposure} on the terms in \code{numerator}, using the link function indicated by \code{family} and \code{link}.
\item the denominator contains the probability of the observed exposure level given the observed values of a set of confounders, as well as the stabilization factors in the numerator. These probabilities are estimated using the model regressing \code{exposure} on the terms in \code{denominator}, using the link function indicated by \code{family} and \code{link}.}

When the models from which the elements in the numerator and denominator are predicted are correctly specified, and there is no unmeasured confounding, weighting the observations by the inverse probability weights adjusts for confounding of the effect of the exposure of interest. On the weighted dataset a marginal structural model can then be fitted, quantifying the causal effect of the exposure on the outcome of interest.

With \code{numerator} specified, stabilized weights are computed, otherwise unstabilized weighs with a numerator of 1 are computed. With a continuous exposure, using \code{family="gaussian"}, weights are computed using the ratio of predicted densities. Therefore, for \code{family="gaussian"} only stabilized weights can be used, since unstabilized weights would have infinity variance.
}

\value{
A list containing the following elements:
\item{ipw.weights }{is a vector containing inverse probability weights for each unit under observation. This vector is returned in the same order as the measurements contained in \code{data}, to facilitate merging.}
\item{weights.trimmed }{is a vector containing trimmed inverse probability weights for each unit under observation. This vector is only returned when \code{trim} is specified.}
\item{call }{is the original function call to \code{ipwpoint}.}
\item{num.mod }{is the numerator model, only returned when \code{numerator} is specified.}
\item{den.mod }{is the denominator model.}
}

\section{Missing values}{The \code{exposure} variable and the variables used in \code{numerator} and \code{denominator} should not contain missing values.}

\references{
Cole, S. R. & Hern�n, M. A. (2008). Constructing inverse probability weights for marginal structural models. \emph{American Journal of Epidemiology}, \emph{168}(6), 656-664.

Robins, J. M., Hern�n, M. A. & Brumback, B. A. (2000). Marginal structural models and causal inference in epidemiology. \emph{Epidemiology}, \emph{11}, 550-560.
}

\author{Willem M. van der Wal \email{w.m.vanderwal@amc.uva.nl}}

\note{
%%  ~~further notes~~
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{\code{\link{basdat}}, \code{\link{haartdat}}, \code{\link{healthdat}}, \code{\link{ipwplot}}, \code{\link{ipwpoint}}, \code{\link{ipwtm}}, \code{\link{timedat}}, \code{\link{tstartfun}}.}

\examples{

#load IQ, income and health data.
data(healthdat)

#IQ is confounder for the effect of income on health score.
#Estimate inverse probability weights to correct for confounding.
#Exposure allocation model is linear regression model.
temp <- ipwpoint(
	exposure = income,
	family = "gaussian",
	numerator = ~ 1,
	denominator = ~ iq,
	data = healthdat)

#plot inverse probability weights
graphics.off()
ipwplot(weights = temp$ipw.weights, logscale = FALSE, main = "Stabilized weights", xlim = c(0, 8))

#Marginal structural model for the causal effect of income on health score
#corrected for confounding by IQ using inverse probability weighting.
summary(glm(health ~ income, data = healthdat, weights = temp$ipw.weights))

#Compute basic bootstrap confidence interval for income parameter.
boot.fun <- function(dat, index){
    coef(glm(
        formula = health ~ income,
        data = dat[index,],
        weights = ipwpoint(
            exposure = income,
            family = "gaussian",
            numerator = ~ 1,
            denominator = ~ iq,
            data = dat[index,])$ipw.weights))[2]
    }
bootres <- boot(healthdat, boot.fun, 499);bootres
boot.ci(bootres, type = "basic")
}

% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
\keyword{htest}
\keyword{models}