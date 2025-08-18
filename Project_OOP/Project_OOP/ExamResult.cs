using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Project_OOP
{
    internal class ExamResult
    {
        public Exam Exam { get; set; }
        public Students Student { get; set; }
        public int Score { get; set; }
        public bool Passed => Score >= Exam.Course.MaxDegree / 2;

        public void TakeExam(List<string> answers)
        {
            Exam.StartExam();
            int score = 0;

            for(int i = 0; i < Exam.Questions.Count; i++)
            {
                var question = Exam.Questions[i];
                if (question.CheckAnswer(answers[i]))
                    score += question.Mark;
            }

            Score = score;
        }

        public static void Compare(ExamResult r1, ExamResult r2)
        {
            Console.WriteLine($"{r1.Student.Name}: {r1.Score}");
            Console.WriteLine($"{r2.Student.Name}: {r2.Score}");
            Console.WriteLine(
                r1.Score > r2.Score ?
                $"{r1.Student.Name} wins" :
                r2.Score > r1.Score ?
                $"{r2.Student.Name} wins" :
                "Equal scores"
            );
        }
    }
}
