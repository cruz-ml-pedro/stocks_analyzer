pacman::p_load(tidyverse,TTR,plotly,xts, quantmod)

# UI do Módulo Dois
moduloDoisUI <- function(id, tickers,benchmarks) {
    ns <- NS(id)
      tagList(
        h2("Análise técnica"),
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
      ),
       # Plot results
          mainPanel(
            tabsetPanel(
              tabPanel("Exemplo reativo",
           # h3("Análise Técnica"),
            plotly::plotlyOutput(ns("plot1"),width = "100%", 300),
           # h3("Volume"),
            plotly::plotlyOutput(ns("plot2"),width = "100%", 200),
            #h3("Commodity Channel Index (CCI)"),
            plotly::plotlyOutput(ns("plot3"),width = "100%", 200)
           ),
           tabPanel("Exemplo estático",
            #h3("Análise Técnica"),
            plotOutput(ns("plot4"),width = "100%")
           )
          )
        )
      )
    )
}

# Server do Módulo Dois
moduloDoisServer <- function(id, prices) {
  moduleServer(id, function(input, output, session) {
    observeEvent(c(input$period,input$stocks), {
      
  prices_2 <- prices %>%
    dplyr::filter(symbol %in% input$stocks) %>% 
    tidyr::drop_na()
      
   #realizando o cálculo das Médias Móveis e Bollinger Bands
  # transformando os dados em objetos xts
  ohlc_data <- xts::xts(prices_2[, c("open", "high", "low", "close","volume")], order.by = prices_2$date)
  sma5 <- TTR::SMA(Cl(ohlc_data), n = 5)#Médias Móvel =5
  sma20 <- TTR::SMA(Cl(ohlc_data), n = 20)#Médias Móvel =2
  sma50 <- TTR::SMA(Cl(ohlc_data), n = 50)#Médias Móvel =50
  cci <- TTR::CCI(HLC(ohlc_data), n=20)#Calcular o Commodity Channel Index (CCI)
  bb <- TTR::BBands(Cl(ohlc_data),n=20,sd=2)# Calcular as Bandas de Bollinger
  linha_sup <- 100# p/ o gráfico de CCI
  linha_inf <- -100#p/ o gráfico de CCI
  
  
  
  curvas_list <- list(sma5,sma20,sma50,cci,bb)# criando lista para usar com o lapply
  #transformando os objetos xts em tibbles
  curva_tibble <- lapply(curvas_list,
                         function(x) tibble::as_data_frame(x))
 # Adicionando os valores calculados em um único df
  prices_3 <- prices_2 %>% 
    dplyr::mutate(
      SMA05 =  curva_tibble[[1]] %>% as_vector(),
      SMA20 = curva_tibble[[2]] %>% as_vector(),
      SMA50 = curva_tibble[[3]] %>% as_vector(),
      BBUpper = curva_tibble[[5]][,3] %>% as_vector(),
      BBLower = curva_tibble[[5]][,1] %>% as_vector(),
      cci = curva_tibble[[4]] %>% as_vector(),
      movimento = c(NA,ifelse(diff(close) >= 0, "up", "down"))
    )    
      
   # condicionais para filtrar o período desejado
      if (input$period == 1) {
        prices_3 <- prices_3 %>%
          dplyr::filter(date >= today()-months(1)) 
      }
      
      if (input$period == 2) {
        prices_3 <- prices_3 %>%
          dplyr::filter(date >= today()-months(3))
      }
      
      if (input$period == 3) {
        prices_3 <- prices_3 %>%
          dplyr::filter(date >= today()-months(6))
      }
      
      if (input$period == 4) {
        prices_3 <- prices_3 %>%
          dplyr::filter(date >= today()-months(12))
      }
      
      if (input$period == 5) {
        prices_3 <- prices_3 %>%
          dplyr::filter(year(date) == year(today()))
      }
 
   #gráficos   
  output$plot1 <- plotly::renderPlotly({
      print(
        plotly::ggplotly(prices_3 %>% 
            ggplot(aes(x = date, close)) +
            geom_segment(aes(xend = dplyr::lag(date), yend =dplyr::lag(close), color = movimento), linewidth = 2)+
            scale_color_manual(values = c(up = "green", down = "orange"))+
            scale_y_continuous(position = "right")+
            geom_line(aes(y = SMA05),color="darkred",linewidth = .7, alpha = .9) +
            geom_line(aes(y = SMA20), color = "blue",linewidth = .7, alpha = .9) +
            geom_line(aes(y = SMA50), color = "darkgreen",linewidth = .7, alpha = .9) +
            geom_line(aes(y = BBUpper), color = "darkred",linetype = 2,linewidth = .7, alpha = .9) +
            geom_line(aes(y = BBLower), color = "darkred", linetype = 2,linewidth = .7, alpha = .9) +
            theme_minimal(base_size=16)+
            theme(axis.title=element_blank(),
            plot.background = element_rect(fill = "white"),
            panel.background = element_rect(fill="white"),
            panel.grid = element_blank(),
            legend.text = element_text(colour="black"),
            legend.position = "none")+
            ylab("Preço")
          
        )
      )
    })
    
    output$plot2 <- plotly::renderPlotly({
      print(
        plotly::ggplotly(
          prices_3 %>% 
            ggplot(aes(x=date, y=volume))+
            geom_bar(stat = "identity", fill = "darkblue", width = 0.5)+
            theme_minimal(base_size=16)+
            theme(axis.title=element_blank(),
                  plot.background = element_rect(fill = "white"),
                  panel.background = element_rect(fill="white"),
                  panel.grid = element_blank(),
                  legend.text = element_text(colour="black"))
          
        )
      )
    })
    
    output$plot3 <- plotly::renderPlotly({
      print(
        plotly::ggplotly(prices_3 %>% 
            ggplot(aes(x=date, y=cci))+
            geom_line(color="red", linewidth=1)+
            geom_hline(
             yintercept = c(linha_sup, linha_inf), color = "black", linetype = "dashed", linewidth = 1.2
              )+
             geom_segment(aes(x = date, xend = date, y = linha_sup, yend = cci),
                          data = subset(prices_3, cci > linha_sup), color = "red", linewidth = 1) +
             geom_segment(aes(x = date, xend = date, y = linha_inf, yend = cci),
                          data = subset(prices_3, cci < linha_inf), color = "red", linewidth = 1)+
             labs(x = "Data", y = "CCI", title = "") +
             theme_minimal(base_size=16)+
             theme(axis.title=element_blank(),
             plot.background = element_rect(fill = "white"),
             panel.background = element_rect(fill="white"),
             panel.grid = element_blank(),
             legend.text = element_text(colour="black"))
                         
          
        )
      )
    })
    
  output$plot4 <- renderPlot(
    quantmod::chartSeries(ohlc_data, name = "stock",theme = "white",
                       TA = "addVo(); addBBands(); addCCI();
                             addEMA(50,col='black');
                             addEMA(20,col='blue');addEMA(5,col='red')")
  )
    
    
  })#fim do observeEvent
})
}