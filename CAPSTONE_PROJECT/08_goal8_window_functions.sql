-- 		QUERY 8.1
SELECT 
  ROW_NUMBER() OVER (ORDER BY COUNT(*) DESC) as row_num,
  RANK() OVER (ORDER BY COUNT(*) DESC) as mem_rank,
  DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) as den_rank,
  m.first_name, m.last_name,
  COUNT(*) as total_loans
FROM members m
JOIN loans l ON m.member_id = l.member_id
GROUP BY m.member_id
ORDER BY total_loans DESC;

-- QUERY 8.2
SELECT f.payment_date, f.fine_amount, SUM(f.fine_amount) OVER (ORDER BY f.payment_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM fines f
WHERE f.paid = TRUE
ORDER BY f.payment_date;

--	QUERY 8.6
WITH daily_loans AS (
    SELECT DATE(loan_date) AS loan_day, COUNT(*) AS loans_that_day
    FROM loans
    GROUP BY DATE(loan_date)
)
SELECT loan_day, loans_that_day,
    ROUND(
        AVG(loans_that_day) OVER (
            ORDER BY loan_day 
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ), 2
    ) AS moving_avg_7_day
FROM daily_loans
ORDER BY loan_day DESC
LIMIT 30;

--		QUERY 8.5
WITH ranked_events AS (
    SELECT 
        m.member_id,
        CONCAT(m.first_name, ' ', m.last_name) AS member_name,
        e.event_name,
        e.event_date,
        ROW_NUMBER() OVER (
            PARTITION BY m.member_id 
            ORDER BY e.event_date
        ) AS rn
    FROM event_registrations er
    JOIN members m ON er.member_id = m.member_id
    JOIN events e ON er.event_id = e.event_id
    WHERE e.event_date >= CURDATE()
)
SELECT 
    member_name,
    event_name AS next_event,
    event_date
FROM ranked_events
WHERE rn = 1
ORDER BY event_date;

-- 		QUERY 8.7
SELECT CONCAT(m.first_name, ' ', m.last_name) AS member_name, f.fine_amount,
ROUND(PERCENT_RANK() OVER (ORDER BY f.fine_amount) * 100, 2) AS percentile_rank
FROM fines f JOIN loans l ON f.loan_id = l.loan_id
JOIN members m ON l.member_id = m.member_id
WHERE f.paid = FALSE
ORDER BY percentile_rank DESC;

--		QUERY 8.8
SELECT m.first_name, m.last_name, l.loan_date,
LAG(l.loan_date) OVER (PARTITION BY m.member_id ORDER BY l.loan_date) as prev_loan,
DATEDIFF(l.loan_date, LAG(l.loan_date) OVER (PARTITION BY m.member_id ORDER BY l.loan_date)) as days_gap
FROM members m
JOIN loans l ON m.member_id = l.member_id
ORDER BY m.member_id, l.loan_date;

