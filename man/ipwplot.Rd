\name{ipwplot}
\Rdversion{1.1}
\alias{ipwplot}

\title{Plot Inverse Probability Weights
}
\description{
For time varying weights: display boxplots within strata of follow-up time.
For point treatment weights: display density plot.
}

\usage{
ipwplot(weights, timevar = NULL, binwidth = NULL, logscale = TRUE,
        xlab = NULL, ylab = NULL, main = "", ref = TRUE, ...)
}

\arguments{
\item{weights}{numerical vector of inverse probability weights to plot.}
\item{timevar}{numerical vector representing follow-up time. When specified, boxplots within strata of follow-up time are displayed. When left unspecified, a density plot is displayed.}
\item{binwidth}{numerical value indicating the width of the intervals of follow-up time; for each interval a boxplot is made. Ignored when \code{timevar} is not specified.}
\item{logscale}{logical value. If \code{TRUE}, weights are plotted on a logarithmic scale.}
\item{xlab}{label for the horizontal axis.}
\item{ylab}{label for the vertical axis.}
\item{main}{main title for the plot.}
\item{ref}{logical value. If \code{TRUE}, a reference line is plotted at \code{y=1}.}
\item{\dots}{additional arguments passed to \code{\link{boxplot}} (when \code{timevar} is specified) or \code{\link{plot}} (when \code{timevar} is not specified).}
}

\value{
A plot is displayed.
}

\references{
Van der Wal W.M. & Geskus R.B. (2011). ipw: An R Package for Inverse  Probability Weighting. \emph{Journal of Statistical Software}, \bold{43}(13), 1-23. \doi{10.18637/jss.v043.i13}.
}

\author{Willem M. van der Wal \email{willem@vanderwalresearch.com}, Ronald B. Geskus \email{rgeskus@oucru.org}}

\seealso{\code{\link{basdat}}, \code{\link{haartdat}}, \code{\link{ipwplot}}, \code{\link{ipwpoint}}, \code{\link{ipwtm}}, \code{\link{timedat}}, \code{\link{tstartfun}}.}

\examples{
#see ?ipwpoint and ?ipwtm for examples
}

\keyword{hplot}
