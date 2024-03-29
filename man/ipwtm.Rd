 \name{ipwtm}
\Rdversion{1.1}
\alias{ipwtm}

\title{Estimate Inverse Probability Weights (Time Varying)}

\description{Estimate inverse probability weights to fit marginal structural models, with a time-varying exposure and time-varying confounders. Within each unit under observation this function computes inverse probability weights at each time point during follow-up. The exposure can be binomial, multinomial, ordinal or continuous. Both stabilized and unstabilized weights can be estimated.}

\usage{ipwtm(exposure, family, link, numerator = NULL, denominator, id,
       tstart, timevar, type, data, corstr = "ar1", trunc = NULL,
       ...)}

\arguments{
\item{exposure}{vector, representing the exposure of interest. Both numerical and categorical variables can be used. A binomial exposure variable should be coded using values \code{0}/\code{1}.}
\item{family}{specifies a family of link functions, used to model the relationship between the variables in \code{numerator} or \code{denominator} and \code{exposure}, respectively. Alternatives are \code{"binomial"}, \code{"survival"}, \code{"multinomial"}, \code{"ordinal"} and \code{"gaussian"}. A specific link function is then chosen using the argument \code{link}, as explained below. Regression models are fitted using \code{\link{glm}}, \code{\link{coxph}}, \code{\link{multinom}}, \code{\link{polr}} or \code{\link{geeglm}}, respectively.}
\item{link}{specifies the specific link function between the variables in \code{numerator} or \code{denominator} and exposure, respectively. For \code{family="binomial"} (fitted using \code{\link{glm}}) alternatives are \code{"logit"}, \code{"probit"}, \code{"cauchit"}, \code{"log"} and \code{"cloglog"}. For \code{family="survival"} this argument is ignored, and Cox proportional hazards models are always used (fitted using \code{\link{coxph}}). For \code{family="multinomial"} this argument is ignored, and multinomial logistic regression models are always used (fitted using \code{\link{multinom}}). For \code{family=} \code{"ordinal"} (fitted using \code{\link{polr}}) alternatives are \code{"logit"}, \code{"probit"}, \code{"cauchit"}, and \code{"cloglog"}. For \code{family="gaussian"} this argument is ignored, and GEE models with an identity link are always used (fitted using \code{\link{geeglm}}.}
\item{numerator}{is a formula, specifying the right-hand side of the model used to estimate the elements in the numerator of the inverse probability weights. When left unspecified, unstabilized weights with a numerator of 1 are estimated.}
\item{denominator}{is a formula, specifying the right-hand side of the model used to estimate the elements in the denominator of the inverse probability weights.}
\item{id}{vector, uniquely identifying the units under observation (typically patients) within which the longitudinal measurements are taken.}
\item{tstart}{numerical vector, representing the starting time of follow-up intervals, using the counting process notation. This argument is only needed when \code{family=} \code{"survival"}, otherwise it is ignored. The Cox proportional hazards models are fitted using counting process data. Since a switch in exposure level can occur at the start of follow-up, \code{tstart} should be negative for the first interval (with \code{timevar=0}) within each patient.}
\item{timevar}{numerical vector, representing follow-up time, starting at \code{0}. This variable is used as the end time of follow-up intervals, using the counting process notation, when \code{family="survival"}.}
\item{type}{specifies the type of exposure. Alternatives are \code{"first"}, \code{"cens"} and \code{"all"}. With \code{type="first"}, weights are estimated up to the first switch from the lowest exposure value (typically \code{0} or the first factor level) to any other value. After this switch, weights will then be constant. Such a weight is e.g. used when estimating the effect of ``initiation of HAART'' on mortality (see example 1 below). \code{type="first"} is currently only implemented for \code{"binomial"}, \code{"survival"}, \code{"multinomial"} and \code{"ordinal"} families. With \code{type="cens"} inverse probability of censoring weights (IPCW) are estimated as defined in appendix 1 in Cole & Hernán (2008). IPCW is illustrated in example 1 below. \code{type="cens"} is currently only implemented for \code{"binomial"} and \code{"survival"} families. With \code{type="all"}, all time points are used to estimate weights. \code{type="all"} is implemented only for the \code{"binomial"} and \code{"gaussian"} family.}
\item{data}{dataframe containing \code{exposure}, variables in \code{numerator} and \code{denominator}, \code{id}, \code{tstart} and \code{timevar}.}
\item{corstr}{correlation structure, only needed when using \code{family = "gaussian"}. Defaults to "ar1". See \code{\link{geeglm}} for details.}
\item{trunc}{optional truncation percentile (0-0.5). E.g. when \code{trunc = 0.01}, the left tail is truncated to the 1st percentile, and the right tail is truncated to the 99th percentile. When specified, both un-truncated and truncated weights are returned.}
\item{...}{are further arguments passed to the function that is used to estimate the numerator and denominator models (the function is chosen using \code{family}).}
}

\details{
Within each unit under observation i (usually patients), this function computes inverse probability weights at each time point j during follow-up. These weights are the cumulative product over all previous time points up to j of the ratio of two probabilities:
\itemize{
\item the numerator contains at each time point the probability of the observed exposure level given observed values of stabilization factors and the observed exposure history up to the time point before j. These probabilities are estimated using the model regressing \code{exposure} on the terms in \code{numerator}, using the link function indicated by \code{family} and \code{link}.
\item the denominator contains at each time point the probability of the observed exposure level given the observed history of time varying confounders up to j, as well as the stabilization factors in the numerator and the observed exposure history up to the time point before j. These probabilities are estimated using the model regressing \code{exposure} on the terms in \code{denominator}, using the link function indicated by \code{family} and \code{link}.}

When the models from which the elements in the numerator and denominator are predicted are correctly specified, and there is no unmeasured confounding, weighting observations ij by the inverse probability weights adjusts for confounding of the effect of the exposure of interest. On the weighted dataset a marginal structural model can then be fitted, quantifying the causal effect of the exposure on the outcome of interest.

With \code{numerator} specified, stabilized weights are computed, otherwise unstabilized weights with a numerator of 1 are computed. With a continuous exposure, using \code{family = "gaussian"}, weights are computed using the ratio of predicted densities at each time point. Therefore, for \code{family = "gaussian"} only stabilized weights can be used, since unstabilized weights would have infinity variance.
}

\value{
A list containing the following elements:
\item{ipw.weights }{vector containing inverse probability weights for each observation. Returned in the same order as the observations in \code{data}, to facilitate merging.}
\item{weights.trunc }{vector containing truncated inverse probability weights, only returned when \code{trunc} is specified.}
\item{call }{the original function call.}
\item{selvar }{selection variable. With \code{type = "first"}, \code{selvar = 1} within each unit under observation, up to and including the first time point at which a switch from the lowest value of \code{exposure} to any other value is made, and \code{selvar = 0} after the first switch. For \code{type = "all"}, \code{selvar = 1} for all measurements. The numerator and denominator models are fitted only on observations with \code{selvar = 1}. Returned in the same order as observations in \code{data}, to facilitate merging.}
\item{num.mod }{the numerator model, only returned when \code{numerator} is specified.}
\item{den.mod }{the denominator model.}
}

\section{Missing values}{Currently, the \code{exposure} variable and the variables used in \code{numerator} and \code{denominator}, \code{id}, \code{tstart} and \code{timevar} should not contain missing values.}

\references{
Cole, S.R. & Hernán, M.A. (2008). Constructing inverse probability weights for marginal structural models. \emph{American Journal of Epidemiology}, \bold{168}(6), 656-664. \url{https://pubmed.ncbi.nlm.nih.gov:443/18682488/}.

Robins, J.M., Hernán, M.A. & Brumback, B.A. (2000). Marginal structural models and causal inference in epidemiology. \emph{Epidemiology}, \bold{11}, 550-560. \url{https://pubmed.ncbi.nlm.nih.gov/10955408/}.

Van der Wal W.M. & Geskus R.B. (2011). ipw: An R Package for Inverse  Probability Weighting. \emph{Journal of Statistical Software}, \bold{43}(13), 1-23. \doi{10.18637/jss.v043.i13}.
}

\author{Willem M. van der Wal \email{willem@vanderwalresearch.com}, Ronald B. Geskus \email{rgeskus@oucru.org}}

\seealso{\code{\link{basdat}}, \code{\link{haartdat}}, \code{\link{ipwplot}}, \code{\link{ipwpoint}}, \code{\link{ipwtm}}, \code{\link{timedat}}, \code{\link{tstartfun}}.}

\examples{
########################################################################
#EXAMPLE 1

#Load longitudinal data from HIV positive individuals.
data(haartdat)

#CD4 is confounder for the effect of initiation of HAART therapy on mortality.
#Estimate inverse probability weights to correct for confounding.
#Exposure allocation model is Cox proportional hazards model.
temp <- ipwtm(
   exposure = haartind,
   family = "survival",
   numerator = ~ sex + age,
   denominator = ~ sex + age + cd4.sqrt,
   id = patient,
   tstart = tstart,
   timevar = fuptime,
   type = "first",
   data = haartdat)

#plot inverse probability weights
graphics.off()
ipwplot(weights = temp$ipw.weights, timevar = haartdat$fuptime,
  binwidth = 100, ylim = c(-1.5, 1.5), main = "Stabilized inverse probability weights")

#CD4 count has an effect both on dropout and mortality, which causes informative censoring.
#Use inverse probability of censoring weighting to correct for effect of CD4 on dropout.
#Use Cox proportional hazards model for dropout.
temp2 <- ipwtm(
   exposure = dropout,
   family = "survival",
   numerator = ~ sex + age,
   denominator = ~ sex + age + cd4.sqrt,
   id = patient,
   tstart = tstart,
   timevar = fuptime,
   type = "cens",
   data = haartdat)

#plot inverse probability of censoring weights
graphics.off()
ipwplot(weights = temp2$ipw.weights, timevar = haartdat$fuptime,
  binwidth = 100, ylim = c(-1.5, 1.5), main = "Stabilized inverse probability of censoring weights")

#MSM for the causal effect of initiation of HAART on mortality.
#Corrected both for confounding and informative censoring.
#With robust standard error obtained using cluster().
require(survival)
summary(coxph(Surv(tstart, fuptime, event) ~ haartind + cluster(patient),
   data = haartdat, weights = temp$ipw.weights*temp2$ipw.weights))

#uncorrected model
summary(coxph(Surv(tstart, fuptime, event) ~ haartind, data = haartdat))

########################################################################
#EXAMPLE 2

data(basdat)
data(timedat)

#Aim: to model the causal effect of active tuberculosis (TB) on mortality.
#Longitudinal CD4 is a confounder as well as intermediate for the effect of TB.

#process original measurements
   #check for ties (not allowed)
      table(duplicated(timedat[,c("id", "fuptime")]))
   #take square root of CD4 because of skewness
      timedat$cd4.sqrt <- sqrt(timedat$cd4count)
   #add TB time to dataframe
      timedat <- merge(timedat, basdat[,c("id", "Ttb")], by = "id", all.x = TRUE)
   #compute TB status
      timedat$tb.lag <- ifelse(with(timedat, !is.na(Ttb) & fuptime > Ttb), 1, 0)
   #longitudinal CD4-model
      require(nlme)
      cd4.lme <- lme(cd4.sqrt ~ fuptime + tb.lag, random = ~ fuptime | id,
      data = timedat)

#build new dataset:
#rows corresponding to TB-status switches, and individual end times
   times <- sort(unique(c(basdat$Ttb, basdat$Tend)))
   startstop <- data.frame(
      id = rep(basdat$id, each = length(times)),
      fuptime = rep(times, nrow(basdat)))
   #add baseline data to dataframe
      startstop <- merge(startstop, basdat, by = "id", all.x = TRUE)
   #limit individual follow-up using Tend
      startstop <- startstop[with(startstop, fuptime <= Tend),]
   startstop$tstart <- tstartfun(id, fuptime, startstop) #compute tstart (?tstartfun)
   #indicate TB status
      startstop$tb <- ifelse(with(startstop, !is.na(Ttb) & fuptime >= Ttb), 1, 0)
   #indicate TB status at previous time point
      startstop$tb.lag <- ifelse(with(startstop, !is.na(Ttb) & fuptime > Ttb), 1, 0)
   #indicate death
      startstop$event <- ifelse(with(startstop, !is.na(Tdeath) & fuptime >= Tdeath),
      1, 0)
   #impute CD4, based on TB status at previous time point.
      startstop$cd4.sqrt <- predict(cd4.lme, newdata = data.frame(id = startstop$id,
         fuptime = startstop$fuptime, tb.lag = startstop$tb.lag))

#compute inverse probability weights
   temp <- ipwtm(
      exposure = tb,
      family = "survival",
      numerator = ~ 1,
      denominator = ~ cd4.sqrt,
      id = id,
      tstart = tstart,
      timevar = fuptime,
      type = "first",
      data = startstop)
   summary(temp$ipw.weights)
   ipwplot(weights = temp$ipw.weights, timevar = startstop$fuptime, binwidth = 100)

#models
   #IPW-fitted MSM, using cluster() to obtain robust standard error estimate
      require(survival)
      summary(coxph(Surv(tstart, fuptime, event) ~ tb + cluster(id),
      data = startstop, weights = temp$ipw.weights))
   #unadjusted
      summary(coxph(Surv(tstart, fuptime, event) ~ tb, data = startstop))
   #adjusted using conditioning: part of the effect of TB is adjusted away
      summary(coxph(Surv(tstart, fuptime, event) ~ tb + cd4.sqrt, data = startstop))

## Not run: 
#compute bootstrap CI for TB parameter (takes a few hours)
#taking into account the uncertainty introduced by modelling longitudinal CD4
#taking into account the uncertainty introduced by estimating the inverse probability weights
#robust with regard to weights unequal to 1
#  require(boot)
#  boot.fun <- function(data, index, data.tm){
#     data.samp <- data[index,]
#     data.samp$id.samp <- 1:nrow(data.samp)
#     data.tm.samp <- do.call("rbind", lapply(data.samp$id.samp, function(id.samp) {
#       cbind(data.tm[data.tm$id == data.samp$id[data.samp$id.samp == id.samp],],
#         id.samp = id.samp)
#       }
#     ))
#     cd4.lme <- lme(cd4.sqrt ~ fuptime + tb.lag, random = ~ fuptime | id.samp, data = data.tm.samp)
#     times <- sort(unique(c(data.samp$Ttb, data.samp$Tend)))
#     startstop.samp <- data.frame(id.samp = rep(data.samp$id.samp, each = length(times)),
#                                  fuptime = rep(times, nrow(data.samp)))
#     startstop.samp <- merge(startstop.samp, data.samp, by = "id.samp", all.x = TRUE)
#     startstop.samp <- startstop.samp[with(startstop.samp, fuptime <= Tend),]
#     startstop.samp$tstart <- tstartfun(id.samp, fuptime, startstop.samp)
#     startstop.samp$tb <- ifelse(with(startstop.samp, !is.na(Ttb) & fuptime >= Ttb), 1, 0)
#     startstop.samp$tb.lag <- ifelse(with(startstop.samp, !is.na(Ttb) & fuptime > Ttb), 1, 0)
#     startstop.samp$event <- ifelse(with(startstop.samp, !is.na(Tdeath) & fuptime >= Tdeath), 1, 0)
#     startstop.samp$cd4.sqrt <- predict(cd4.lme, newdata = data.frame(id.samp =
#       startstop.samp$id.samp, fuptime = startstop.samp$fuptime, tb.lag = startstop.samp$tb.lag))
#
#     return(coef(coxph(Surv(tstart, fuptime, event) ~ tb, data = startstop.samp,
#        weights = ipwtm(
#             exposure = tb,
#             family = "survival",
#             numerator = ~ 1,
#             denominator = ~ cd4.sqrt,
#             id = id.samp,
#             tstart = tstart,
#             timevar = fuptime,
#             type = "first",
#             data = startstop.samp)$ipw.weights))[1])
#     }
#  bootres <- boot(data = basdat, statistic = boot.fun, R = 999, data.tm = timedat)
#  bootres
#  boot.ci(bootres, type = "basic")
#
## End(Not run)
}

\keyword{htest}
\keyword{models}
