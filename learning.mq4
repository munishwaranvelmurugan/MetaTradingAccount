// Previous candle (last closed)
double o1 = Open[1];
double h1 = High[1];
double l1 = Low[1];
double c1 = Close[1];

// Candle before that
double o2 = Open[2];
double h2 = High[2];
double l2 = Low[2];
double c2 = Close[2];


//printing
Print("Close[1] = ", Close[1]);



void OnTick()
{
   static datetime lastBarTime = 0;

   if(Time[0] == lastBarTime)
      return;

   lastBarTime = Time[0];

   double o1 = Open[1];
   double h1 = High[1];
   double l1 = Low[1];
   double c1 = Close[1];

   double o2 = Open[2];
   double h2 = High[2];
   double l2 = Low[2];
   double c2 = Close[2];

   Print("Candle 1 => O:", o1, " H:", h1, " L:", l1, " C:", c1);
   Print("Candle 2 => O:", o2, " H:", h2, " L:", l2, " C:", c2);
}

// -------------------------------------------------GENERAL
OrderSend(
   symbol,
   cmd,
   volume,
   price,
   slippage,
   stoploss,
   takeprofit,
   comment,
   magic,
   expiration,
   color
);


// -------------------------------------------------BUY ORDER EG:
double lot = 0.10;
double price = Ask;

int ticket = OrderSend(
   Symbol(),        // current symbol
   OP_BUY,          // BUY
   lot,
   price,
   3,               // slippage
   0,               // stop loss
   0,               // take profit
   "My Buy Order",
   12345,           // magic number
   0,
   clrBlue
);

int ticket = OrderSend(
   XAUUSD,        // current symbol
   OP_BUY,          // BUY
   lot,
   price,
   3,               // slippage
   0,               // stop loss
   0,               // take profit
   "My Buy Order",
   12345,           // magic number
   0,
   clrBlue
);

if(ticket < 0)
{
   Print("Buy failed. Error: ", GetLastError());
}


// -------------------------------------------------SELL ORDER EG:
double lot = 0.10;
double price = Bid;

int ticket = OrderSend(
   Symbol(),
   OP_SELL,
   lot,
   price,
   3,
   0,
   0,
   "My Sell Order",
   12345,
   0,
   clrRed
);

if(ticket < 0)
{
   Print("Sell failed. Error: ", GetLastError());
}

