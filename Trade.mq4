//+------------------------------------------------------------------+
#property strict

input string TradeSymbol = "XAUUSD";
input double LotSize     = 0.02;
input int    MagicNumber = 988950;
input int PipMultiplier = 300;

//================ ENUMS ===================
enum BasketState { NORMAL_MODE=0, BUY_BASKET, SELL_BASKET };
enum TradeMode   { MODE_NONE=0, MODE_1, MODE_2, MODE_3 };

//================ GLOBALS ===================
BasketState CurrentBasket = NORMAL_MODE;
TradeMode   CurrentMode   = MODE_NONE;

int      CurrentTicket = -1;
datetime LastClosedTime = 0;

double FirstCandleClose;
double ThirdCandleOpen;

double CurrentMultiplier = 0;

datetime lastBarTime = 0;

//================ STRUCT ===================
struct Candle { double open; double close; };

//================ HELPERS ===================
bool isBullish(const Candle &c){ return c.close > c.open; }
bool isBearish(const Candle &c){ return c.close < c.open; }

double Pip()
{
   if(Digits==3 || Digits==5)
      return Point*10*PipMultiplier;
   return Point*PipMultiplier;
}

//================ LOT ===================
double GetLotSize()
{
   double lot = LotSize;

   if(CurrentMultiplier>0)
      lot = LotSize * CurrentMultiplier;

   lot = NormalizeDouble(lot,2);

   Print(">>> Lot:",lot," Multiplier:",CurrentMultiplier);

   return lot;
}

//================ CHECK OPEN TRADE ===================
bool IsTradeOpen()
{
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
      {
         if(OrderMagicNumber()==MagicNumber &&
            OrderSymbol()==TradeSymbol)
         {
            CurrentTicket = OrderTicket();
            return true;
         }
      }
   }
   return false;
}

//================ SAFE SEND ===================
bool SendOrder(int type,double rawSL,double rawTP)
{
   RefreshRates();

   double price = (type==OP_BUY)? Ask : Bid;
   price = NormalizeDouble(price,Digits);

   double spread = MarketInfo(Symbol(),MODE_SPREAD)*Point;
   double stopLevel = MarketInfo(Symbol(),MODE_STOPLEVEL)*Point;

   // Minimum allowed distance
   double minDistance = MathMax(stopLevel, spread);
   minDistance += 5*Point;   // extra safety buffer

   double sl=rawSL;
   double tp=rawTP;

   if(type==OP_BUY)
   {
      if(price-sl < minDistance)
         sl = price-minDistance;

      if(tp-price < minDistance)
         tp = price+minDistance;
   }
   else
   {
      if(sl-price < minDistance)
         sl = price+minDistance;

      if(price-tp < minDistance)
         tp = price-minDistance;
   }

   sl=NormalizeDouble(sl,Digits);
   tp=NormalizeDouble(tp,Digits);

   double lot = GetLotSize();

   Print(">>> SEND | Type:",type,
         " Price:",price,
         " SL:",sl,
         " TP:",tp,
         " Spread:",spread/Point,
         " StopLevel:",stopLevel/Point);

   int ticket = OrderSend(Symbol(),type,lot,price,3,sl,tp,
                          "BasketEA",MagicNumber,0,clrBlue);

   if(ticket<0)
   {
      Print("!!! OrderSend failed:",GetLastError());
      return false;
   }

   CurrentTicket=ticket;
   Print(">>> Opened Ticket:",ticket);
   return true;
}

//================ RESET ===================
void ResetBasket()
{
   CurrentBasket=NORMAL_MODE;
   CurrentMode=MODE_NONE;
   CurrentTicket=-1;
   Print(">>> BACK TO NORMAL");
}

//================ PATTERN ===================
void CheckForPattern()
{
   if(Symbol()!=TradeSymbol) return;
   if(Period()!=PERIOD_M5) return;
   if(Bars<4) return;
   if(Time[0]==lastBarTime) return;

   lastBarTime=Time[0];

   Candle c1,c2,c3;
   c1.open=Open[1]; c1.close=Close[1];
   c2.open=Open[2]; c2.close=Close[2];
   c3.open=Open[3]; c3.close=Close[3];

   bool bull3=isBullish(c1)&&isBullish(c2)&&isBullish(c3);
   bool bear3=isBearish(c1)&&isBearish(c2)&&isBearish(c3);

   if(bull3)
   {
      FirstCandleClose=c1.close;
      ThirdCandleOpen=c3.open;
      CurrentBasket=BUY_BASKET;
      CurrentMode=MODE_1;

      SendOrder(OP_BUY,
                ThirdCandleOpen,
                FirstCandleClose+Pip());
   }
   else if(bear3)
   {
      FirstCandleClose=c1.close;
      ThirdCandleOpen=c3.open;
      CurrentBasket=SELL_BASKET;
      CurrentMode=MODE_1;

      SendOrder(OP_SELL,
                ThirdCandleOpen,
                FirstCandleClose-Pip());
   }
}

//================ MANAGE ===================
void ManageBasket()
{
   if(IsTradeOpen()) return;

   for(int i=OrdersHistoryTotal()-1;i>=0;i--)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY))
      {
         if(OrderMagicNumber()==MagicNumber &&
            OrderSymbol()==TradeSymbol &&
            OrderCloseTime()>LastClosedTime)
         {
            LastClosedTime=OrderCloseTime();

            double profit=OrderProfit();
            Print("Closed Profit:",profit);

            if(profit>0)
            {
               CurrentMultiplier=0;
               ResetBasket();
               return;
            }
            else
            {
               if(CurrentMultiplier==0)
                  CurrentMultiplier=1.5;
               else
                  CurrentMultiplier+=2;
            }

            if(CurrentMode==MODE_1)
            {
               CurrentMode=MODE_2;

               if(CurrentBasket==BUY_BASKET)
                  SendOrder(OP_SELL,
                            FirstCandleClose,
                            ThirdCandleOpen-Pip());
               else
                  SendOrder(OP_BUY,
                            FirstCandleClose,
                            ThirdCandleOpen+Pip());
            }
            else if(CurrentMode==MODE_2)
            {
               CurrentMode=MODE_3;

               if(CurrentBasket==BUY_BASKET)
                  SendOrder(OP_BUY,
                            ThirdCandleOpen,
                            FirstCandleClose+Pip());
               else
                  SendOrder(OP_SELL,
                            ThirdCandleOpen,
                            FirstCandleClose-Pip());
            }
            else
            {
               ResetBasket();
            }

            break;
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
   else
      ManageBasket();
}