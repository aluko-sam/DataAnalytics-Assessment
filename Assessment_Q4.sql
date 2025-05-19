-- Step 1: Define a Common Table Expression (CTE) to compute basic customer metrics
WITH customer_metrics AS (
    SELECT
        u.id AS customer_id,  -- Unique identifier for the customer
        CONCAT(u.first_name, ' ', u.last_name) AS name,  -- Full name by concatenating first and last names
        TIMESTAMPDIFF(MONTH, u.date_joined, CURRENT_DATE) AS tenure_months,  -- Account tenure in months
        COUNT(s.id) AS total_transactions  -- Total number of transactions by the customer
    FROM
        users_customuser u
    LEFT JOIN
        savings_savingsaccount s ON u.id = s.owner_id  -- Join with savings transactions to count inflows
    GROUP BY
        u.id, u.first_name, u.last_name, u.date_joined  -- Group by customer to aggregate transaction data
)

-- Step 2: Use the metrics to estimate CLV and present the final output
SELECT
    customer_id,              -- Customer ID
    name,                     -- Customer full name
    tenure_months,            -- Duration the account has been active (in months)
    total_transactions,       -- Total number of transactions performed
    ROUND(
        (total_transactions / NULLIF(tenure_months, 0)) * 12 * 0.001,  -- Simplified CLV formula
        2
    ) AS estimated_clv        -- Estimated Customer Lifetime Value, rounded to 2 decimal places
FROM
    customer_metrics
ORDER BY
    estimated_clv DESC;       -- Sort results by highest CLV first
