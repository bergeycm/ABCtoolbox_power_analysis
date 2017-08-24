#!/usr/bin/env Rscript

# ----------------------------------------------------------------------------------------
# --- Analyze and summarize estimator output for all PODs
# ----------------------------------------------------------------------------------------

options(stringsAsFactors=FALSE)

library(ggplot2)

# ----------------------------------------------------------------------------------------
# --- 1000 1000

ests = read.table("results/estimator_output/ABCestimator.DNA1000_STR1000_IND25.results.txt",
    fill=TRUE)
out.prefix = "results/plots/ABCestimator.DNA1000_STR1000_IND25"

# ----------------------------------------------------------------------------------------
# --- 5000 5000

ests = read.table("results/estimator_output/ABCestimator.DNA5000_STR5000_IND25.results.txt",
    fill=TRUE)
out.prefix = "results/plots/ABCestimator.DNA5000_STR5000_IND25"

# ----------------------------------------------------------------------------------------
# --- 1000 40000

ests = read.table("results/estimator_output/ABCestimator.DNA1000_STR40000_IND25.results.txt",
    fill=TRUE)
out.prefix = "results/plots/ABCestimator.DNA1000_STR40000_IND25"

# ----------------------------------------------------------------------------------------


params = c("LOG_N_NOW", "LOG_N_ANCESTRAL", "T_SHRINK", "STR_MUTATION", "MTDNA_MUTATION",
    "GAMMA", "N_NOW", "N_ANCESTRAL", "N_ANCESTRAL_REL", "N_NOW_REL", "N_NOW_MTDNA")

if (grepl("40000", out.prefix)) {
    sum.stats = c("H_1", "S_1", "D_1", "FS_1", "Pi_1", "GW_1", "R_1", "Rsd_1")
} else {
    sum.stats = c("K_1", "mean_K", "H_1", "Hsd_1", "mean_H", "tot_H_1", "S_1", "prS_1",
                  "mean_S", "tot_S", "D_1", "mean_D", "FS_1", "mean_FS", "Pi_1", "mean_Pi",
                  "tot_H", "GW_1", "GWsd_1", "mean_GW", "tot_GW", "NGW_1", "NGWsd_1",
                  "mean_NGW", "R_1", "Rsd_1", "mean_R", "tot_R")
}

posterior.chracteristic.types = c("mode", "mean", "median",
                                  "q50_lower", "q50_upper",
                                  "q90_lower", "q90_upper",
                                  "q95_lower", "q95_upper",
                                  "q99_lower", "q99_upper",
                                  "HDI50_lower", "HDI50_upper",
                                  "HDI90_lower", "HDI90_upper",
                                  "HDI95_lower", "HDI95_upper",
                                  "HDI99_lower", "HDI99_upper")

# Line in file is one more than "iter_num" variable or "Sim" column below
# but represents the line number in the parallelized output
est.col.names = c("line")

# Parameter values for this POD
est.col.names = c(est.col.names, c("Sim", params))

# Summary stat values
est.col.names = c(est.col.names, sum.stats)

# Variable with states {0,1,2,3}
est.col.names = c(est.col.names, "dataSet")

est.col.names = c(est.col.names, apply(
    expand.grid(posterior.chracteristic.types, params)[,c(2,1)],
    1, paste, collapse="_"))

est.col.names = c(est.col.names, "num_sim_points")

names(ests) = est.col.names

# Remove fouled up estimates
ests = ests[(ests$LOG_N_ANCESTRAL_mean != "LOG_N_ANCESTRAL_mean") &
            (ests$LOG_N_ANCESTRAL_mean != "-nan"),]

# ----------------------------------------------------------------------------------------
# --- Do plotting
# ----------------------------------------------------------------------------------------

# --- Plot "real" value of POD vs median of posterior, colored by number of points

ests$T_SHRINK_median = as.numeric(ests$T_SHRINK_median)
ests$LOG_N_NOW_median = as.numeric(ests$LOG_N_NOW_median)
ests$LOG_N_ANCESTRAL_median = as.numeric(ests$LOG_N_ANCESTRAL_median)

ests$T_SHRINK_q50_upper = as.numeric(ests$T_SHRINK_q50_upper)
ests$T_SHRINK_q50_lower = as.numeric(ests$T_SHRINK_q50_lower)
ests$LOG_N_NOW_q50_upper = as.numeric(ests$LOG_N_NOW_q50_upper)
ests$LOG_N_NOW_q50_lower = as.numeric(ests$LOG_N_NOW_q50_lower)
ests$LOG_N_ANCESTRAL_q50_upper = as.numeric(ests$LOG_N_ANCESTRAL_q50_upper)
ests$LOG_N_ANCESTRAL_q50_lower = as.numeric(ests$LOG_N_ANCESTRAL_q50_lower)

N_range = c(log(80, base=10), log(4000, base=10))

nrow(ests[ests$T_SHRINK > ests$T_SHRINK_q95_lower & ests$T_SHRINK < ests$T_SHRINK_q95_upper,]) / nrow(ests)
nrow(ests[ests$LOG_N_NOW > ests$LOG_N_NOW_q95_lower & ests$LOG_N_NOW < ests$LOG_N_NOW_q95_upper,]) / nrow(ests)
nrow(ests[ests$LOG_N_ANCESTRAL > ests$LOG_N_ANCESTRAL_q95_lower & ests$LOG_N_ANCESTRAL < ests$LOG_N_ANCESTRAL_q95_upper,]) / nrow(ests)

if (grepl("5000", out.prefix)) {
    ests.many_sims = ests[ests$num_sim_points > 1000,]
    nrow(ests.many_sims[ests.many_sims$T_SHRINK > ests.many_sims$T_SHRINK_q95_lower & ests.many_sims$T_SHRINK < ests.many_sims$T_SHRINK_q95_upper,]) / nrow(ests.many_sims)
    nrow(ests.many_sims[ests.many_sims$LOG_N_NOW > ests.many_sims$LOG_N_NOW_q95_lower & ests.many_sims$LOG_N_NOW < ests.many_sims$LOG_N_NOW_q95_upper,]) / nrow(ests.many_sims)
    nrow(ests.many_sims[ests.many_sims$LOG_N_ANCESTRAL > ests.many_sims$LOG_N_ANCESTRAL_q95_lower & ests.many_sims$LOG_N_ANCESTRAL < ests.many_sims$LOG_N_ANCESTRAL_q95_upper,]) / nrow(ests)
} else {
    ests.many_sims = ests
}

p = ggplot(ests.many_sims, aes(T_SHRINK, T_SHRINK_median, col=num_sim_points)) +
    geom_segment(data=ests.many_sims, aes(x=T_SHRINK, y=T_SHRINK_q50_lower,
        xend=T_SHRINK, yend=T_SHRINK_q50_upper), lwd=0.2) +
    geom_point() +
    geom_abline(slope=1, intercept=0, lty=3, col='red') +
    xlim(c(80,400)) + ylim(c(80,400)) +
    coord_fixed() +
    theme_bw() +
    xlab(expression("Pseudo-observed T"[Shrink])) +
    ylab(expression("T"[Shrink]~" Posterior Median")) +
    guides(color=guide_legend(title="Num. Sim. Points"))
ggsave(p, filename=paste0(out.prefix, ".T_SHRINK.pdf"))

p = ggplot(ests.many_sims, aes(LOG_N_NOW, LOG_N_NOW_median, col=num_sim_points)) +
    geom_segment(data=ests.many_sims, aes(x=LOG_N_NOW, y=LOG_N_NOW_q50_lower,
        xend=LOG_N_NOW, yend=LOG_N_NOW_q50_upper), lwd=0.2) +
    geom_point() +
    geom_abline(slope=1, intercept=0, lty=3, col='red') +
    xlim(N_range) + ylim(N_range) +
    coord_fixed() +
    theme_bw() +
    xlab(expression("Pseudo-observed log N"[Now])) +
    ylab(expression("N"[Now]~" Posterior Median")) +
    guides(color=guide_legend(title="Num. Sim. Points"))
ggsave(p, filename=paste0(out.prefix, ".LOG_N_NOW.pdf"))

p = ggplot(ests.many_sims, aes(LOG_N_ANCESTRAL, LOG_N_ANCESTRAL_median, col=num_sim_points)) +
    geom_segment(data=ests.many_sims, aes(x=LOG_N_ANCESTRAL, y=LOG_N_ANCESTRAL_q50_lower,
        xend=LOG_N_ANCESTRAL, yend=LOG_N_ANCESTRAL_q50_upper), lwd=0.2) +
    geom_point() +
    geom_abline(slope=1, intercept=0, lty=3, col='red') +
    xlim(N_range) + ylim(N_range) +
    coord_fixed() +
    theme_bw() +
    xlab(expression("Pseudo-observed log N"[Ancestral])) +
    ylab(expression("N"[Ancestral]~" Posterior Median")) +
    guides(color=guide_legend(title="Num. Sim. Points"))
ggsave(p, filename=paste0(out.prefix, ".LOG_N_ACNESTRAl.pdf"))

# --- Plot size of T CI vs. number of points

ests$T_SHRINK_q95_upper = as.numeric(ests$T_SHRINK_q95_upper)
ests$T_SHRINK_q95_lower = as.numeric(ests$T_SHRINK_q95_lower)

ests$T_SHRINK_q95_range = ests$T_SHRINK_q95_upper - ests$T_SHRINK_q95_lower

ggplot(ests, aes(T_SHRINK_q95_range, num_sim_points)) +
    geom_point()

# --- Figure out which points go where
ests$big.T.range = FALSE
ests$big.T.range[ests$T_SHRINK_q95_range > 200] = TRUE

ests$many.points = FALSE
ests$many.points[ests$num_sim_points > 5000] = TRUE

ests$few.points = FALSE
ests$few.points[ests$num_sim_points < 200] = TRUE

ggplot(ests, aes(T_SHRINK, T_SHRINK_median, col=paste(big.T.range, many.points, few.points)), sep="-") +
    geom_point() #+
    #xlim(c(80,400)) + ylim(80,400) +
    #coord_fixed()

# --- Plot T range by T

ggplot(ests, aes(T_SHRINK_median, T_SHRINK_q95_range, col=paste(big.T.range, many.points, few.points)), sep="-") +
    geom_point()

# --- Plot sumstats by T

# Many with H=1
ggplot(ests, aes(T_SHRINK, H_1, col=paste(big.T.range, many.points, few.points)), sep="-") +
    geom_point()

ggplot(ests, aes(T_SHRINK, S_1, col=paste(big.T.range, many.points, few.points)), sep="-") +
    geom_point()

ggplot(ests, aes(T_SHRINK, D_1, col=paste(big.T.range, many.points, few.points)), sep="-") +
    geom_point()

ggplot(ests, aes(T_SHRINK, FS_1, col=paste(big.T.range, many.points, few.points)), sep="-") +
    geom_point()

ggplot(ests, aes(T_SHRINK, Pi_1, col=paste(big.T.range, many.points, few.points)), sep="-") +
    geom_point()

ggplot(ests, aes(T_SHRINK, GW_1, col=paste(big.T.range, many.points, few.points)), sep="-") +
    geom_point()

ggplot(ests, aes(T_SHRINK, R_1, col=paste(big.T.range, many.points, few.points)), sep="-") +
    geom_point()

ggplot(ests, aes(T_SHRINK, Rsd_1, col=paste(big.T.range, many.points, few.points)), sep="-") +
    geom_point()

# ---

abline(a=0, b=1, col='red', lty=3)
plot(ests$N_ANCESTRAL, ests$N_ANCESTRAL_median,
    xlim=c(0,10000), ylim=c(0,10000), asp=1)
abline(a=0, b=1, col='red', lty=3)
plot(ests$N_NOW,       ests$N_NOW_median,
    xlim=c(0,4000), ylim=c(0,4000), asp=1)
abline(a=0, b=1, col='red', lty=3)


par(mfrow=c(4,2))
    hist(ests$H_1,   breaks=100)
    hist(ests$S_1,   breaks=100)
    hist(ests$D_1,   breaks=100)
    hist(ests$FS_1,  breaks=100)
    hist(ests$Pi_1,  breaks=100)
    hist(ests$Hsd_1, breaks=100)
    hist(ests$GW_1,  breaks=100)
    hist(ests$R_1,   breaks=100)
par(mfrow=c(1,1))

