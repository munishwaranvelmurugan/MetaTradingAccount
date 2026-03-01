//+------------------------------------------------------------------+
//|                                                        demo1.mq4 |
//+------------------------------------------------------------------+
#property strict

int No_of_BullPatterns = 0;
int No_of_BearPatterns = 0;

struct Candle
{
   double open;
   double high;
   double low;
   double close;
};

// --- Helpers
bool isBullish(const Candle &c) { return (c.close > c.open); }
bool isBearish(const Candle &c) { return (c.close < c.open); }

// "Continuation" (optional, matches your logic style)
bool isBullishContinuation(const Candle &current, const Candle &previous)
{
   // current is more bullish than previous (higher open and higher close)
   return (current.open  > previous.open) &&
          (current.close > previous.close);
}

bool isBearishContinuation(const Candle &current, const Candle &previous)
{
   // current is more bearish than previous (lower open and lower close)
   return (current.open  < previous.open) &&
          (current.close < previous.close);
}

int OnInit()
{
   return(INIT_SUCCEEDED);
}

void OnTick()
{


   GeneralLogic();


}

void GeneralLogic()
{
   
   static datetime lastBarTime = 0;

   // run ONLY once per new candle (fastest possible: first tick of new bar)
   if(Bars < 4) return;
   if(Time[0] == lastBarTime) return;
   Print("S===========================================================");
   Print("New bar detected at time: ", TimeToString(Time[0], TIME_DATE|TIME_SECONDS));


   lastBarTime = Time[0];
   Candle c1, c2, c3;   // c1 = last closed candle, c2 = one before, c3 = three back

   c1.open  = Open[1];  c1.high  = High[1];  c1.low  = Low[1];  c1.close = Close[1];
   c2.open  = Open[2];  c2.high  = High[2];  c2.low  = Low[2];  c2.close = Close[2];
   c3.open  = Open[3];  c3.high  = High[3];  c3.low  = Low[3];  c3.close = Close[3];

   bool bull3 =
      isBullish(c1) && isBullish(c2) && isBullish(c3) &&
      isBullishContinuation(c1, c2) &&
      isBullishContinuation(c2, c3);

   bool bear3 =
      isBearish(c1) && isBearish(c2) && isBearish(c3) &&
      isBearishContinuation(c1, c2) &&
      isBearishContinuation(c2, c3);

   // If you want ONLY "3 bulls" without continuation rule, replace bull3/bear3 with:
   // bool bull3 = isBullish(c1) && isBullish(c2) && isBullish(c3);
   // bool bear3 = isBearish(c1) && isBearish(c2) && isBearish(c3);

   if(bull3)
   {
      No_of_BullPatterns++;

      double buyPrice  = c1.close;
      double stopLoss  = c3.open;
      double takeProfit = buyPrice 

      Print("======= 3 BULLISH CANDLES FOUND (Last 3 closed bars) =======");
      Print("Candle1 (bar 1): O=", c1.open, " H=", c1.high, " L=", c1.low, " C=", c1.close);
      Print("Candle2 (bar 2): O=", c2.open, " H=", c2.high, " L=", c2.low, " C=", c2.close);
      Print("Candle3 (bar 3): O=", c3.open, " H=", c3.high, " L=", c3.low, " C=", c3.close);
      Print("No_of_BullPatterns: ", No_of_BullPatterns);
      Print("Buy Price: ", buyPrice);
      Print("Stop Loss: ", stopLoss);
      Print("Take Profit (20 pips): ", takeProfit);
      Print("===========================================================");

   }
   else if(bear3)
   {
      No_of_BearPatterns++;

      double sellPrice = c1.close;
      double stopLoss  = c3.open;
      double takeProfit = sellPrice - 20 * Pip();

      Print("======= 3 BEARISH CANDLES FOUND (Last 3 closed bars) =======");
      Print("Candle1 (bar 1): O=", c1.open, " H=", c1.high, " L=", c1.low, " C=", c1.close);
      Print("Candle2 (bar 2): O=", c2.open, " H=", c2.high, " L=", c2.low, " C=", c2.close);
      Print("Candle3 (bar 3): O=", c3.open, " H=", c3.high, " L=", c3.low, " C=", c3.close);
      Print("No_of_BearPatterns: ", No_of_BearPatterns);
      Print("Sell Price: ", sellPrice);
      Print("Stop Loss: ", stopLoss);
      Print("Take Profit (20 pips): ", takeProfit);


      Print("E===========================================================");
   }
}
