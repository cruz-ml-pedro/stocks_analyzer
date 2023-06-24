pacman::p_load(zoo, biwavelet, WaveletComp, plotly,gridExtra,tidyverse, here)#highcharter
source(here::here("functions/func_scale.R"))
source(here::here("functions/func_acf_plot.R"))
source(here::here("functions/func_ccf_plot.R"))
# UI do Módulo Três
moduloTresUI <- function(id,tickers,benchmarks) {
  ns <- NS(id)
     tagList(
    h2("Análises avançadas"),
    # Sidebar 
    sidebarLayout(
    sidebarPanel(width = 3,
   # Let user pick stocks
     shinyWidgets::pickerInput(
           inputId =ns("stocks"),
           label = h4("Stocks"),
            choices = c(
            "Bitcoin"       = tickers[1], 
            "Ethereum"   = tickers[2],
            "Litecoin"      = tickers[3],
            "Cardano"         = tickers[4],
            "Polkadot"    = tickers[5],
            "Bitcoin Cash"     = tickers[6],
            "Stellar"       = tickers[7],
            "Dogecoin" = tickers[8],
            "Binance Coin" = tickers[9]),
             selected = tickers[1],   
             options = list(`actions-box` = TRUE), 
             multiple = F
           ),
                             
             # Pick time period
   radioButtons(ns("period"), label = h4("Period"),
      choices = list("1 month" = 1, "3 months" = 2, "6 months" = 3, "12 months" = 4, "YTD" = 5), 
      selected = 4
           ),
                             
             # Pick benchmark
   radioButtons(ns("benchmark"), label = h4("Benchmark"),
       choices = list("SP500" = 1, "Nasdaq100" = 2,"CMC_Crypto_200" = 3),
       selected = 3)
          ),
              
          # Plot results
   mainPanel(
   #    h3("Stock vs Benchmark"),
     #highcharter::highchartOutput(ns("plot"),width = "100%", height=400),
     plotly::plotlyOutput(ns("plot"),width = "100%", height=400),
     #
     tabsetPanel(
       tabPanel("Correlação",
                plotOutput(ns("corr_plot"))
                ),
       tabPanel("Análises espectrais",
                tabsetPanel(
                  tabPanel("Espectro de potência",
                    h6("Espectro de potência Stock"),
                           plotOutput(ns("spec_plot1")),
                           h6("Espectro de potência Benchmark"),
                           plotOutput(ns("spec_plot2"))),
                  tabPanel("Espectrograma de wavelets",
                    h6("Espectrograma Stock"),
                           plotOutput(ns("wave_plot1")),
                           h6("Espectrograma Benchmark"),
                           plotOutput(ns("wave_plot2"))),
                  tabPanel("Espectrograma de Coerência espectral",
                           h6("Coerência espectral via wavelets"),
                           plotOutput(ns("coerencia_plot"))
                  )
                  
                )
             )
           )
        )
      )
    )
}

# Server do Módulo Três
moduloTresServer <- function(id,bench,prices) {
  moduleServer(id, function(input, output, session) {
    
    observeEvent(c(input$period,input$stocks,input$benchmark), {
      #filtrando apenas a ação escolhida
      prices <- prices %>%
      dplyr::filter(symbol %in%  input$stocks) %>%
      dplyr::select(symbol,date,close)
      
      #lógica da escolha do período selecionado
      if (input$period == 1) {
        prices <- prices %>%
          dplyr::filter(date >= today()-months(1)) 
      }
      
      if (input$period == 2) {
        prices <- prices %>%
          dplyr::filter(date >= today()-months(3))
      }
      
      if (input$period == 3) {
        prices <- prices %>%
          dplyr::filter(date >= today()-months(6))
      }
      
      if (input$period == 4) {
        prices <- prices %>%
          dplyr::filter(date >= today()-months(12))
      }
      
      if (input$period == 5) {
        prices <- prices %>%
          dplyr::filter(year(date) == year(today()))
      }
      #filtrando o benchmark a partir da escolha do usuário e da "data/rices$date"      
      if (input$benchmark == 1) {
        bench <- bench %>%
          dplyr::filter(symbol=="^GSPC",date >= min(prices$date))
       # prices <- rbind(prices,bench)
      }
      
      if (input$benchmark == 2) {
        bench <- bench %>%
          dplyr::filter(symbol=="^NDX",date >= min(prices$date))
       # prices <- rbind(prices,bench)
      }
      
      if (input$benchmark == 3) {
        bench <- bench %>%
          dplyr::filter(symbol=="^CMC200", date >= min(prices$date))
       # prices <- rbind(prices,bench) 
      }
      
        #colocando os dados no formato final para o gráfico que usa highcharter 
      stock_bench <- 
     dplyr::left_join(prices,bench, by = "date") %>% 
      tidyr::drop_na()
      
      # usando a função que vem do source(here::here("func_scale.R"))
      #/coloca os dados na mesma escala
        dataframe_padronizado <- data_scale(stock_bench)
      #
      # Os dados usados estão todos dentro da lista lista_dataframes_padronizados
      # nas próximas linhas vamos saparar esses dados em diferentes objetos que serão usados em
      # funções externas que fazem as análises e gráficos de interesse. 
      
        high_plot <- dataframe_padronizado# objeto para o plot de ST highcharter
        valor_stock <- dataframe_padronizado[,3] %>% as_vector()#para análise de correlação
        valor_benchmark <- dataframe_padronizado[,5] %>% as_vector()#para análise de correlação
        data <- dataframe_padronizado[,2] %>% as_vector()#para análise de correlação
        my.data <- dataframe_padronizado%>% 
       dplyr::select(close.x,close.y)# para análise de potência espectral (Fourier e wavelet/Fourier)
        
        #Gráficos
      # output$plot <- renderHighchart({
      #    
      #    highcharter::highchart(type = "stock") %>%
      #     hc_chart(
      #       backgroundColor = "#FFFFFF" # Definindo a cor de fundo como branco (código hexadecimal)
      #     ) %>% 
      #      hc_add_series(high_plot$close.x, type = "line") %>% 
      #       hc_add_series(high_plot$close.y, type = "line")
      #  })# fim Highchart
        
        output$plot <- plotly::renderPlotly({
          print(
            plotly::ggplotly(high_plot %>% 
                               ggplot(aes(x=date))+
                               geom_line(aes(y=close.x), color="steelblue")+
                               geom_line(aes(y=close.y), color="darkorange")
             
            )
          )
        })
      
     #plots de correlação
     output$corr_plot <- renderPlot({
       #
       #Função que converte os dados em ts, realiza a análise de correlação e gera um plot em ggplot2
       p1 <- acf_plot(valor_stock, data)
       p2 <- acf_plot(valor_benchmark,data)  
       p3 <- ccf_plot(valor_stock,valor_benchmark,data)# função para correlação cruzada
       # Definindo os títulos das imagens
       titulo1 <- "Autocorrelação Stock"
       titulo2 <- "Autocorrelação Benchmark"
       titulo3 <- "Correlação cruzada Stock vs Benchmark"
        #criando um grid para plotar as duas imagens
       grid <-gridExtra::grid.arrange(
         arrangeGrob(p1 + ggtitle(titulo1), p2 + ggtitle(titulo2), ncol = 2),
         p3 + ggtitle(titulo3),
         ncol=1,
         heights = c(1, 1)
       )
       grid
     })
     
     #plot de potência espectral
      my.wx <- analyze.wavelet(my.data, "close.x")#análise wavelet stock
      my.wy <- analyze.wavelet(my.data, "close.y")#análise wavelet benchmark
      maximum.level = 1.001*max(my.wx$Power.avg, my.wy$Power.avg)#usado para limite do espectrod e potência
      #
      output$spec_plot1 <- renderPlot({
        wt.avg(my.wx, maximum.level = maximum.level)
      })
     # 
      output$spec_plot2 <- renderPlot({
        wt.avg(my.wy, maximum.level = maximum.level)
      })
     # plot espectrograma stock
      output$wave_plot1 <- renderPlot({
        wt.image(my.wx, color.key = "interval", n.levels = 250,
                 legend.params = list(lab = "wavelet power levels"))
      })
      # plot espectrograma benchmark
      output$wave_plot2 <- renderPlot({
        wt.image(my.wy, color.key = "interval", n.levels = 250,
                 legend.params = list(lab = "wavelet power levels"))
      })
      # calculando a análise de coerência
      my.wc <- analyze.coherency(my.data, my.pair = c("close.x","close.y"),
                                 loess.span = 0,
                                 dt = 1, dj = 1/100,
                                 lowerPeriod = 1,
                                 make.pval = TRUE, n.sim = 10)
      #plot de coerência
      output$coerencia_plot <- renderPlot({
        wc.image(my.wc, legend.params = list(lab = "cross-wavelet power levels"),
                 timelab = "", periodlab = "period (days)")
      })
    })
  })
}
