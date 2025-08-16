using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OOP_Task3
{
    internal class SavingAccount : Account
    {
        public decimal InterestRate { get; set; } = 5;

        public decimal CalculateMonthlyInterest()
        {
            return (Balance * InterestRate) / 100 / 12;
        }

        public override void ShowAccountDetails()
        {
            base.ShowAccountDetails();
            Console.WriteLine($"Interest Rate: {InterestRate}%");
        }
    }
}
