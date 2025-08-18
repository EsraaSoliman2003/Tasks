using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Project_OOP
{
    internal class TorFQuestion : Questions
    {
        public bool Solution { get; set; }
        public override bool CheckAnswer(string answer) =>
            Solution == bool.Parse(answer);

    }
}
