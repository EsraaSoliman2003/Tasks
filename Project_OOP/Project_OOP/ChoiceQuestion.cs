using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Project_OOP
{
    internal class ChoiceQuestion : Questions
    {
        public List<string> Options { get; set; } = new();
        public string? Solution { get; set; }
        public override bool CheckAnswer(string answer) => Solution == answer;

    }
}
