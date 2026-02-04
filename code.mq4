//+------------------------------------------------------------------+
//|                                                        demo1.mq4 |
//|                                  Copyright 2026, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property strict
//+------------------------------------------------------------------+
//| VARIABLE INITILIZATION                                           |
//+------------------------------------------------------------------+
int No_of_BullPatterns=0; 
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
struct Candle
{
   double open;
   double high;
   double low;
   double close;
};


int OnInit()
  {
//---
    return(INIT_SUCCEEDED);
//---
  
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| CUSTOM METHODS                                                   |
//+------------------------------------------------------------------+
bool isBullishContinuation(const Candle &current, const Candle &previous)
{
  return (previous.close < current.close) &&
         (previous.open  < current.open);
}

bool isBullish(const Candle &current)
{
  return current.open   < current.close; 
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  static datetime lastBarTime = 0;

  if(Time[0] == lastBarTime || Bars < 4)
    return;

  lastBarTime = Time[0];
  Candle candle[4];

  for(int i = 1; i <=3; i++)
    {
      candle[i].open = Open[i];
      candle[i].high = High[i];
      candle[i].low = Low[i];
      candle[i].close = Close[i];
    }

    if (    isBullish(candle[1]) &&
            isBullish(candle[2]) &&
            isBullish(candle[3]) &&
            isBullishContinuation(candle[1], candle[2]) &&
            isBullishContinuation(candle[2], candle[3])
      )
    {
      Print("3 Bullish candle pattern detected!");
      for(int i = 1; i <=3; i++)
        {
          Print("Candle ", i, ": Open=", candle[i].open, " High=", candle[i].high, " Low=", candle[i].low, " Close=", candle[i].close);
        }
      Print("No_of_BullPatterns: ", ++No_of_BullPatterns);
    }


  
  }
//+------------------------------------------------------------------+
