// Create objects
SavingAccount account1 = new SavingAccount("SA001", 1000, 10);
CurrentAccount account2 = new CurrentAccount("CA001", 5000, 2000);

// Create List of BankAccount
List<BankAccount> accounts = new List<BankAccount>();
accounts.Add(account1);
accounts.Add(account2);

// Loop through accounts
foreach (var account in accounts)
{
    account.ShowAccountDetails();
    Console.WriteLine($"Calculated Interest: {account.CalculateInterest()}");
    Console.WriteLine("----------------------------");
}

// ===== Base Class =====
public class BankAccount
{
    public string AccountNumber { get; set; }
    public decimal Balance { get; set; }

    public BankAccount(string accountNumber, decimal balance)
    {
        AccountNumber = accountNumber;
        Balance = balance;
    }

    // Polymorphism method
    public virtual decimal CalculateInterest()
    {
        return 0;
    }

    // Show account details (can be overridden)
    public virtual void ShowAccountDetails()
    {
        Console.WriteLine($"Account Number: {AccountNumber}");
        Console.WriteLine($"Balance: {Balance}");
    }
}

// ===== Derived Class: SavingAccount =====
public class SavingAccount : BankAccount
{
    public decimal InterestRate { get; set; }

    public SavingAccount(string accountNumber, decimal balance, decimal interestRate)
        : base(accountNumber, balance)
    {
        InterestRate = interestRate;
    }

    public override decimal CalculateInterest()
    {
        return Balance * InterestRate / 100;
    }

    public override void ShowAccountDetails()
    {
        base.ShowAccountDetails();
        Console.WriteLine($"Interest Rate: {InterestRate}%");
    }
}

// ===== Derived Class: CurrentAccount =====
public class CurrentAccount : BankAccount
{
    public decimal OverdraftLimit { get; set; }

    public CurrentAccount(string accountNumber, decimal balance, decimal overdraftLimit)
        : base(accountNumber, balance)
    {
        OverdraftLimit = overdraftLimit;
    }

    public override decimal CalculateInterest()
    {
        return 0; // Current accounts don't earn interest
    }

    public override void ShowAccountDetails()
    {
        base.ShowAccountDetails();
        Console.WriteLine($"Overdraft Limit: {OverdraftLimit}");
    }
}
