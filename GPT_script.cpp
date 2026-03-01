
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
martigal_multipler if i loss 1 trade then need to increase the martigal_multipler+=1.5
then the next trade need to make the LotSize = LotSize * martigal_multipler and martigal_multipler != 0
-------------------- This are all my requirements.

-------------> Got the run time error,
How to solve ? 

give the full integrated code with the corrections.

