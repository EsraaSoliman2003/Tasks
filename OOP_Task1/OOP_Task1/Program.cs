// See https://aka.ms/new-console-template for more information
//Console.WriteLine("Hello, World!");





BankAccount account1 = new BankAccount();
BankAccount account2 = new BankAccount( 123456789, "Esraa Soliman", "30312028800645", "01146815591", "October", 1500 );


account2.ShowAccountDetails();




public class BankAccount
{
    public const string BankCode = "BNK001";

    public readonly DateTime CreatedDate;

    private int _accountNumber;
    private string _fullName;
    private string _nationalID;
    private string _phoneNumber;
    private string _address;
    private decimal _balance;


    public string FullName
    {
        get
        {
            return _fullName;
        }
        set
        {
            if (value != null && value.Trim() != "")
                _fullName = value;
        }
    }

    public string NationalID
    {
        get
        {
            return _nationalID;
        }
        set
        {
            if (value.Length == 14)
                _nationalID = value;
        }
    }

    public string PhoneNumber
    {
        get
        {
            return _phoneNumber;
        }
        set
        {
            if (value.Length == 11 && value.StartsWith("01"))
                _phoneNumber = value;
        }
    }

    public string Address
    {
        get
        {
            return _address;
        }
        set
        {
            _address = value;
        }
    }

    public decimal Balance
    {
        get
        {
            return _balance;
        }
        set
        {
            if (value >= 0)
                _balance = value;
        }
    }

    public BankAccount()
    {
        _accountNumber = 1000;
        _fullName = "Default Name";
        _nationalID = "00000000000000";
        _phoneNumber = "01000000000";
        _address = "-";
        _balance = 0;
        CreatedDate = DateTime.Now;
    }

    public BankAccount(int accountNumber, string fullName, string nationalID, string phoneNumber, string address, decimal balance)
    {
        this._accountNumber = accountNumber;
        this._fullName = fullName;
        this._nationalID = nationalID;
        this._phoneNumber = phoneNumber;
        this._address = address;
        this._balance = balance;
        CreatedDate = DateTime.Now;

    }

    public BankAccount(int accountNumber, string fullName, string nationalID, string phoneNumber, string address)
    {
        this._accountNumber = accountNumber;
        this._fullName = fullName;
        this._nationalID = nationalID;
        this._phoneNumber = phoneNumber;
        this._address = address;
        this._balance = 0;
        CreatedDate = DateTime.Now;

    }

    public void ShowAccountDetails()
    {
        Console.WriteLine("=== Account Details ===");
        Console.WriteLine($"Bank Code     : {BankCode}");
        Console.WriteLine($"Account Number: {_accountNumber}");
        Console.WriteLine($"Full Name     : {FullName}");
        Console.WriteLine($"National ID   : {NationalID}");
        Console.WriteLine($"Phone Number  : {PhoneNumber}");
        Console.WriteLine($"Address       : {Address}");
        Console.WriteLine($"Balance       : {Balance}");
        Console.WriteLine($"Created Date  : {CreatedDate}");
        Console.WriteLine("========================\n");
    }

    public bool IsValidNationalID( string nationalID)
    {
        return NationalID.Length == 14;

    }

    public bool IsValidPhoneNumber(string phone)
    {
        return phone.Length == 11 && phone.StartsWith("01");

    }


}
