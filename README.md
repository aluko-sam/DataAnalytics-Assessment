ASSESSMENT_Q1

Objective:
Identify customers who have both a savings and an investment plan, calculate their total savings deposits, and sort them by deposit value to find high-value customers.

Tables Used:

	plans_plan: Contains details about each financial plan, including type indicators and deletion status.
	savings_savingsaccount: Contains individual savings transactions, including deposit amounts.
	users_customuser: Stores user profile data such as first name and last name.

Approach:

1 Identify Plan Types: 
	Used the plans_plan table to distinguish savings plans (is_regular_savings = 1) and investment plans (is_fixed_investment = 1). Filtered out any deleted plans using is_deleted = 0.

2 Group by Customer:
	Grouped data by owner_id to get aggregate counts of each plan type per customer using conditional SUM:
SUM(CASE WHEN pl.is_regular_savings = 1 THEN 1 ELSE 0 END) AS savings_count,
SUM(CASE WHEN pl.is_fixed_investment = 1 THEN 1 ELSE 0 END) AS investment_count
Join Deposits Data:
Linked the savings_savingsaccount table to pull in total_deposit amounts for each user using a LEFT JOIN and aggregated using SUM.

3 Join User Information:
	Merged with the users_customuser table to fetch user names and used CONCAT(first_name, ' ', last_name) to format the full name.

4 Apply Filters:
	Used HAVING clause to ensure the customer has at least 1 savings plan and exactly 1 investment plan.

------------------------------------------------------------------------------------------------------------------------------------------

ASSESSMENT_Q2

Objective:
The goal is to analyze customer transaction behavior by calculating the average number of transactions per month per customer and categorizing them into segments:
-High Frequency: ≥ 10 transactions/month
-Medium Frequency: 3–9 transactions/month
-Low Frequency: ≤ 2 transactions/month

Tables Used:

	savings_savingsaccount: Contains transaction details, including owner_id and transaction_date.
	users_customuser (referenced indirectly if needed): May be used to enrich user data such as names or signup dates.

Approach:

1 Monthly Transaction Count per User:
	Extracted YEAR and MONTH from the transaction_date in savings_savingsaccount.
	Counted how many transactions each user had per month using COUNT(*).
	Grouped by owner_id, YEAR, and MONTH.

2 Average Monthly Transactions per User:
	Took the result from Step 1 and calculated the average number of monthly transactions per user using AVG(monthly_txn_count).
	Rounded the result to 2 decimal places for clarity.

3 Categorization by Frequency:
	Categorized users into three groups based on their avg_txn_per_month using CASE WHEN.
	Counted how many users fall into each frequency group.
	Also calculated the average transaction rate within each category for deeper insights.

Challenges and How I Resolved Them:
	The only major challenge i had was getting the monthly-level and year-level aggregations and accurately aggregating them without using too complex queries which i did by: Using both EXTRACT(YEAR...) and EXTRACT(MONTH...) to correctly bucket monthly transactions after which i averaged the monthly counts after aggregation, which normalized behavior over time.
       
------------------------------------------------------------------------------------------------------------------------------------------

ASSESSMENT_Q3

Objective:
The operations team requested a report on active savings or investment accounts that have not had any inflow transactions in the past 365 days. This allows them to identify dormant accounts that might need customer engagement or intervention.

Table Used:

	plans_plan: Contains metadata about accounts (type, status).
	savings_savingsaccount: Contains the actual transactions associated with each plan.

Approach:

Step-by-Step Logic:
	Filter Plans: I selected only active plans (is_deleted = 0) and those that are either fixed investment or regular savings.
	Join Transaction Table: Used a LEFT JOIN to get the last transaction date for each plan (from savings_savingsaccount) via plan_id.
	Aggregation: Calculated the most recent transaction date for each plan using MAX(s.transaction_date).
	Calculate Inactivity: Computed inactivity_days as the difference between CURRENT_DATE and the most recent transaction date.
	Final Filter Using HAVING:
 
		Included plans with no transactions at all (MAX(...) IS NULL).
		Or those where the last transaction was over 365 days ago.

Challenges and How I Resolved Them:
	major challenge was figuring out what to do with the nulls, do i add them or not? well from a business perspective, the goal of this analysis is to identify inactive or dormant accounts — not just those that stopped transacting, but also those that were opened but never funded or used. A NULL transaction_date indicates exactly that.

------------------------------------------------------------------------------------------------------------------------------------------

ASSESSMENT_Q4

Objective:
Customer Lifetime Value (CLV) Estimation
Marketing wants to estimate how valuable each customer is by combining account tenure and transaction volume. This helps prioritize users for marketing and retention strategies.

Tables Used:

	users_customuser: To get customer details and account creation date.
	savings_savingsaccount: To count transactions per customer.

 Approach:
 
1 Data Aggregation
	I created a CTE named customer_metrics to calculate:
		tenure_months: Time since signup using TIMESTAMPDIFF
		total_transactions: Count of transaction records per customer

2 CLV Calculation
	I applied the given formula:
		CLV = (total_transactions / tenure_months) * 12 * profit_per_transaction
		where profit_per_transaction = 0.001 (i.e., 0.1%).
		I wrapped the tenure_months with NULLIF(..., 0) to avoid division-by-zero errors.
		after which i sorted the results in descending order of estimated_clv.
