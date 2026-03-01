//+------------------------------------------------------------------+
//|                                                        demo1.mq4 |
//+------------------------------------------------------------------+
#property strict

int No_of_BullPatterns = 0;
int No_of_BearPatterns = 0;

bool isBuyBasket = false;   // Flag to prevent multiple buy orders
bool isSellBasket = false;  // Flag to prevent multiple sell orders

int buyTicket = -1;         // Store the ticket number of the buy order
int sellTicket = -1;        // Store the ticket number of the sell order

struct Scale
{
   double stoploss1;
   double takeprofit1;
   int    current_logic; // 0= no trade, 1= buy trade , 2 = sell trade, 3= buy trade
   double stoploss2;
   double takeprofit2;
};

Scale scale;

void ResetAll()
{
   isBuyBasket = false;
   isSellBasket = false;
   buyTicket = -1;
   sellTicket = -1;

   scale.stoploss1 = 0;
   scale.takeprofit1 = 0;
   scale.current_logic = 0;
   scale.stoploss2 = 0;
   scale.takeprofit2 = 0;
}

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

bool isBullishContinuation(const Candle &current, const Candle &previous)
{
   return (current.open  > previous.open) &&
          (current.close > previous.close);
}

bool isBearishContinuation(const Candle &current, const Candle &previous)
{
   return (current.open  < previous.open) &&
          (current.close < previous.close);
}

// Pip helper (handles 5-digit / 3-digit brokers)
double Pip()
{
   if(Digits == 3 || Digits == 5) return 10 * Point;
   return Point;
}

// ✅ MT4-safe: No pointers. Updates global vars directly.
bool PlaceBuyOrder(double stopLoss, double takeProfit)
{
   if(isBuyBasket)
   {
      Print("A buy order is already active.");
      return false;
   }

   RefreshRates();

   int ticket = OrderSend(Symbol(), OP_BUY, 0.1, Ask, 3,
                          stopLoss, takeProfit,
                          "Buy Basket", 0, 0, Green);

   if(ticket > 0)
   {
      Print("Buy order placed successfully. Ticket: ", ticket);
      isBuyBasket = true;
      buyTicket   = ticket;
      return true;
   }

   Print("Error placing buy order. Error code: ", GetLastError());
   return false;
}

int OnInit()
{
   ResetAll();
   return(INIT_SUCCEEDED);
}

void OnTick()
{
   if(isBuyBasket == true)
   {
      // BUY LOGIC
      BuyAlgorithmLogic();
   }

   if(isSellBasket == true)
   {
      // SELL LOGIC (not implemented)
   }

   GeneralLogic();
}

void GeneralLogic()
{
   static datetime lastBarTime = 0;

   if(Bars < 4) return;

   // run ONLY once per new candle
   if(Time[0] == lastBarTime || isBuyBasket == true || isSellBasket == true) return;

   Print("S===========================================================");
   Print("New bar detected at time: ", TimeToString(Time[0], TIME_DATE|TIME_SECONDS));

   lastBarTime = Time[0];

   Candle c1, c2, c3;
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

   if(bull3)
   {
      No_of_BullPatterns++;

      double buyPrice   = c1.close;         // reference only
      double stopLoss   = c3.open;
      double takeProfit = buyPrice + Pip(); // NOTE: 1 pip (because Pip() = 1 pip size)

      Print("======= 3 BULLISH CANDLES FOUND (Last 3 closed bars) =======");
      Print("No_of_BullPatterns: ", No_of_BullPatterns);
      Print("Buy Price(ref): ", buyPrice);
      Print("Stop Loss: ", stopLoss);
      Print("Take Profit: ", takeProfit);
      Print("===========================================================");

      bool ok = PlaceBuyOrder(stopLoss, takeProfit);
      Print("Buy order placement status: ", (ok ? "Success" : "Failed"));

      if(ok)
      {
         scale.stoploss1 = stopLoss;
         scale.takeprofit1 = takeProfit;
         scale.current_logic = 1;

         scale.stoploss2 = buyPrice;
         scale.takeprofit2 = stopLoss - Pip();
      }
   }
   else if(bear3)
   {
      No_of_BearPatterns++;

      double sellPrice  = c1.close;            // reference only
      double stopLoss   = c3.open;
      double takeProfit = sellPrice - 20 * Pip();

      Print("======= 3 BEARISH CANDLES FOUND (Last 3 closed bars) =======");
      Print("No_of_BearPatterns: ", No_of_BearPatterns);
      Print("Sell Price(ref): ", sellPrice);
      Print("Stop Loss: ", stopLoss);
      Print("Take Profit: ", takeProfit);
      Print("E===========================================================");
   }
}

void BuyAlgorithmLogic()
{
   switch(scale.current_logic)
   {
      case 1:
         BuyBasketCase1(false);
         break;

      case 2:
         BuyBasketCase2();
         break;

      case 3:
         BuyBasketCase1(true);
         break;

      default:
         Print("Invalid current_logic value: ", scale.current_logic);
         break;
   }
}

void BuyBasketCase1(bool needToStop)
{
   RefreshRates();
   double currentPrice = Bid;

   if(currentPrice >= scale.takeprofit1)
   {
      int ticket = OrderSend(Symbol(), OP_SELL, 0.1, Bid, 3,
                             scale.stoploss1, scale.takeprofit1,
                             "Sell Basket", 0, 0, Red);

      if(ticket > 0)
      {
         Print("Sell order placed successfully. Ticket: ", ticket);
         ResetAll();
      }
      else
      {
         Print("Error placing sell order. Error code: ", GetLastError());
      }
   }
   else if(currentPrice <= scale.stoploss1)
   {
      if(needToStop)
      {
         ResetAll();
         return;
      }

      scale.current_logic = 2;

      int ticket = OrderSend(Symbol(), OP_SELL, 0.1, Bid, 3,
                             scale.stoploss1, scale.takeprofit1,
                             "Sell Basket", 0, 0, Red);

      if(ticket <= 0)
         Print("Error placing sell order. Error code: ", GetLastError());
   }
}

void BuyBasketCase2()
{
   RefreshRates();

   if(scale.takeprofit2 >= Bid)
   {
      int ticket = OrderSend(Symbol(), OP_SELL, 0.1, Bid, 3,
                             scale.stoploss2, scale.takeprofit2,
                             "Sell Basket", 0, 0, Red);

      if(ticket > 0)
      {
         Print("Sell order placed successfully. Ticket: ", ticket);
         ResetAll();
      }
      else
      {
         Print("Error placing sell order. Error code: ", GetLastError());
      }
   }
   else if(scale.stoploss2 <= Ask)
   {
      int ticket = OrderSend(Symbol(), OP_BUY, 0.1, Ask, 3,
                             scale.stoploss2, scale.takeprofit2,
                             "Buy Basket", 0, 0, Green);

      if(ticket > 0)
      {
         Print("Buy order placed successfully. Ticket: ", ticket);
         scale.current_logic = 3;
      }
      else
      {
         Print("Error placing buy order. Error code: ", GetLastError());
      }
   }
}
