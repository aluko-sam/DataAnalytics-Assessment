SELECT
    p.id AS plan_id,                                  -- Plan identifier
    p.owner_id,                                       -- Owner of the plan
    CASE 
        WHEN p.is_fixed_investment = 1 THEN 'Investment'  -- Label type as 'Investment' if fixed investment
        WHEN p.is_regular_savings = 1 THEN 'Savings'       -- Label type as 'Savings' if regular savings
        ELSE 'Other'                                        -- Default fallback label
    END AS type,
    MAX(s.transaction_date) AS last_transaction_date,      -- Most recent transaction date for the plan
    DATEDIFF(CURRENT_DATE, MAX(s.transaction_date)) AS inactivity_days  -- Days since last transaction
FROM
    plans_plan p
LEFT JOIN
    savings_savingsaccount s ON p.id = s.plan_id            -- Join to get transactions related to the plan
WHERE
    (p.is_fixed_investment = 1 OR p.is_regular_savings = 1) -- Filter only investment or savings plans
    AND p.is_deleted = 0                                     -- Only consider active (not deleted) plans
GROUP BY
    p.id, p.owner_id, p.is_fixed_investment, p.is_regular_savings
HAVING
    MAX(s.transaction_date) IS NULL                           -- Include plans with no transactions at all
    OR DATEDIFF(CURRENT_DATE, MAX(s.transaction_date)) > 365 -- Or with last transaction older than 1 year
;
