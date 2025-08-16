using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml.Linq;

namespace OOP_Task3
{
    internal class Customer
    {
        static int staticID = 0;
        public int Id { get; set; }
        public string? FullName { get; set; }
        public int NationalID { get; set; }
        public DateOnly BirthDate { get; set; }
        public List<Account> Accounts { get; set; }

        public Customer(string FullName, int NationalID, DateOnly BirthDate)
        {
            staticID++;
            this.Id = staticID;
            this.FullName = FullName;
            this.NationalID = NationalID;
            this.BirthDate = BirthDate;
            this.Accounts = new List<Account>();
        }

        public decimal Balance => Accounts.Sum(a => a.Balance);

        public void updateInfo(string FullName, DateOnly BirthDate)
        {
            this.FullName = FullName;
            this.BirthDate = BirthDate;
            Console.WriteLine("done");
        }

        public virtual void ShowAccountDetails()
        {
            Console.WriteLine($"Personal Id: {Id}");
            Console.WriteLine($"Bank FullName: {FullName}");
            Console.WriteLine($"Bank NationalID: {NationalID}");
            Console.WriteLine($"Bank BirthDate: {BirthDate}");
            Console.WriteLine($"Total Balance: {Balance}");
            foreach (var account in Accounts)
            {
                Console.WriteLine($"------------------- Account -------------------");
                account.ShowAccountDetails();
            }

        }
        public bool CanDelete() => Balance == 0;

    }


}
