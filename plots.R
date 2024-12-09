# Set working dir.
setwd("~/OneDrive - University of Iowa/ms_26/ui_24f/ECON_5810/vsp/semicon_analysis")

# Packages
library(ggplot2)
library(tidyverse)
library(haven)
library(gridExtra)
library(grid)
library(ggpubr)
library(cowplot)
library(RColorBrewer)
library(ggsci)

# Importing dataset
df <- read_dta("data/trim/est_res.dta")

# Plotting info.
depvars <- c("lgemp", "lgcapx", "lgxrd", "lgxrdint", "eqr")
names(depvars) <- c("Log of Employment", 
                    "Log of Capital Expenditure", 
                    "Log of R&D Expenditure", 
                    "Log of R&D Intensity", 
                    "Equity Ratio")

estimators <- c("ab3", "bb3", "lsdvcab", "lsdvcbb")
names(estimators) <- c("Diff. GMM w/ 3 Lags", 
                       "Sys. GMM w/ 3 Lags", 
                       "Bias-corrected Least Squares Dummy Variable (AB)",
                       "Bias-corrected Least Squares Dummy Variable (BB)")


#==================================
#         Residual Plots
#==================================

 
# Individual residual plot
residual_plot <- function(df, res, x_var, title) {
  
  # Removing NAs
  plot_data <- df %>%
    filter(!is.na(.data[[x_var]]), !is.na(.data[[res]]))
  
  # Plot w/ industry as shape and color var.
  ggplot(plot_data, aes(x = .data[[x_var]], 
                        y = .data[[res]])) +
    geom_point(alpha = 0.65, size = 2.5, color = "darkblue") +
    geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
    labs(title = title, color = "Industry Groups") +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(hjust = 0, size = 10, face = "bold"),
      axis.title = element_blank(),
      legend.position = "bottom",
      panel.grid.major = element_line(color = "grey80"),
      panel.grid.minor = element_blank(),
      panel.background = element_rect(color = "white")
    )
}

# Function to extract legend for grid plot
extract_legend <- function(plot) {
  g <- ggplotGrob(plot)
  legend <- g$grobs[which(sapply(g$grobs, function(x) x$name) == "guide-box")][[1]]
  legend
}

# Function to enerate grid of residual plots for all estimators
generate_residual_plot_grid <- function(df, depvars, estimators, output_dir = "output/plots/", save = TRUE) {
  
  # Iterating through each estimator
  for (estimator in names(estimators)) {
    
    # Getting individual plots for each model
    plots <- lapply(names(depvars), function(depvar) {
      res <- paste0("ep_", depvars[depvar], "_", estimators[estimator])
      if (estimators[estimator] %in% c("ab3", "bb3")) {
        x_var <- paste0("difffit_", depvars[depvar], "_", estimators[estimator])
      } else {
        x_var <- paste0("fit_", depvars[depvar], "_", estimators[estimator])
      }
      residual_plot(df, res = res, x_var = x_var, title = depvar)
    })
    
    # Making grid of plots w/ respect to given estimator
    plot_grid <- arrangeGrob(
      grobs = plots,
      ncol = 2,
      bottom = textGrob("Fitted Values", gp = gpar(fontface = "bold", fontsize = 12)),
      left = textGrob("Residuals", gp = gpar(fontface = "bold", fontsize = 12), rot = 90),
      top = textGrob(paste("Residual Plots for ", estimator), gp = gpar(fontface = "bold", fontsize = 14))
    )
    
    # Applying final grid w/ legend
    final_plot <- arrangeGrob(
      plot_grid,
      ncol = 1,
      heights = c(10, 1)
    )
    
    if (save) {
      output_file <- file.path(output_dir, paste0("residual_plots_", estimators[estimator], ".png"))
      ggsave(output_file, plot = final_plot, width = 12, height = 8, dpi = 1000)
    } else {
      grid.newpage()
      grid.draw(final_plot)
    }
  }
}



# Plotting command
generate_residual_plot_grid(df, depvars, estimators, save = T)


#==================================
#.          Q-Q Plots
#==================================


# Individual Q-Q plot
qq_plot <- function(df, res, title) {
  
  # Removing NAs
  plot_data <- df %>%
    filter(!is.na(.data[[res]]))
  
  # Plot w/ industry as shape and color var.
  ggplot(plot_data, aes(sample = .data[[res]])) +
    stat_qq(alpha = 0.65, size = 2.5, color = "skyblue") + 
    stat_qq_line() +
    labs(title = title) +
    theme(
      plot.title = element_text(hjust = 0, size = 10, face = "bold"),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      legend.position = "bottom",
      panel.grid.major = element_line(color = "grey80"),
      panel.grid.minor = element_blank(),
      panel.background = element_rect(fill = "white", color = "white")
    )
}

# Function to generate grid of Q-Q plots for all estimators
generate_qq_plot_grid <- function(df, depvars, estimators, output_dir = "output/plots/", save = TRUE) {
  
  # Iterating through each estimator
  for (estimator in names(estimators)) {
    
    # Getting individual plots for each model
    plots <- lapply(names(depvars), function(depvar) {
      res <- paste0("ep_", depvars[depvar], "_", estimators[estimator])
      qq_plot(df, res = res, title = depvar)
    })
    
    # Making grid of plots w/ respect to given estimator
    plot_grid <- arrangeGrob(
      grobs = plots,
      ncol = 2,
      bottom = textGrob("Theoretical Quantiles", gp = gpar(fontface = "bold", fontsize = 12)),
      left = textGrob("Sample Quantiles", gp = gpar(fontface = "bold", fontsize = 12), rot = 90),
      top = textGrob(paste("Q-Q Plots for ", estimator), gp = gpar(fontface = "bold", fontsize = 14))
    )
    
    # Applying final grid w/ legend
    final_plot <- arrangeGrob(
      plot_grid,
      ncol = 1,
      heights = c(10, 1)
    )
    
    if (save) {
      output_file <- file.path(output_dir, paste0("qq_plots_", estimators[estimator], ".png"))
      ggsave(output_file, plot = final_plot, width = 12, height = 8, dpi = 1000)
    } else {
      grid.newpage()
      grid.draw(final_plot)
    }
  }
}



# Plotting command
generate_qq_plot_grid(df, depvars, estimators, save = T)


#==================================
#         Fitted Plots
#==================================


# Individual plot
fitted_plot <- function(df, fitted_vals, actual_vals, title, grouping) {
  
  # Removing NAs and calculating mean and CI bounds for each group
  plot_data <- df %>%
    filter(!is.na(.data[["year"]]), 
           !is.na(.data[[fitted_vals]]),
           !is.na(.data[[actual_vals]]),
           !is.na(.data[[grouping]])) %>%
    group_by(.data[[grouping]], .data[["year"]]) %>%
    summarize(
      mean_fitted = mean(.data[[fitted_vals]], na.rm = TRUE),
      mean_actual = mean(.data[[actual_vals]], na.rm = TRUE),
      .groups = 'drop'
    )
  
  # Plot with grouping as color variable
  ggplot(plot_data, aes(x = .data[["year"]], color = as.factor(.data[[grouping]]))) +
    geom_line(
      data = plot_data,
      aes(y = mean_actual), 
      alpha = 0.8, 
      size = 1,
      linetype = "dashed"
    ) +
    geom_line(
      data = plot_data,
      aes(y = mean_fitted), 
      alpha = 0.8, 
      size = 1
    ) +
    geom_vline(xintercept = 2018, linetype = "solid", color = "red") +
    labs(title = title, 
         color = "Groups", 
         fill = "Groups",
         x = "Year",
         y = "Fitted Values") +
    scale_color_d3() +
    scale_fill_d3() +
    scale_x_continuous(breaks = seq(2006, 2023, by=2)) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(hjust = 0, size = 10, face = "bold"),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      legend.position = "bottom",
      panel.grid.major = element_line(color = "grey80"),
      panel.grid.minor = element_blank(),
      panel.background = element_rect(fill = "white", color = "white")
    )
}

generate_fitted_grid <- function(df, depvars, estimators, grouping, output_dir = "output/plots/", save = TRUE) {
  
  # Iterating through each estimator
  for (estimator in names(estimators)) {
    
    # Getting individual plots for each model
    plots <- lapply(names(depvars), function(depvar) {
      fitted_vals <- paste0("fit_", depvars[depvar], "_", estimators[estimator])
      fitted_plot(df, fitted_vals = fitted_vals, actual_vals = depvars[depvar],  title = depvar, grouping = grouping)
    })
    
    # Getting a single shared legend; Removing others
    legend <- extract_legend(plots[[1]])
    plots <- lapply(plots, function(plot) plot + theme(legend.position = "none"))
    
    # Making grid of plots w/ respect to given estimator
    plot_grid <- arrangeGrob(
      grobs = plots,
      ncol = 2,
      bottom = textGrob("Fitted Values", gp = gpar(fontface = "bold", fontsize = 12)),
      left = textGrob("Year", gp = gpar(fontface = "bold", fontsize = 12), rot = 90),
      top = textGrob(paste("Fitted Plots for ", estimator), gp = gpar(fontface = "bold", fontsize = 14))
    )
    
    # Applying final grid w/ legend
    final_plot <- arrangeGrob(
      plot_grid,
      legend,
      ncol = 1,
      heights = c(10, 1)
    )
    
    if (save) {
      output_file <- file.path(output_dir, paste0("fitted_plots_", estimators[estimator], ".png"))
      ggsave(output_file, plot = final_plot, width = 12, height = 8, dpi = 1000)
    } else {
      grid.newpage()
      grid.draw(final_plot)
    }
  }
}

# Plotting info.
depvars <- c("lgemp", "lgcapx", "lgxrd", "lgxrdint", "eqr")
names(depvars) <- c("Log of Employment", "Log of Capital Expenditure", "Log of R&D Expenditure", "Log of R&D Intensity", "Equity Ratio")
estimators <- c("ab3", "bb3", "lsdvcab", "lsdvcbb")
names(estimators) <- c("Diff. GMM w/ 3 Lags", 
                       "Sys. GMM w/ 3 Lags", 
                       "Bias-corrected Least Squares Dummy Variable (AB)",
                       "Bias-corrected Least Squares Dummy Variable (BB)")

generate_fitted_grid(df, depvars, estimators, "ggroup", save = T)


#==================================
#         Depvar. Plots
#==================================

# Individual plot
depvar_plot <- function(df, depvar, title, grouping) {
  
  # Removing NAs and calculating mean and CI bounds for each group
  plot_data <- df %>%
    filter(!is.na(.data[["year"]]), 
           !is.na(.data[[depvar]]), 
           !is.na(.data[[grouping]])) %>%
    group_by(.data[[grouping]], .data[["year"]]) %>%
    summarize(
      mean_fitted = mean(.data[[depvar]], na.rm = TRUE),
      .groups = 'drop'
    )
  
  # Plot with grouping as color variable
  ggplot(plot_data, aes(x = .data[["year"]], color = as.factor(.data[[grouping]]))) +
    geom_line(
      data = plot_data %>% filter(.data[["year"]] <= 2018),
      aes(y = mean_fitted), 
      alpha = 0.8, 
      linewidth = 1,
      linetype = "dashed"
    ) +
    geom_line(
      data = plot_data %>% filter(.data[["year"]] >= 2018),
      aes(y = mean_fitted), 
      alpha = 0.8, 
      linewidth = 1
    ) +
    geom_vline(xintercept = 2018, linetype = "solid", color = "red") +
    labs(title = title, 
         color = "GICS Industry", 
         fill = "GICS Industry") +
    guides(color = guide_legend(nrow = 1)) +
    scale_color_d3() +
    scale_fill_d3() +
    scale_x_continuous(breaks = seq(2006, 2023, by=2)) +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(hjust = 0, size = 12, face = "bold"),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      legend.position = "bottom",
      legend.box = "horizontal",
      panel.grid.major = element_line(color = "grey80"),
      panel.grid.minor = element_blank(),
      panel.background = element_rect(fill = "white", color = "white")
    )
}

generate_depvar_grid <- function(df, depvars, grouping, output_dir = "output/plots/", save = TRUE) {
  # Getting individual plots for each depvar
  plots <- lapply(names(depvars), function(depvar) {
    depvar_plot(df, depvar = depvars[depvar], title = depvar, grouping = grouping)
  })
  
  # Getting a single shared legend; Removing others
  legend <- extract_legend(plots[[1]])
  plots <- lapply(plots, function(plot) plot + theme(legend.position = "none"))
  
  # Making grid of plots w/ respect to given estimator
  plot_grid <- arrangeGrob(
    grobs = plots,
    ncol = 2,
    bottom = textGrob("Year", gp = gpar(fontface = "italic", fontsize = 12)),
  )
  
  # Applying final grid w/ legend
  final_plot <- arrangeGrob(
    plot_grid,
    legend,
    ncol = 1,
    heights = c(10, 1)
  )
  
  if (save) {
    output_file <- file.path(output_dir, paste0("model_plots_", grouping, ".png"))
    ggsave(output_file, plot = final_plot, width = 15, height = 8, dpi = 1000)
  } else {
    grid.newpage()
    grid.draw(final_plot)
  }
}

# Plotting commands
paper_out <- "~/OneDrive - University of Iowa/ms_26/ui_24f/ECON_5810/vsp/paper/figs_n_tables/"
generate_depvar_grid(df, depvars, "gsector", save = T)
generate_depvar_grid(df, depvars, "ggroup", save = T)
generate_depvar_grid(df, depvars, "gind", save = T)
generate_depvar_grid(df, depvars, "gsubind", save = T)


#==================================
#         Error Bar
#==================================


# Individual plot
error_bar <- function(estimates, errors, title) {
  labels <- c("1", "2", "3", "4")
  plot_data <- data.frame(
    Estimate = estimates,
    SE = errors,
    Label = factor(labels, levels = labels)
  )
  
  ggplot(plot_data, aes(x = Label, y = Estimate, color = Label)) +
    geom_point(size = 3, data = plot_data) +
    geom_errorbar(aes(ymin = Estimate - SE * 1.96, ymax = Estimate + SE * 1.96), 
                  width = 0.2) +
    geom_text(data = plot_data, aes(x = Label, y = Estimate, label = Estimate), inherit.aes = FALSE, size = 3, fontface = "bold", nudge_x = 0.35) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "red") +
    labs(title = title, y = "Estimate", color = "Lags") +
    guides(color = guide_legend(nrow = 1)) +
    scale_color_d3() +
    scale_fill_d3() +
    theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(hjust = 0, size = 12, face = "bold"),
      axis.title.x = element_blank(),
      axis.text.x = element_blank(),
      axis.title.y = element_blank(),
      legend.position = "bottom",
      legend.box = "horizontal",
      legend.text = element_text(size = 12, face = "bold"),
      panel.grid.major.y = element_line(color = "grey80"),
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank(),
      panel.background = element_rect(fill = "white", color = "white")
    )
}

# Grid
generate_error_grid <- function(df, depvars, output_dir = "output/plots/", save = TRUE) {
  # Getting individual plots for each depvar
  plots <- lapply(names(depvars), function(depvar) {
    error_bar(estimates = df[, paste0(depvars[depvar], "_est")], errors = df[, paste0(depvars[depvar], "_se")], title = depvar)
  })
  
  # Getting a single shared legend; Removing others
  legend <- extract_legend(plots[[1]])
  plots <- lapply(plots, function(plot) plot + theme(legend.position = "none"))
  
  # Making grid of plots w/ respect to given estimator
  plot_grid <- arrangeGrob(
    grobs = plots,
    ncol = 2,
  )
  
  # Applying final grid w/ legend
  final_plot <- arrangeGrob(
    plot_grid,
    legend,
    ncol = 1,
    heights = c(10, 1)
  )
  
  if (save) {
    output_file <- file.path(output_dir, "model_lag_error_bar.png")
    ggsave(output_file, plot = final_plot, width = 15, height = 8, dpi = 1000)
  } else {
    grid.newpage()
    grid.draw(final_plot)
  }
}

# Plotting commands
paper_out <- "~/OneDrive - University of Iowa/ms_26/ui_24f/ECON_5810/vsp/paper/figs_n_tables/"
depvars <- c("lgemp", "lgcapx", "lgxrd", "lgxrdint", "eqr")
names(depvars) <- c("Log of Employment", "Log of Capital Expenditure", "Log of R&D Expenditure", "Log of R&D Intensity", "Equity Ratio")
df_errors <- data.frame(
  "lgemp_est" = c(-0.00101, -0.0510, -0.0499, -0.0387),
  "lgemp_se" = c(0.0482, 0.0164, 0.0158, 0.0160),
  "lgcapx_est" = c(-0.0967, -0.255, -0.214, -0.185),
  "lgcapx_se" = c(0.138, 0.0885, 0.0792, 0.0785),
  "lgxrd_est" = c(-0.0362, -0.0710, -0.0641, -0.0619),
  "lgxrd_se" = c(0.0233, 0.0222, 0.0242, 0.0249),
  "lgxrdint_est" = c(-0.147, -0.0790, -0.0874, -0.0395),
  "lgxrdint_se" = c(0.213, 0.171, 0.179, 0.143),
  "eqr_est" = c(-0.0203, -0.0482, -0.0416, -0.0413),
  "eqr_se" = c(0.0597, 0.0288, 0.0293, 0.0279)
)
generate_error_grid(df_errors, depvars, output_dir = paper_out)



