void BuyAlgorithmLogic(double buyPrice, double stopLoss, double takeProfit)
{
    while (true)
    {
        // Check if the current price is less than or equal to the buy price
        if (Bid <= buyPrice)
        {
            // Place a buy order
            int ticket = OrderSend(Symbol(), OP_BUY, 0.1, Ask, 3, stopLoss, takeProfit, "Buy Basket", 0, 0, Green);
            if (ticket > 0)
            {
                Print("Buy order placed successfully. Ticket: ", ticket);
            }
            else
            {
                Print("Error placing buy order. Error code: ", GetLastError());
            }
            break; // Exit the loop after placing the order
        }
    }
}