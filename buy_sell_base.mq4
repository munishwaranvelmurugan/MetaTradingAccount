void OnTick()
{
   static datetime lastBarTime = 0;

   if(Time[0] == lastBarTime)
      return;

   lastBarTime = Time[0];

   double o1 = Open[1];
   double c1 = Close[1];

   Print("Last candle O:", o1, " C:", c1);

   // Check open trades
   for(int i=0;i<OrdersTotal();i++)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol())
            return;

   if(c1 > o1)
      OrderSend(Symbol(), OP_BUY, 0.1, Ask, 3, 0, 0, "Bullish Buy", 111, 0, clrBlue);

   if(c1 < o1)
      OrderSend(Symbol(), OP_SELL, 0.1, Bid, 3, 0, 0, "Bearish Sell", 111, 0, clrRed);
}
