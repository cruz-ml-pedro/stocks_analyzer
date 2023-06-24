pacman::p_load(shiny, shinythemes, shinyWidgets, here)
source(here::here("modules/mod_aba_um.R"))
source(here::here("modules/mod_aba_dois.R"))
source(here::here("modules/mod_aba_tres.R"))

# Script externo que retorna os dados
source(here::here("functions/data_loader.R"))
# UI da aplicação principal
ui <- fluidPage(theme = shinytheme("cyborg"),
    tabsetPanel(
        id = "tabs",
        tabPanel("Stock vs Benchmark", moduloUmUI("moduloUm",tickers,benchmarks)),
        tabPanel("Análise Técnica", moduloDoisUI("moduloDois",tickers)),
        tabPanel("Análises avançadas", moduloTresUI("moduloTres",tickers,benchmarks))
    )
)

# Server da aplicação principal
server <- function(input, output, session) {
    
    # Chamar os módulos
    moduloUmServer("moduloUm",bench,prices)
    moduloDoisServer("moduloDois",prices)
    moduloTresServer("moduloTres",bench,prices)
}

# Executar a aplicação Shiny
shinyApp(ui, server)