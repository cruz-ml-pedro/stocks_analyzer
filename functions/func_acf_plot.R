acf_plot <- function(valor,data){
  
  #
  acf_to_df <- function(acf_result) {
    df <- data.frame(lag = acf_result$lag, acf = acf_result$acf)
    return(df)
  }  
  
  
  x <- zoo::zoo(valor, order.by= data) #criando objeto aceito nas funções
  
  acf_result <- acf(coredata(x), plot = FALSE) 
  acf_df <- acf_to_df(acf_result)
  
  # Cálculo dos limites de confiança
  conf_level <- 0.95
  n <- length(valor)
  acf_df$lower_conf <- -1.96 / sqrt(n)
  acf_df$upper_conf <- 1.96 / sqrt(n)
  
  # Plotar o gráfico usando ggplot2
  acf_plot <- ggplot(acf_df, aes(x = lag, y = acf)) +
    geom_bar(stat = "identity", fill = "black", width = 0.1) +
    geom_hline(yintercept = 0, linetype = "dashed", color = "red", linewidth = 1.2) +
    geom_hline(yintercept = acf_df$lower_conf, linetype = "dashed", color = "steelblue",linewidth = 1.2) +
    geom_hline(yintercept = acf_df$upper_conf, linetype = "dashed", color = "steelblue",linewidth = 1.2) +
    labs(title = "", x = "Lag", y = "ACF")
  
  return(acf_plot)
  
}