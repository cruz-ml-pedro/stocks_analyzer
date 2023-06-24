# Função usada no terceiro módulo do app
# Essa função coloca os dados em escala para plotagem e 
# realização de nálises de correlação e espectrais
data_scale <- function(df){
 
  # Colunas a serem transformadas
  colunas_para_escala <- c("close.x", "close.y")
  
  # Aplicando a função scale nas colunas selecionadas usando sapply
  df[colunas_para_escala] <- sapply(df[colunas_para_escala], scale)
 
  return(df)
  
}




