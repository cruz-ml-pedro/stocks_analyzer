
ccf_plot <- function(valor1,valor2,data){
  
# Função para converter os resultados de ccf em um data frame
ccf_to_df <- function(ccf_result) {
  df <- data.frame(lag = ccf_result$lag, ccf = ccf_result$acf)
  return(df)
}


x<- zoo::zoo(valor1,order.by= data)
y<- zoo::zoo(valor2,order.by= data)

# Exemplo de ccf
ccf_result <- ccf(coredata(x),coredata(y), plot = FALSE)
ccf_df <- ccf_to_df(ccf_result)

# Cálculo dos limites de confiança
conf_level <- 0.95
n <- length(valor1)
ccf_df$lower_conf <- -1.96 / sqrt(n)
ccf_df$upper_conf <- 1.96 / sqrt(n)

# Plotar o gráfico usando ggplot2
ccf_plot <- ggplot(ccf_df, aes(x = lag, y = ccf)) +
  geom_bar(stat = "identity", fill = "black", width = 0.1) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "red", linewidth = 1.2) +
  geom_hline(yintercept = ccf_df$lower_conf, linetype = "dashed", color = "steelblue",linewidth = 1.2) +
  geom_hline(yintercept = ccf_df$upper_conf, linetype = "dashed", color = "steelblue", linewidth = 1.2) +
  labs(title = "", x = "Lag", y = "CCF")

# Exibir o gráfico
return(ccf_plot)
}
