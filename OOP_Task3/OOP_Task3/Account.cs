using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Transactions;

namespace OOP_Task3
{
    internal abstract class Account
    {
        private static int staticAccNum = 0;

        public int PersonalAccountNumber { get; private set; }
        public decimal Balance { get; protected set; }
        public DateTime DateOpened { get; private set; }
        public List<string> Log { get; private set; }

        protected Account()
        {
            staticAccNum++;
            PersonalAccountNumber = staticAccNum;
            DateOpened = DateTime.Now;
            Balance = 0;
            Log = new List<string>();
        }

        public virtual void Deposit(decimal amount)
        {
            Balance += amount;
            AddLog($"Deposited {amount}. New Balance = {Balance}");
            Console.WriteLine("Deposited successful.");

        }

        public virtual void Withdraw(decimal amount)
        {
            if (amount > Balance)
            {
                Console.WriteLine("Insufficient balance.");
                return;
            }

            Balance -= amount;
            AddLog($"Withdraw {amount}. New Balance = {Balance}");
            Console.WriteLine("Withdraw successful.");

        }

        public virtual void TransferTo(Account targetAccount, decimal amount)
        {
            if (amount > Balance)
            {
                Console.WriteLine("Insufficient balance for transfer.");
                return;
            }

            Balance -= amount;
            targetAccount.Balance += amount;

            AddLog($"Transferred {amount} to Account {targetAccount.PersonalAccountNumber}. New Balance = {Balance}");
            targetAccount.AddLog($"Received {amount} from Account {PersonalAccountNumber}. New Balance = {targetAccount.Balance}");

            Console.WriteLine("Transfer successful.");
        }

        public virtual void ShowAccountDetails()
        {
            Console.WriteLine($"Account Number: {PersonalAccountNumber}");
            Console.WriteLine($"Balance: {Balance}");
            Console.WriteLine($"Date Opened: {DateOpened}");

            Console.WriteLine($"--- Transaction History for Account {PersonalAccountNumber} ---");
            if (Log.Count == 0)
                Console.WriteLine("No transactions yet.");
            else
                Log.ForEach(Console.WriteLine);
        }

        protected void AddLog(string message)
        {
            Log.Add($"{DateTime.Now}: {message}");
        }
    }
}
