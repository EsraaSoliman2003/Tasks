-- Create Department table
CREATE TABLE Department (
    DeptID INT PRIMARY KEY IDENTITY(1,1),
    DeptName NVARCHAR(100) NOT NULL UNIQUE,
    ManagerID INT -- Will be set as a Foreign Key after creating Employee table
);

-- Create Employee table
CREATE TABLE Employee (
    EmpID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('M', 'F')),
    BirthDate DATE NOT NULL,
    NationalID CHAR(14) NOT NULL UNIQUE,
    HireDate DATE NOT NULL DEFAULT GETDATE(),
    DeptID INT NOT NULL,
    Salary DECIMAL(10,2) CHECK (Salary > 0)
);

-- Add Foreign Key between Employee and Department
ALTER TABLE Employee
ADD CONSTRAINT FK_Employee_Department
FOREIGN KEY (DeptID)
REFERENCES Department(DeptID)
ON DELETE NO ACTION
ON UPDATE CASCADE;

-- Add Foreign Key between Department and its Manager (Employee)
ALTER TABLE Department
ADD CONSTRAINT FK_Department_Manager
FOREIGN KEY (ManagerID)
REFERENCES Employee(EmpID)
ON DELETE SET NULL
ON UPDATE CASCADE;

-- Create Project table
CREATE TABLE Project (
    ProjectID INT PRIMARY KEY IDENTITY(1,1),
    ProjectName NVARCHAR(100) NOT NULL UNIQUE,
    StartDate DATE NOT NULL,
    DeptID INT NOT NULL
);

-- Add Foreign Key between Project and Department
ALTER TABLE Project
ADD CONSTRAINT FK_Project_Department
FOREIGN KEY (DeptID)
REFERENCES Department(DeptID)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- Create junction table Employee_Project for M:N relation
CREATE TABLE Employee_Project (
    EmpID INT,
    ProjectID INT,
    AssignedDate DATE DEFAULT GETDATE(),
    PRIMARY KEY (EmpID, ProjectID),
    FOREIGN KEY (EmpID) REFERENCES Employee(EmpID),
    FOREIGN KEY (ProjectID) REFERENCES Project(ProjectID)
);

-- Create Dependent table
CREATE TABLE Dependent (
    DepID INT PRIMARY KEY IDENTITY(1,1),
    DepName NVARCHAR(100) NOT NULL,
    Gender CHAR(1) NOT NULL CHECK (Gender IN ('M', 'F')),
    Relation NVARCHAR(50) NOT NULL,
    EmpID INT NOT NULL
);

-- Add Foreign Key with ON DELETE CASCADE (delete dependents when employee is deleted)
ALTER TABLE Dependent
ADD CONSTRAINT FK_Dependent_Employee
FOREIGN KEY (EmpID)
REFERENCES Employee(EmpID)
ON DELETE CASCADE
ON UPDATE CASCADE;

-- Add a new column to Employee table
ALTER TABLE Employee
ADD Email NVARCHAR(100);

-- Modify column data type (e.g. increase LastName length)
ALTER TABLE Employee
ALTER COLUMN LastName NVARCHAR(100);

-- Insert sample departments
INSERT INTO Department (DeptName) VALUES
('Human Resources'),
('IT Department'),
('Finance');

-- Insert sample employees
INSERT INTO Employee (FirstName, LastName, Gender, BirthDate, NationalID, HireDate, DeptID, Salary)
VALUES
('Ahmed', 'Ali', 'M', '1990-05-01', '12345678901234', '2020-01-15', 1, 8000.00),
('Sara', 'Ibrahim', 'F', '1992-03-20', '98765432109876', '2021-04-01', 2, 9500.00);

-- Assign manager to a department (e.g., Ahmed is manager of HR)
UPDATE Department SET ManagerID = 1 WHERE DeptID = 1;

-- Insert sample projects
INSERT INTO Project (ProjectName, StartDate, DeptID)
VALUES 
('Employee Portal', '2023-01-01', 2),
('Payroll System', '2023-05-01', 3);

-- Assign employees to projects
INSERT INTO Employee_Project (EmpID, ProjectID) VALUES
(1, 1),
(2, 1),
(2, 2);

-- Insert dependents
INSERT INTO Dependent (DepName, Gender, Relation, EmpID)
VALUES
('Omar', 'M', 'Son', 1),
('Layla', 'F', 'Daughter', 2);



