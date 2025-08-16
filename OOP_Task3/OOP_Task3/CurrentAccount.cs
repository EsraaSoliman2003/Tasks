using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OOP_Task3
{
    internal class CurrentAccount : Account
    {
        public decimal OverdraftLimit { get; set; } = 1000;

        public override void Withdraw(decimal amount)
        {
            if (amount > Balance + OverdraftLimit)
            {
                Console.WriteLine("Overdraft limit exceeded.");
                return;
            }

            Balance -= amount;
            AddLog($"Withdraw {amount} with overdraft. New Balance = {Balance}");
            Console.WriteLine("Withdraw successful.");

        }

        public override void ShowAccountDetails()
        {
            base.ShowAccountDetails();
            Console.WriteLine($"Overdraft Limit: {OverdraftLimit}");
        }
    }

}
