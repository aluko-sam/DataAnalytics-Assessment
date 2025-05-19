-- Step 1: Calculate the average number of transactions per month for each user
WITH savings_per_user AS (
    SELECT 
        owner_id,
        ROUND(AVG(monthly_txn_count), 2) AS avg_txn_per_month  -- Calculate average monthly transactions, rounded to 2 decimal places
    FROM (
        SELECT 
            owner_id,
            EXTRACT(YEAR FROM transaction_date) AS year,   -- Extract year from transaction date
            EXTRACT(MONTH FROM transaction_date) AS month, -- Extract month from transaction date
            COUNT(*) AS monthly_txn_count                  -- Count transactions per user per month
        FROM savings_savingsaccount
        GROUP BY owner_id, EXTRACT(YEAR FROM transaction_date), EXTRACT(MONTH FROM transaction_date)
    ) AS monthly_txns
    GROUP BY owner_id
)

-- Step 2: Categorize users based on their average transaction frequency to get the summary statistics
SELECT 
    CASE 
        WHEN avg_txn_per_month >= 10 THEN 'High Frequency'                          -- More than or equal to 10 transactions/month
        WHEN avg_txn_per_month >= 3 AND avg_txn_per_month <= 9 THEN 'Medium Frequency' -- Between 3 and 9 transactions/month
        ELSE 'Low Frequency'                                                       -- Less than 3 transactions/month
    END AS frequency_category,
    
    COUNT(*) AS customer_count,                        -- Number of customers in each frequency category
    ROUND(AVG(avg_txn_per_month), 2) AS average_transactions_per_month -- Average transactions per user in each category
FROM savings_per_user
GROUP BY frequency_category;
