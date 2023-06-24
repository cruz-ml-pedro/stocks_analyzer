library(tidyquant)

tickers <- c("BTC-USD","ETH-USD","LTC-USD","ADA-USD","DOT-USD","BCH-USD","XLM-USD", "DOGE-USD","BNB-USD")
benchmarks <- c("^CMC200", "^NDX", "^GSPC")

prices <- tq_get(tickers, 
                 get  = "stock.prices",
                 from = today()-months(12),
                 to   = today(),
                 complete_cases = F) 

bench <- tq_get(benchmarks,
                get  = "stock.prices",
                from = today()-months(12),
                to   = today()) 
