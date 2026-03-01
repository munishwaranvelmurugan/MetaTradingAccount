//+------------------------------------------------------------------+
//|                                                        demo1.mq4 |
//+------------------------------------------------------------------+
#property strict

int No_of_BullPatterns = 0;
int No_of_BearPatterns = 0;
bool isBuyBasket = false; // Flag to prevent multiple buy orders
bool isSellBasket = false; // Flag to prevent multiple sell orders
int buyTicket = -1; // Store the ticket number of the buy order
int sellTicket = -1; // Store the ticket number of the sell order


struct Scale
{
   double stoploss1;
   double takeprofit1;
   int current_logic; // 0= no trade, 1= buy trade , 2 = sell trade
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

// Pip helper (handles 5-digit / 3-digit brokers)
double Pip()
{
   if(Digits == 3 || Digits == 5) return 10 * Point;
   return Point;
}

bool PlaceBuyOrder(double buyPrice, double stopLoss, double takeProfit, bool *isBuyBasket, int *buyTicket)
{
    if (*isBuyBasket)
    {
        Print("A buy order is already active. Cannot place another buy order.");
        return false;
    }

    // Place a buy order
    int ticket = OrderSend(Symbol(), OP_BUY, 0.1, Ask, 3, stopLoss, takeProfit, "Buy Basket", 0, 0, Green);
    if (ticket > 0)
    {
        Print("Buy order placed successfully. Ticket: ", ticket);
        *isBuyBasket = true; // Set the flag to indicate an active buy order
        *buyTicket = ticket; // Store the ticket number of the buy order
        return true;
    }
    else
    {
        Print("Error placing buy order. Error code: ", GetLastError());
        return false;
    }
}


int OnInit()
{
   return(INIT_SUCCEEDED);
}

void OnTick()
{


   if(isBuyBasket == true)
   {
      //BUY LOGIC
      BuyAlgorithmLogic();
   }
   if(isSellBasket == true)
   {
      //SELL LOGIC
   }
   GeneralLogic();


}

void GeneralLogic()
{
   
   static datetime lastBarTime = 0;

   // run ONLY once per new candle (fastest possible: first tick of new bar)
   if(Bars < 4) return;
   if(Time[0] == lastBarTime || isBuyBasket == true || isSellBasket == true) return;
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
      double takeProfit = buyPrice + Pip();

      Print("======= 3 BULLISH CANDLES FOUND (Last 3 closed bars) =======");
      Print("Candle1 (bar 1): O=", c1.open, " H=", c1.high, " L=", c1.low, " C=", c1.close);
      Print("Candle2 (bar 2): O=", c2.open, " H=", c2.high, " L=", c2.low, " C=", c2.close);
      Print("Candle3 (bar 3): O=", c3.open, " H=", c3.high, " L=", c3.low, " C=", c3.close);
      Print("No_of_BullPatterns: ", No_of_BullPatterns);
      Print("Buy Price: ", buyPrice);
      Print("Stop Loss: ", stopLoss);
      Print("Take Profit (20 pips): ", takeProfit);
      Print("===========================================================");

      bool isBuyOrderPlaced = PlaceBuyOrder(buyPrice, stopLoss, takeProfit, &isBuyBasket, &buyTicket);
      Print("Buy order placement status: ", isBuyOrderPlaced ? "Success" : "Failed");
      if (isBuyOrderPlaced)
      {
         isBuyBasket = isBuyOrderPlaced; // Update the flag based on whether the order was placed successfully 
         scale.stoploss1 = stopLoss;
         scale.takeprofit1 = takeProfit;
         scale.current_logic = 1; // Set to buy logic
         scale.stoploss2 = buyPrice
         scale.takeprofit2  = stopLoss - Pip()
      }
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

void BuyAlgorithmLogic(){
  switch(scale.current_logic)
  {
    case 1:
      // BUY LOGIC
      BuyBasketCase1(false);
      break;
    case 2:
      BuyBasketCase2();
      // SELL LOGIC
      break;
    case 3:
      BuyBasketCase1(true);
      // SELL LOGIC
      break;

    default:
      Print("Invalid current_logic value: ", scale.current_logic);
  }
}


void BuyBasketCase1(bool needToStop)
{
   double currentPrice = Bid;
   if(currentPrice >= scale.takeprofit1)
   {
      // place the sell and exit the loop
      int ticket = OrderSend(Symbol(), OP_SELL, 0.1, Bid, 3, scale.stoploss1, scale.takeprofit1, "Sell Basket", 0, 0, Red);
      if (ticket > 0)
      {
         Print("Sell order placed successfully. Ticket: ", ticket);
         ResetAll();
      }
      else
      {
         Print("Error placing sell order. Error code: ", GetLastError());
      }
   }
   else if (currentPrice <= scale.stoploss1)
   {
      // switch to buybaseketcase2 and make the sell for the amount scale.stoploss1
      if (needToStop){
         // reset all and go back to general logic
         ResetAll();
         return;
      }
      scale.current_logic = 2; // Switch to sell logic
      int ticket = OrderSend(Symbol(), OP_SELL, 0.1, Bid, 3, scale.stoploss1, scale.takeprofit1, "Sell Basket", 0, 0, Red);
   }
}

void BuyBasketCase2()
{
   if(scale.takeprofit2 >= Bid)
   {
      // place sell order and reset all and go back to general logic
      int ticket = OrderSend(Symbol(), OP_SELL, 0.1, Bid, 3, scale.stoploss2, scale.takeprofit2, "Sell Basket", 0, 0, Red);
      if (ticket > 0)
      {
         Print("Sell order placed successfully. Ticket: ", ticket);
         ResetAll();
      }
      else
      {
         Print("Error placing sell order. Error code: ", GetLastError());
      }
   }
   else if (scale.stoploss2 <= Ask)
   {
      // place the buy order and return to case 3
      int ticket = OrderSend(Symbol(), OP_BUY, 0.1, Ask, 3, scale.stoploss2, scale.takeprofit2, "Buy Basket", 0, 0, Green);
      if (ticket > 0)
      {
         Print("Buy order placed successfully. Ticket: ", ticket);
         scale.current_logic = 3; // Switch to case 3
      }
      else
      {
         Print("Error placing buy order. Error code: ", GetLastError());
      }
   }
}