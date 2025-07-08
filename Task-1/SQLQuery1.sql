-- 1. Create EMPLOYEE table
CREATE TABLE EMPLOYEE (
    SSN INT PRIMARY KEY,
    Fname VARCHAR(50) NOT NULL,
    Lname VARCHAR(50) NOT NULL,
    BirthDate DATE NOT NULL,
    Gender CHAR(1) CHECK (Gender IN ('M', 'F')),
    DepartmentID INT NOT NULL,
    SupervisorSSN INT NULL
);

-- 2. Create DEPARTMENT table
CREATE TABLE DEPARTMENT (
    DNUM INT PRIMARY KEY,
    DName VARCHAR(100) NOT NULL UNIQUE,
    ManagerSSN INT NOT NULL,
    ManagerHireDate DATE NOT NULL,
    FOREIGN KEY (ManagerSSN) REFERENCES EMPLOYEE(SSN)
);

-- 3. Alter EMPLOYEE to add FK after DEPARTMENT is created
ALTER TABLE EMPLOYEE
ADD CONSTRAINT FK_Emp_Dept FOREIGN KEY (DepartmentID) REFERENCES DEPARTMENT(DNUM);

-- 4. Add Supervisor FK after EMPLOYEE is created
ALTER TABLE EMPLOYEE
ADD CONSTRAINT FK_Emp_Supervisor FOREIGN KEY (SupervisorSSN) REFERENCES EMPLOYEE(SSN);

-- 5. Create PROJECT table
CREATE TABLE PROJECT (
    PNumber INT PRIMARY KEY,
    Pname VARCHAR(100) NOT NULL,
    Location VARCHAR(100),
    DepartmentID INT NOT NULL,
    FOREIGN KEY (DepartmentID) REFERENCES DEPARTMENT(DNUM)
);

-- 6. Create WORKS_ON table (Many-to-Many between EMPLOYEE and PROJECT)
CREATE TABLE WORKS_ON (
    SSN INT,
    PNumber INT,
    Hours DECIMAL(5,2),
    PRIMARY KEY (SSN, PNumber),
    FOREIGN KEY (SSN) REFERENCES EMPLOYEE(SSN),
    FOREIGN KEY (PNumber) REFERENCES PROJECT(PNumber)
);

-- 7. Create DEPENDENT table
CREATE TABLE DEPENDENT (
    DependentName VARCHAR(50),
    SSN INT,
    Gender CHAR(1) CHECK (Gender IN ('M', 'F')),
    BirthDate DATE,
    PRIMARY KEY (SSN, DependentName),
    FOREIGN KEY (SSN) REFERENCES EMPLOYEE(SSN) ON DELETE CASCADE
);

-- Insert Departments first (empty manager just for now)
INSERT INTO DEPARTMENT (DNUM, DName, ManagerSSN, ManagerHireDate)
VALUES
(1, 'Engineering', 0, '2022-01-01'),
(2, 'HR', 0, '2023-03-15'),
(3, 'Marketing', 0, '2024-06-01');

-- Insert Employees (now with real managers)
INSERT INTO EMPLOYEE (SSN, Fname, Lname, BirthDate, Gender, DepartmentID, SupervisorSSN)
VALUES
(1001, 'Ali', 'Youssef', '1990-02-15', 'M', 1, NULL),
(1002, 'Sara', 'Mohamed', '1992-05-10', 'F', 2, 1001),
(1003, 'Omar', 'Ibrahim', '1988-11-20', 'M', 3, 1001),
(1004, 'Laila', 'Hassan', '1995-07-07', 'F', 1, 1001),
(1005, 'Hany', 'Adel', '1993-09-30', 'M', 2, 1002);

-- Update Departments with real manager SSNs
UPDATE DEPARTMENT SET ManagerSSN = 1001 WHERE DNUM = 1;
UPDATE DEPARTMENT SET ManagerSSN = 1002 WHERE DNUM = 2;
UPDATE DEPARTMENT SET ManagerSSN = 1003 WHERE DNUM = 3;

-- Insert Projects
INSERT INTO PROJECT (PNumber, Pname, Location, DepartmentID)
VALUES
(101, 'Website Revamp', 'Cairo', 1),
(102, 'Recruitment Drive', 'Alex', 2),
(103, 'Ad Campaign', 'Giza', 3);

-- Assign Employees to Projects (WORKS_ON)
INSERT INTO WORKS_ON (SSN, PNumber, Hours)
VALUES
(1001, 101, 20),
(1002, 102, 15),
(1003, 103, 30),
(1004, 101, 25),
(1005, 102, 10);

-- Insert Dependents
INSERT INTO DEPENDENT (DependentName, SSN, Gender, BirthDate)
VALUES
('Nada', 1001, 'F', '2015-06-12'),
('Kareem', 1002, 'M', '2018-03-21'),
('Yara', 1003, 'F', '2012-09-19');

-- Update: change department for employee 1004
UPDATE EMPLOYEE
SET DepartmentID = 3
WHERE SSN = 1004;

-- Delete a dependent (e.g. Kareem)
DELETE FROM DEPENDENT
WHERE SSN = 1002 AND DependentName = 'Kareem';

-- Retrieve all employees working in a specific department (e.g. DNUM = 1)
SELECT *
FROM EMPLOYEE
WHERE DepartmentID = 1;

-- Find all employees and their project assignments with working hours
SELECT 
    E.SSN,
    E.Fname,
    E.Lname,
    P.Pname,
    W.Hours
FROM EMPLOYEE E
JOIN WORKS_ON W ON E.SSN = W.SSN
JOIN PROJECT P ON W.PNumber = P.PNumber;
