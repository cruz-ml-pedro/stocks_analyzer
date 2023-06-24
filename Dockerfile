# Use a imagem rocker/shiny baseada no Windows
FROM rocker/shiny:latest

# Defina o diretório de trabalho
WORKDIR /app

# Instale os pacotes necessários
RUN R -e "install.packages(c('shiny', 'shinythemes', 'shinyWidgets', 'plotly', 'TTR', 'zoo', 'biwavelet', 'WaveletComp', 'gridExtra', 'tidyquant', 'pacman', 'here', 'xts', 'tidyverse', 'quantmod'))"

# Copie os arquivos do aplicativo
COPY aplicativo /app
COPY modules /app/modules
COPY functions /app/functions

# Exponha a porta necessária pelo Shiny Server
EXPOSE 3838

# Defina o comando de inicialização do Shiny Server no Windows
CMD ["R", "-e", "shiny::runApp('/app', host = '0.0.0.0', port = 3838)"]
