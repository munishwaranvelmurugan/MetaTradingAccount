
Step 1:

    1 - 1sh need to find the 3 consicutive bull or bare candle dont consider the current candle
    , this is normalMode()
    2 - If i got the 3 bull candle i need to enter into BuyBasketMode()
        else if:  i got the 3 bare candle i need to enter into SellBasketMode()
    3 - if any of this condition is satisfied then this mode need to execute inifinate until give 
    the return to normalMode()


Step 2: (BuyBasketMode) logic

    1 - need to place the Entry(buyOrder) on the Closing price of the candle 1 ,
        Fix the TP(Take Profit) 10 Pip using Function from the Closing price of the candle 1,
        Fix the SL(Stop Loss) at the Third candle opening price.
        Asume this is Mode 1 (Trade 1)
    2 - in the mode 1 Track the current market price (index) 
        if it Hit the TP , Exit the trade(Trade 1) and return to normalMode()
        else if Hit the SL,  Exit the trade(Trade 1) and Enter into Mode 2
    3 - in the mode 2 , Place the Sell Order (Trade2) from Exit the trade(Trade 1) 
        which is the Opening price of the candle 3 ,
        Fix the TP(Take Profit) -10 Pip using Function from the Entry price of the Trade 2,
        Fix the SL(Stop Loss) at the First candle closing price.
    4 - analysis of mode 2
        if it HIT TP, Exit the trade(Trade 2) and return to normalMode()
        else if Hit the SL,  Exit the trade(Trade 2) and Enter into Mode 3
    5 - in the mode 3 , is Similar as mode 1 but only change is that,
        if Hit the SL,  Exit the trade(Trade 1) and dont enter into mode 2 just return to normalMode() and wait for the next signal

Step 3: (SellBasketMode) logic
    1 - need to place the Entry(sellOrder) on the Closing price of the candle 1 ,
        Fix the TP(Take Profit) 10 Pip using Function from the Closing price of the candle 1,
        Fix the SL(Stop Loss) at the Third candle opening price.
        Asume this is Mode 1 (Trade 1)
    2 - in the mode 1 Track the current market price (index) 
        if it Hit the TP , Exit the trade(Trade 1) and return to normalMode()
        else if Hit the SL,  Exit the trade(Trade 1) and Enter into Mode 2
    3 - in the mode 2 , Place the Buy Order (Trade2) from Exit the trade(Trade 1) 
        which is the Opening price of the candle 3 ,
        Fix the TP(Take Profit) -10 Pip using Function from the Entry price of the Trade 2,
        Fix the SL(Stop Loss) at the First candle closing price.
    4 - analysis of mode 2
        if it HIT TP, Exit the trade(Trade 2) and return to normalMode()
        else if Hit the SL,  Exit the trade(Trade 2) and Enter into Mode 3
    5 - in the mode 3 , is Similar as mode 1 but only change is that,
        if Hit the SL,  Exit the trade(Trade 1) and dont enter into mode 2 just return to normalMode() and wait for the next signal





 













===# Pseudo Code for the Trading Strategy
//+------------------------------------------------------------------+
#property strict

//================ INPUTS ===================
input string TradeSymbol = "XAUUSD";
input double LotSize     = 0.02;
input int    MagicNumber = 988950;

//================ ENUMS ===================
enum BasketState
{
   NORMAL_MODE = 0,
   BUY_BASKET,
   SELL_BASKET
};

enum TradeMode
{
   MODE_NONE = 0,
   MODE_1,
   MODE_2,
   MODE_3
};

//================ GLOBALS ===================
BasketState CurrentBasket = NORMAL_MODE;
TradeMode   CurrentMode   = MODE_NONE;

int CurrentTicket = -1;

double FirstCandleClose;
double ThirdCandleOpen;

datetime lastBarTime = 0;

//================ STRUCT ===================
struct Candle
{
   double open;
   double high;
   double low;
   double close;
};

//================ HELPERS ===================
bool isBullish(const Candle &c) { return (c.close > c.open); }
bool isBearish(const Candle &c) { return (c.close < c.open); }

double Pip()
{
   if(Digits == 3 || Digits == 5)
      return Point * 10;
   return Point;
}

//================ ORDER HELPERS ===================
bool HasOpenTrade()
{
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderSymbol()==TradeSymbol &&
            OrderMagicNumber()==MagicNumber)
            return true;
      }
   }
   return false;
}

void ResetToNormal()
{
   Print(">>> Resetting to NORMAL MODE");
   CurrentBasket = NORMAL_MODE;
   CurrentMode   = MODE_NONE;
   CurrentTicket = -1;
}

//================ ENTRY FUNCTIONS ===================
void OpenBuy(double sl,double tp)
{
   Print(">>> Opening BUY | SL:",sl," TP:",tp);

   CurrentTicket = OrderSend(
      TradeSymbol,
      OP_BUY,
      LotSize,
      Ask,
      3,
      sl,
      tp,
      "BuyBasket",
      MagicNumber,
      0,
      clrBlue
   );

   if(CurrentTicket < 0)
      Print("!!! BUY FAILED. Error: ",GetLastError());
   else
      Print(">>> BUY OPENED. Ticket: ",CurrentTicket);
}

void OpenSell(double sl,double tp)
{
   Print(">>> Opening SELL | SL:",sl," TP:",tp);

   CurrentTicket = OrderSend(
      TradeSymbol,
      OP_SELL,
      LotSize,
      Bid,
      3,
      sl,
      tp,
      "SellBasket",
      MagicNumber,
      0,
      clrRed
   );

   if(CurrentTicket < 0)
      Print("!!! SELL FAILED. Error: ",GetLastError());
   else
      Print(">>> SELL OPENED. Ticket: ",CurrentTicket);
}

//================ NORMAL MODE ===================
void CheckForPattern()
{
   if(Symbol() != TradeSymbol) return;
   if(Period() != PERIOD_M5)   return;

   if(Bars < 4) return;
   if(Time[0] == lastBarTime) return;

   lastBarTime = Time[0];

   Print("---- New M5 Candle Detected ----");

   Candle c1,c2,c3;

   c1.open=Open[1]; c1.close=Close[1];
   c2.open=Open[2]; c2.close=Close[2];
   c3.open=Open[3]; c3.close=Close[3];

   bool bull3 = isBullish(c1) && isBullish(c2) && isBullish(c3);
   bool bear3 = isBearish(c1) && isBearish(c2) && isBearish(c3);

   if(bull3)
   {
      Print(">>> 3 BULLISH CANDLES FOUND");

      FirstCandleClose = c1.close;
      ThirdCandleOpen  = c3.open;

      CurrentBasket = BUY_BASKET;
      CurrentMode   = MODE_1;

      double sl = ThirdCandleOpen;
      double tp = FirstCandleClose + 10*Pip();

      OpenBuy(sl,tp);
   }
   else if(bear3)
   {
      Print(">>> 3 BEARISH CANDLES FOUND");

      FirstCandleClose = c1.close;
      ThirdCandleOpen  = c3.open;

      CurrentBasket = SELL_BASKET;
      CurrentMode   = MODE_1;

      double sl = ThirdCandleOpen;
      double tp = FirstCandleClose - 10*Pip();

      OpenSell(sl,tp);
   }
}

//================ BUY BASKET ===================
void ManageBuyBasket()
{
   if(!OrderSelect(CurrentTicket,SELECT_BY_TICKET)) return;
   if(OrderSymbol()!=TradeSymbol ||
      OrderMagicNumber()!=MagicNumber) return;

   if(OrderCloseTime()>0)
   {
      Print(">>> BUY Basket Trade Closed. Profit: ",OrderProfit());

      if(OrderProfit()>0)
      {
         Print(">>> TP HIT in BUY Basket");
         ResetToNormal();
         return;
      }
      else
      {
         if(CurrentMode==MODE_1)
         {
            Print(">>> MODE 1 SL HIT → Enter MODE 2");

            CurrentMode=MODE_2;

            double sl=FirstCandleClose;
            double tp=ThirdCandleOpen-10*Pip();

            OpenSell(sl,tp);
         }
         else if(CurrentMode==MODE_2)
         {
            Print(">>> MODE 2 SL HIT → Enter MODE 3");

            CurrentMode=MODE_3;

            double sl=ThirdCandleOpen;
            double tp=FirstCandleClose+10*Pip();

            OpenBuy(sl,tp);
         }
         else if(CurrentMode==MODE_3)
         {
            Print(">>> MODE 3 SL HIT → Back to NORMAL");

            ResetToNormal();
         }
      }
   }
}

//================ SELL BASKET ===================
void ManageSellBasket()
{
   if(!OrderSelect(CurrentTicket,SELECT_BY_TICKET)) return;
   if(OrderSymbol()!=TradeSymbol ||
      OrderMagicNumber()!=MagicNumber) return;

   if(OrderCloseTime()>0)
   {
      Print(">>> SELL Basket Trade Closed. Profit: ",OrderProfit());

      if(OrderProfit()>0)
      {
         Print(">>> TP HIT in SELL Basket");
         ResetToNormal();
         return;
      }
      else
      {
         if(CurrentMode==MODE_1)
         {
            Print(">>> MODE 1 SL HIT → Enter MODE 2");

            CurrentMode=MODE_2;

            double sl=FirstCandleClose;
            double tp=ThirdCandleOpen+10*Pip();

            OpenBuy(sl,tp);
         }
         else if(CurrentMode==MODE_2)
         {
            Print(">>> MODE 2 SL HIT → Enter MODE 3");

            CurrentMode=MODE_3;

            double sl=ThirdCandleOpen;
            double tp=FirstCandleClose-10*Pip();

            OpenSell(sl,tp);
         }
         else if(CurrentMode==MODE_3)
         {
            Print(">>> MODE 3 SL HIT → Back to NORMAL");

            ResetToNormal();
         }
      }
   }
}

//================ MAIN ===================
void OnTick()
{
   if(Symbol()!=TradeSymbol) return;
   if(Period()!=PERIOD_M5) return;

   if(CurrentBasket==NORMAL_MODE)
      CheckForPattern();
   else if(CurrentBasket==BUY_BASKET)
      ManageBuyBasket();
   else if(CurrentBasket==SELL_BASKET)
      ManageSellBasket();
}




===== I have written Little bit of the code.

Understand the logic and complete the code for me, i need to place the orders and manage the trades as per the logic i have mentioned above.
input string TradeSymbol = "XAUUSD";
input double LotSize     = 0.02;
input int    MagicNumber = 988950;

-------- I need to add some conditions on it
add the TradeSymbol and magic number,
and also make sure it only manages trades for that symbol and magic number.
add some debug prints to track the flow of the strategy.
add the LotSize to the order send functions.
and i need to trade in M5 timeframe only.



