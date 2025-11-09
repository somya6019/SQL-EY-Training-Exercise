-- 		QUERY 6.1
SELECT CONCAT(m.first_name, ' ', m.last_name) AS member_name, SUM(f.fine_amount) AS total_unpaid_fines,
COUNT(f.fine_id) AS number_of_fines
FROM members m JOIN loans l ON m.member_id = l.member_id
JOIN fines f ON l.loan_id = f.loan_id
WHERE f.paid = FALSE
GROUP BY m.member_id, m.first_name, m.last_name
HAVING total_unpaid_fines > (
    SELECT AVG(member_total)
    FROM (
        SELECT SUM(f2.fine_amount) AS member_total
        FROM fines f2
        JOIN loans l2 ON f2.loan_id = l2.loan_id
        WHERE f2.paid = FALSE
        GROUP BY l2.member_id
    ) AS avg_fines
)
ORDER BY total_unpaid_fines DESC;

--		QUERY 6.2
SELECT b.title, a.author_name,
COUNT(l.loan_id) AS total_loans,
(
	SELECT AVG(loans_per_book)
	FROM (
		SELECT COUNT(l2.loan_id) AS loans_per_book
		FROM books b2 JOIN book_copies bc2 ON b2.book_id = bc2.book_id
		JOIN loans l2 ON bc2.copy_id = l2.copy_id
		GROUP BY b2.book_id
	) AS avg_data
) AS avg_loans_per_book
FROM books b JOIN authors a ON b.author_id = a.author_id
JOIN book_copies bc ON b.book_id = bc.book_id
JOIN loans l ON bc.copy_id = l.copy_id
GROUP BY b.book_id, b.title, a.author_name
HAVING total_loans > (
    SELECT AVG(loans_per_book)
    FROM (
        SELECT COUNT(l3.loan_id) AS loans_per_book
        FROM books b3
        JOIN book_copies bc3 ON b3.book_id = bc3.book_id
        JOIN loans l3 ON bc3.copy_id = l3.copy_id
        GROUP BY b3.book_id
    ) AS avg_sub
)
ORDER BY total_loans DESC;

--		QUERY 6.3
WITH 
loan_counts AS (
    SELECT 
        m.member_id,
        COUNT(l.loan_id) AS total_loans
    FROM members m
    LEFT JOIN loans l ON m.member_id = l.member_id
    GROUP BY m.member_id
),

fine_totals AS (
    SELECT 
        l.member_id,
        COALESCE(SUM(f.fine_amount), 0) AS total_fines
    FROM loans l
    LEFT JOIN fines f ON l.loan_id = f.loan_id
    GROUP BY l.member_id
),

active_loans AS (
    SELECT 
        m.member_id,
        COUNT(l.loan_id) AS active_loans
    FROM members m
    JOIN loans l ON m.member_id = l.member_id
    WHERE l.status = 'active'
    GROUP BY m.member_id
)

-- Main query: Combine all CTEs
SELECT CONCAT(m.first_name, ' ', m.last_name) AS member_name,
COALESCE(lc.total_loans, 0) AS total_loans,
COALESCE(al.active_loans, 0) AS active_loans,
COALESCE(ft.total_fines, 0) AS total_fines,
m.status
FROM members m LEFT JOIN loan_counts lc ON m.member_id = lc.member_id
LEFT JOIN active_loans al ON m.member_id = al.member_id
LEFT JOIN fine_totals ft ON m.member_id = ft.member_id
ORDER BY total_loans DESC;

--		QUERY 6.4
SELECT b.title, a.author_name, b.genre, b.total_copies, b.publication_year
FROM books b JOIN authors a ON b.author_id = a.author_id
WHERE NOT EXISTS (
    SELECT 1
    FROM book_copies bc
    JOIN loans l ON bc.copy_id = l.copy_id
    WHERE bc.book_id = b.book_id
)
ORDER BY b.publication_year ASC;

-- 		QUERY 6.5
SELECT CONCAT(m.first_name, ' ', m.last_name) AS member_name, COUNT(er.event_id) AS events_attended
FROM members m JOIN event_registrations er ON m.member_id = er.member_id
JOIN events e ON er.event_id = e.event_id
WHERE e.event_type = 'book_club'
GROUP BY m.member_id, m.first_name, m.last_name
HAVING COUNT(er.event_id) = (
    SELECT COUNT(*) 
    FROM events  
    WHERE event_type = 'book_club'
)
ORDER BY member_name;

--		QUERY 6.7
SELECT b.title, a.author_name,
(
SELECT MAX(l.loan_date)
FROM loans l
JOIN book_copies bc2 ON l.copy_id = bc2.copy_id
WHERE bc2.book_id = b.book_id
) AS most_recent_loan_date,
(
SELECT CONCAT(m.first_name, ' ', m.last_name)
FROM loans l JOIN book_copies bc3 ON l.copy_id = bc3.copy_id
JOIN members m ON l.member_id = m.member_id
WHERE bc3.book_id = b.book_id
ORDER BY l.loan_date DESC
LIMIT 1
) AS borrower_name
FROM books b
JOIN authors a ON b.author_id = a.author_id
WHERE EXISTS (
SELECT 1 
FROM loans l JOIN book_copies bc ON l.copy_id = bc.copy_id
WHERE bc.book_id = b.book_id
)
ORDER BY most_recent_loan_date DESC;

