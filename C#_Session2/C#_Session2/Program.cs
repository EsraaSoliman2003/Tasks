// See https://aka.ms/new-console-template for more information
Console.WriteLine("Hello!");

Console.WriteLine("Input the first number: ");
int num1 = int.Parse(Console.ReadLine());

Console.WriteLine("Input the second number: ");
int num2 = int.Parse(Console.ReadLine());

Console.WriteLine("What do you want to do with those numbers?\r\n[A]dd\r\n[S]ubtract\r\n[M]ultiply\r\n");
string choice = Console.ReadLine();

if(choice == "A" ||  choice == "a")
{
    Console.WriteLine($"{num1} + {num2} = {num1 + num2}");
}
else if(choice == "S" || choice == "s")
{
    Console.WriteLine($"{num1} + {num2} = {num1 - num2}");
}
else if (choice == "M" || choice == "m")
{
    Console.WriteLine($"{num1} + {num2} = {num1 * num2}");
}
else
{
    Console.WriteLine("Invalid option");
}

Console.WriteLine("Press any key to close");
Console.ReadKey();





