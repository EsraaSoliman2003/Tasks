using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OOP_Task3
{
    internal class Bank
    {
        public string? Name { get; set; }
        public int BranchCode { get; set; }
        public List<Customer> Customers { get; set; } = new List<Customer>();

        public Bank(string Name, int BranchCode)
        {
            this.Name = Name;
            this.BranchCode = BranchCode;
        }

        public void ShowSingleReport( Customer customer )
        {
            Console.WriteLine("--------------------------------------------------------");
            Console.WriteLine($"--- Bank Report ---");
            Console.WriteLine($"Bank Name: {Name}");
            Console.WriteLine($"Branch Code: {BranchCode}");
            customer.ShowAccountDetails();
            Console.WriteLine("--------------------------------------------------------");
        }

    }


}
