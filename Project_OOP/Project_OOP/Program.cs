// Create course
using Project_OOP;

var course = new Courses { Title = "OOP",
    Description = "Object Oriented Programming",MaxDegree = 100 };

// Create student
var student1 = new Students { Id = 1, Name = "Esraa Soliman", Email = "esraa@test.com" };
student1.Courses.Add(course);
var student2 = new Students { Id = 2, Name = "Aya Ashraf", Email = "aya@test.com" };
student2.Courses.Add(course);

// Create instructor
var instructor = new Instructors { Id = 1, Name = "Karim Essam",
    Specialization = "Software Engineering" };
instructor.Courses.Add(course);

// Create exam
var exam = new Exam { Title = "OOP Final", Course = course };

exam.AddQuestion(new TorFQuestion { Text = "C# supports OOP?",
    Solution = true, Mark = 20 });
exam.AddQuestion(new ChoiceQuestion
{
    Text = "Which is a reference type?",
    Options = new List<string> { "int", "string", "bool" },
    Solution = "string",
    Mark = 30
});
exam.AddQuestion(new EssayQuestion { Text = "Explain polymorphism", Mark = 50 });

// Take exam
var result1 = new ExamResult {
    Exam = exam,
    Student = student1,
};
result1.TakeExam([ "true", "string", "bla bla bla" ]);

var result2 = new ExamResult
{
    Exam = exam,
    Student = student2,
};
result2.TakeExam(["true", "int", "bla bla bla"]);

// Report
Console.WriteLine("---- Report ----");
Console.WriteLine($"Exam: {result1.Exam.Title}");
Console.WriteLine($"Student: {result1.Student.Name}");
Console.WriteLine($"Course: {result1.Exam.Course.Title}");
Console.WriteLine($"Score: {result1.Score}");
Console.WriteLine($"Pass: {result1.Passed}");

Console.WriteLine("---------------------------------------");

// Compare
ExamResult.Compare(result1, result2);