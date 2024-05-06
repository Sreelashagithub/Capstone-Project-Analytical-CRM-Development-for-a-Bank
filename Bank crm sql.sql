CREATE DATABASE NEW_PROJECT;
show databases;
use new_project;
show tables;
select * from activecustomer;
show tables;
select * from bank_churn;
select * from customerinfo;
select * from geography;
select * from exitcustomer;
select * from gender;
select * from creditcard;


-- 2. Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year. (SQL)    //
 SELECT ï»¿CustomerId, surname, estimatedsalary
FROM customerinfo 
WHERE EXTRACT(QUARTER FROM 'BankDOJ') = 4
ORDER BY estimatedsalary DESC
LIMIT 5;

-- Objective qs 3. Calculate the average number of products used by customers who have a credit card. (SQL)

SELECT AVG(NumOfProducts) AS AvgNoProducts
FROM bank_churn
WHERE HasCrCard = 1;


    -- Objective qs 5. Compare the average credit score of customers who have exited and those who remain. (SQL)

SELECT AVG(CASE WHEN Exited = 1 THEN CreditScore END) AS AverageCreditScoreExited,      
AVG(CASE WHEN Exited = 0 THEN CreditScore END) AS AverageCreditScoreremain
FROM bank_churn;

-- Objective qs 6. Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? (SQL)
SELECT 
    g.GenderCategory AS Gender,
    AVG(c.EstimatedSalary) AS AverageSalary,
    COUNT(DISTINCT bc.ï»¿CustomerId) AS ActiveAccounts
FROM 
    customerinfo c
JOIN 
    gender g ON c.GenderID = g.ï»¿GenderID
JOIN 
    bank_churn bc ON c.ï»¿CustomerId = bc.ï»¿CustomerId
JOIN 
    activecustomer a ON bc.ï»¿CustomerId = a.ï»¿ActiveID
WHERE 
    a.ActiveCategory = 'Active Member'
GROUP BY 
    g.GenderCategory;

--    Objective qs 7. Segment the customers based on their credit score and identify the segment with the highest exit rate. (SQL)

WITH credit_score_segments AS (
    SELECT
        CASE
            WHEN CreditScore <= 600 THEN 'Low'
            WHEN CreditScore <= 700 THEN 'Medium'
            ELSE 'High'
        END AS credit_score_segment,
        Exited
    FROM
        bank_churn
),
segment_exit_rates AS (
    SELECT
        credit_score_segment,
        AVG(Exited) AS exit_rate
    FROM
        credit_score_segments
    GROUP BY
        credit_score_segment
)
SELECT
    *
FROM
    segment_exit_rates
WHERE
    exit_rate = (SELECT MAX(exit_rate) FROM segment_exit_rates);
    
    
      --    Objective qs 8. Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. (SQL)
 
   SELECT g.GeographyLocation,
    COUNT(ci.ï»¿CustomerId) AS Num_Active_Customers
FROM customerinfo ci
JOIN geography g ON ci.GeographyID = g.ï»¿GeographyID
JOIN bank_churn bc ON ci.ï»¿CustomerId = bc.ï»¿CustomerId
WHERE bc.Tenure > 5
GROUP BY g.GeographyLocation
ORDER BY Num_Active_Customers DESC;

--    Objective qs  11.	Examine the trend of customer joining over time and identify any seasonal patterns (yearly or monthly). Prepare the data through SQL and then visualize it.

    SELECT YEAR(`Bank DOJ`) AS Years,COUNT(ï»¿CustomerId) AS CustomersCount
FROM CustomerInfo
GROUP BY Years
ORDER BY CustomersCount DESC;
    
    --     Objective qs 15. Using SQL, write a query to find out the gender wise average income of male and female in each geography id. Also rank the gender according to the average value. (SQL)

WITH gender_avg_income AS (
    SELECT
        GeographyID,
        genderID,
        ROUND(AVG(estimatedsalary),2) AS avg_income,
        RANK() OVER (PARTITION BY GeographyID ORDER BY AVG(estimatedsalary) DESC) AS gender_rank
    FROM
        customerinfo
    GROUP BY
        GeographyID,
        genderID
)
SELECT
    GeographyID,
    genderID,
    avg_income,
    gender_rank
FROM
    gender_avg_income;
    
     --     Objective qs 16. Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).

SELECT
    CASE
        WHEN ci.Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN ci.Age BETWEEN 31 AND 50 THEN '31-50'
        WHEN ci.Age > 50 THEN '50+'
        ELSE 'Unknown'
    END AS AgeBracket,
    AVG(bc.Tenure) AS AverageTenure
FROM
    bank_churn bc
JOIN
    customerinfo ci ON bc.ï»¿CustomerId = ci.ï»¿CustomerId
WHERE
    bc.Exited = 1
GROUP BY
    AgeBracket
ORDER BY
    AgeBracket;
    
    --   19. Rank each bucket of credit score as per the number of customers who have churned the bank.
    Select CreditScore,
    count(*) AS Churned_Customers,
    rank() Over (order by count(*) desc) AS score_Rank
    from bank_churn
    where Exited = 1
    group by creditscore;
    
    
    
    --     23. Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL.

 SELECT bc.*,       
(SELECT ec.ExitCategory FROM exitcustomer ec WHERE ec.ï»¿ExitID = bc.Exited) AS ExitCategory
FROM bank_churn bc; 

 --     25. Write the query to get the customer IDs, their last name, and whether they are active or not for the customers whose surname ends with “on”


select ï»¿CustomerId,Surname as lastname,
case when IsActiveMember = 1 then 'Active'
else 'Inactive'
end as Active_Status
from
customerinfo join bank_churn using (ï»¿CustomerId)
where
surname like '%on';


   
   
   
   
--  subjective question   9. Utilize SQL queries to segment customers based on demographics and account details.
-- Segment customers based on age groups:
SELECT
    CASE
        WHEN age BETWEEN 18 AND 30 THEN '18-30'
        WHEN age BETWEEN 31 AND 40 THEN '31-40'
        WHEN age BETWEEN 41 AND 50 THEN '41-50'
        ELSE '51+'
    END AS age_group, COUNT(*) AS num_customers
FROM customerinfo
GROUP BY age_group;
--     Segment customers based on gender and geography:
SELECT GenderID, GeographyID, COUNT(*) AS num_customers
FROM customerinfo
GROUP BY GenderID, GeographyID
ORDER BY GeographyID;

-- Segment customers based on account details:
SELECT Exited, Has_creditcard, IsActiveMember, COUNT(*) AS num_customers
FROM bank_churn
GROUP BY Exited, Has_creditcard, IsActiveMember;

-- Segment customers based on gender, geography, and churn status:
SELECT GenderID, GeographyID, Exited, COUNT(*) AS num_customers
FROM customerinfo ci
JOIN bank_churn bc ON ï»¿CustomerId = ï»¿CustomerId
GROUP BY GenderID, GeographyID, Exited;


  
  
--  subjective question  14. In the "Bank_curn" table how can you modify the name of the "HasCrCard" column to "Has_creditcard"?
ALTER TABLE Bank_Churn
RENAME COLUMN Has_creditcard TO Has_creditcard;

 

