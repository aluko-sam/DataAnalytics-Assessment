SELECT
    p.owner_id,  
    CONCAT(u.first_name, ' ', u.last_name) AS name,    -- Concatenate first_name and last_name as full name
    SUM(CASE WHEN p.is_regular_savings = 1 THEN 1 ELSE 0 END) AS savings_count,   -- Count savings plans
    SUM(CASE WHEN p.is_fixed_investment = 1 THEN 1 ELSE 0 END) AS investment_count, -- Count investment plans
    ROUND(COALESCE(SUM(s.amount), 0), 2) AS total_deposits      -- Total deposits from savings accounts, rounded to 2 decimals
FROM
    plans_plan p
INNER JOIN
    users_customuser u ON p.owner_id = u.id           -- Join to get user info
LEFT JOIN
    savings_savingsaccount s ON p.id = s.plan_id      -- Join to get savings amounts
WHERE
    p.is_deleted = 0                                  -- Only active plans
GROUP BY
    p.owner_id, u.first_name, u.last_name
HAVING
    savings_count > 0                                 -- At least one savings plan
    AND investment_count = 1                          -- Exactly one investment plan
ORDER BY
    total_deposits DESC;
