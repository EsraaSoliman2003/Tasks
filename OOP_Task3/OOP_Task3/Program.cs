using OOP_Task3;

Bank bank1 = new Bank("Masr", 123);

// Initial data
Customer customer1 = new Customer("Esraa", 123, new DateOnly(2003, 12, 2));
customer1.Accounts.Add(new SavingAccount());
customer1.Accounts.Add(new CurrentAccount());
bank1.Customers.Add(customer1);

Customer customer2 = new Customer("Mai", 456, new DateOnly(2003, 12, 2));
customer2.Accounts.Add(new CurrentAccount());
bank1.Customers.Add(customer2);

Customer customer3 = new Customer("Nada", 789, new DateOnly(2003, 12, 2));
customer3.Accounts.Add(new SavingAccount());
bank1.Customers.Add(customer3);

// Main Menu
bool running = true;
while (running)
{
    Console.WriteLine("\n=== Bank Menu ===");
    Console.WriteLine("1. Show all customers report");
    Console.WriteLine("2. Search for a customer");
    Console.WriteLine("3. Update customer info");
    Console.WriteLine("4. Deposit");
    Console.WriteLine("5. Withdraw");
    Console.WriteLine("6. Transfer between accounts");
    Console.WriteLine("7. Delete customer");
    Console.WriteLine("0. Exit");
    Console.Write("Your choice: ");
    string? choice = Console.ReadLine();

    switch (choice)
    {
        case "1": // Show report
            foreach (var cust in bank1.Customers)
                bank1.ShowSingleReport(cust);
            break;

        case "2": // Search
            Console.WriteLine("A => by name ");
            Console.WriteLine("B => by national ID ");
            string? searchWay = Console.ReadLine();
            Console.Write("Enter value: ");
            string? value = Console.ReadLine();

            Customer? found = null;
            if (searchWay?.ToLower() == "a")
                found = bank1.Customers.Find(c => c.FullName == value);
            else if (searchWay?.ToLower() == "b" && int.TryParse(value, out int nid))
                found = bank1.Customers.Find(c => c.NationalID == nid);

            if (found != null) bank1.ShowSingleReport(found);
            else Console.WriteLine("Customer not found.");
            break;

        case "3": // Update
            Console.Write("Enter customer Id: ");
            if (int.TryParse(Console.ReadLine(), out int idToUpdate))
            {
                var cust = bank1.Customers.Find(c => c.Id == idToUpdate);
                if (cust != null)
                {
                    Console.Write("Enter new name: ");
                    string? newName = Console.ReadLine();
                    Console.Write("Enter new birthdate (yyyy-mm-dd): ");
                    if (DateOnly.TryParse(Console.ReadLine(), out DateOnly newDate))
                    {
                        cust.updateInfo(newName ?? cust.FullName!, newDate);
                    }
                }
            }
            break;

        case "4": // Deposit
            Console.Write("Enter customer Id: ");
            if (int.TryParse(Console.ReadLine(), out int idDep))
            {
                var cust = bank1.Customers.Find(c => c.Id == idDep);
                if (cust != null)
                {
                    Console.Write("Enter account number: ");
                    if (int.TryParse(Console.ReadLine(), out int accNum))
                    {
                        var acc = cust.Accounts.Find(a => a.PersonalAccountNumber == accNum);
                        if (acc != null)
                        {
                            Console.Write("Enter amount: ");
                            if (decimal.TryParse(Console.ReadLine(), out decimal amount))
                                acc.Deposit(amount);
                        }
                    }
                }
            }
            break;

        case "5": // Withdraw
            Console.Write("Enter customer Id: ");
            if (int.TryParse(Console.ReadLine(), out int idWit))
            {
                var cust = bank1.Customers.Find(c => c.Id == idWit);
                if (cust != null)
                {
                    Console.Write("Enter account number: ");
                    if (int.TryParse(Console.ReadLine(), out int accNum))
                    {
                        var acc = cust.Accounts.Find(a => a.PersonalAccountNumber == accNum);
                        if (acc != null)
                        {
                            Console.Write("Enter amount: ");
                            if (decimal.TryParse(Console.ReadLine(), out decimal amount))
                                acc.Withdraw(amount);
                        }
                    }
                }
            }
            break;

        case "6": // Transfer
            Console.Write("Enter sender customer Id: ");
            if (int.TryParse(Console.ReadLine(), out int fromId))
            {
                var fromCust = bank1.Customers.Find(c => c.Id == fromId);
                if (fromCust != null)
                {
                    Console.Write("Enter sender account number: ");
                    int fromAccNum = int.Parse(Console.ReadLine() ?? "0");
                    var fromAcc = fromCust.Accounts.Find(a => a.PersonalAccountNumber == fromAccNum);

                    Console.Write("Enter receiver customer Id: ");
                    int toId = int.Parse(Console.ReadLine() ?? "0");
                    var toCust = bank1.Customers.Find(c => c.Id == toId);

                    Console.Write("Enter receiver account number: ");
                    int toAccNum = int.Parse(Console.ReadLine() ?? "0");
                    var toAcc = toCust?.Accounts.Find(a => a.PersonalAccountNumber == toAccNum);

                    if (fromAcc != null && toAcc != null)
                    {
                        Console.Write("Enter amount: ");
                        decimal amount = decimal.Parse(Console.ReadLine() ?? "0");
                        fromAcc.TransferTo(toAcc, amount);
                    }
                }
            }
            break;

        case "7": // Delete
            Console.Write("Enter customer Id: ");
            if (int.TryParse(Console.ReadLine(), out int idDel))
            {
                var cust = bank1.Customers.Find(c => c.Id == idDel);
                if (cust != null)
                {
                    if (cust.CanDelete())
                    {
                        bank1.Customers.Remove(cust);
                        Console.WriteLine("Customer deleted successfully.");
                    }
                    else Console.WriteLine($"Cannot delete. Balance = {cust.Balance}");
                }
            }
            break;

        case "0":
            running = false;
            break;

        default:
            Console.WriteLine("Invalid choice.");
            break;
    }
}
