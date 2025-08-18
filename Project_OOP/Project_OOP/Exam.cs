using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Project_OOP
{
    internal class Exam
    {
        public string Title { get; set; }
        public Courses Course { get; set; }
        public List<Questions> Questions { get; set; } = new ();
        public bool Started { get; set; }


        public void AddQuestion(Questions q)
        {
            if (Started) return;
            int currentMarks = Questions.Sum(x => x.Mark);
            if (currentMarks + q.Mark <= Course.MaxDegree)
            {
                Questions.Add(q);
            }
        }

        public void removeQuestionChoice(Questions q)
        {
            if (Started) return;
            Questions.Remove(q);
        }

        public void StartExam() => Started = true;

        public Exam DuplicateTo(Courses newCourse)
        {
            return new Exam
            {
                Title = this.Title,
                Course = newCourse,
                Questions = this.Questions
            };
        }

    }
}
