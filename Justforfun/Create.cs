using System;
using System.Collections.Generic;

// Base class for all employees
public abstract class Employee
{
    public string FirstName { get; }
    public string LastName { get; }
    public long SocialSecurityNumber { get; }

    // Constructor
    public Employee(string firstName, string lastName, long socialSecurityNumber)
    {
        FirstName = firstName;
        LastName = lastName;
        SocialSecurityNumber = socialSecurityNumber;
    }

    // Abstract method to be overridden by derived classes
    public abstract decimal Earnings();

    // Virtual method to provide a string representation
    public override string ToString() => 
        $"{FirstName} {LastName}\nSocial Security Number: {SocialSecurityNumber}";
}

// Derived class for salaried employees
public class SalariedEmployee : Employee
{
    private decimal weeklySalary;

    public decimal WeeklySalary
    {
        get => weeklySalary;
        set
        {
            if (value < 0) // Validation
                throw new ArgumentOutOfRangeException(nameof(value), value, "Weekly salary must be >= 0");
            weeklySalary = value;
        }
    }

    // Constructor
    public SalariedEmployee(string firstName, string lastName, long socialSecurityNumber, decimal weeklySalary)
        : base(firstName, lastName, socialSecurityNumber)
    {
        WeeklySalary = weeklySalary;
    }

    // Implementation of abstract method
    public override decimal Earnings() => WeeklySalary;

    // Override ToString() to include salary details
    public override string ToString() =>
        $"Salaried Employee: {base.ToString()}\nWeekly Salary: {WeeklySalary:C}";
}

// Derived class for commission employees
public class CommissionEmployee : Employee
{
    private decimal grossSales;
    private decimal commissionRate;

    public decimal GrossSales
    {
        get => grossSales;
        set
        {
            if (value < 0)
                throw new ArgumentOutOfRangeException(nameof(value), value, "Gross sales must be >= 0");
            grossSales = value;
        }
    }

    public decimal CommissionRate
    {
        get => commissionRate;
        set
        {
            if (value <= 0 || value >= 1) // Rate must be between 0 and 1 (exclusive)
                throw new ArgumentOutOfRangeException(nameof(value), value, "Commission rate must be > 0 and < 1");
            commissionRate = value;
        }
    }

    // Constructor
    public CommissionEmployee(string firstName, string lastName, long socialSecurityNumber, decimal grossSales, decimal commissionRate)
        : base(firstName, lastName, socialSecurityNumber)
    {
        GrossSales = grossSales;
        CommissionRate = commissionRate;
    }

    // Implementation of abstract method
    public override decimal Earnings() => GrossSales * CommissionRate;

    // Override ToString() to include commission details
    public override string ToString() =>
        $"Commission Employee: {base.ToString()}\nGross Sales: {GrossSales:C}\nCommission Rate: {CommissionRate:P0}";
}

// Main application class
public class PayrollSystemTest
{
    public static void Main()
    {
        // Create a list of employees using the base class type (polymorphism)
        List<Employee> employees = new List<Employee>
        {
            new SalariedEmployee("John", "Doe", 123456789, 800.00M),
            new CommissionEmployee("Jane", "Smith", 987654321, 10000.00M, 0.10M),
            new SalariedEmployee("Bob", "Johnson", 456123789, 1200.50M)
        };

        Console.WriteLine("Employee Payroll Report:\n");

        foreach (var employee in employees)
        {
            // Call ToString() and Earnings() polymorphically
            Console.WriteLine(employee.ToString());
            Console.WriteLine($"Earned: {employee.Earnings():C}");
            Console.WriteLine(new string('-', 30)); // Separator
        }
    }
}
