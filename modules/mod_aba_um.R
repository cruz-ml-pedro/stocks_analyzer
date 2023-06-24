pacman::p_load(shiny, shinythemes, shinyWidgets, tidyverse, plotly)
# UI do Módulo Um
moduloUmUI <- function(id,tickers, benchmarks) {
  ns <- NS(id)
  tagList(
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
                     selected = tickers,   
                     options = list(`actions-box` = TRUE), 
                     multiple = T
                   ),
                   
                   # Pick time period
              radioButtons(ns("period"), label = h4("Period"),
                                choices = list("1 mês" = 1, "3 meses" = 2,
                                               "6 meses" = 3, "12 meses" = 4, "YTD" = 5), 
                                selected = 4
                   ),
                   
                   # Pick benchmark
              radioButtons(ns("benchmark"), label = h4("Benchmark"),
                                choices = list("SP500" = 1, "Nasdaq100" = 2,"CMC_Crypto_200" = 3, "None" = 4),
                                selected = 3)
      ),
      
      # Plot results
      mainPanel(
        h3("Stock vs Benchmark"),
     plotly::plotlyOutput(ns("plot"),width = "100%", height=400)
      )
    )
  )
}

# Server do Módulo Um
moduloUmServer <- function(id, bench, prices) {
  moduleServer(id,function(input, output, session) {
    
    prices <- prices %>%
   dplyr::select(symbol,date,adjusted)
    #
    bench <- bench %>%
    dplyr::select(symbol,date,adjusted)
    
      observeEvent(c(input$period,input$stocks,input$benchmark), {
        
        prices <- prices %>%
        dplyr::filter(symbol %in% input$stocks)
        
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
      ######
        if (input$benchmark == 1) {
          bench <- bench %>%
            dplyr::filter(symbol=="^GSPC",date >= min(prices$date))
          prices <- rbind(prices,bench)
          }
        
        if (input$benchmark == 2) {
          bench <- bench %>%
            dplyr::filter(symbol=="^NDX",date >= min(prices$date))
          prices <- rbind(prices,bench)
          }
        
        if (input$benchmark == 3) {
          bench <- bench %>%
            dplyr::filter(symbol=="^CMC200", date >= min(prices$date))
          prices <- rbind(prices,bench) 
          }
        
        # Create plot
        output$plot <- plotly::renderPlotly({
          print(
         plotly::ggplotly(prices %>%
                       group_by(symbol) %>%
                       mutate(init_close = if_else(date == min(date),adjusted,NA_real_)) %>%
                       mutate(value = round(100 * adjusted / sum(init_close,na.rm=T),1)) %>%
                       ungroup() %>%
                       ggplot(aes(date, value,colour = symbol)) +
                       geom_line(linewidth = 1, alpha = .9) +
                       theme_minimal(base_line=16) +
                       theme(axis.title=element_blank(),
                             plot.background = element_rect(fill = "black"),
                             panel.background = element_rect(fill="black"),
                             panel.grid = element_blank(),
                             legend.text = element_text(colour="white"))
            )
          )
        })
    })
      
    }
  )
}
