using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Project_OOP
{
    public abstract class Questions
    {
        public string? Text { get; set; }
        public int Mark { get; set; }
        public abstract bool CheckAnswer(string answer);

    }
}
