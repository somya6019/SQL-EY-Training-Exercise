USE city_library;

--		QUERY 4.1
SELECT membership_type, COUNT(member_id) AS member_count, ROUND(COUNT(*) * 100/(SELECT COUNT(*) FROM members)) AS percentage
FROM members
GROUP BY membership_type
ORDER BY member_count DESC;

--		QUERY 4.2
SELECT 
    CASE 
        WHEN paid = TRUE THEN 'Paid'
        WHEN paid = FALSE THEN 'Unpaid'
        ELSE 'Unknown'
    END AS payment_status,
    COUNT(*) AS fine_count,
    SUM(fine_amount) AS total_amount
FROM fines
GROUP BY payment_status;

--		QUERY 4.3
SELECT genre, COUNT(*) AS number_of_titles, SUM(total_copies) AS total_copies
FROM books
GROUP BY genre
ORDER BY total_copies DESC
LIMIT 5;

--		QUERY 4.4
SELECT m.membership_type, ROUND(AVG(DATEDIFF(l.return_date, l.loan_date)), 2) AS avg_days_borrowed,
COUNT(l.loan_id) AS total_loans
FROM loans l JOIN members m ON l.member_id = m.member_id
WHERE l.status = 'returned'
GROUP BY m.membership_type
ORDER BY avg_days_borrowed DESC;


--		QUERY 4.5
SELECT b.title, a.author_name AS author, b.genre, bc.acquisition_date
FROM book_copies bc
JOIN books b ON bc.book_id = b.book_id
JOIN authors a ON b.author_id = a.author_id
LEFT JOIN loans l ON bc.copy_id = l.copy_id
WHERE l.loan_id IS NULL
ORDER BY bc.acquisition_date;

--		QUERY 4.6
SELECT CONCAT(m.first_name, ' ', m.last_name) AS member_name, COUNT(l.loan_id) AS total_loans, 
SUM(CASE WHEN l.status = 'active' THEN 1 ELSE 0 END) AS active_loans,
COALESCE(SUM(CASE WHEN f.paid = FALSE THEN f.fine_amount ELSE 0 END), 0) AS unpaid_fines
FROM members m JOIN loans l ON m.member_id = l.member_id
LEFT JOIN fines f ON l.loan_id = f.loan_id
GROUP BY m.member_id
HAVING total_loans > 0
ORDER BY total_loans DESC
LIMIT 10;

--		QUERY 4.7
SELECT YEAR(l.loan_date) AS loan_year, MONTH(l.loan_date) AS loan_month, COUNT(l.loan_id) AS total_loans,
COUNT(DISTINCT l.member_id) AS unique_borrowers,
COUNT(DISTINCT bc.book_id) AS unique_books
FROM loans l JOIN book_copies bc ON l.copy_id = bc.copy_id
WHERE l.loan_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)
GROUP BY YEAR(l.loan_date), MONTH(l.loan_date)
ORDER BY loan_year DESC, loan_month DESC;


-- 		QUERY 4.8
SELECT e.event_name ,e.event_date,COUNT(r.registration_id) AS registrations, e.max_attendees,ROUND((COUNT(r.registration_id) / e.max_attendees) * 100, 2) AS capacity_percentage
FROM events e LEFT JOIN event_registrations r ON r.event_id = e.event_id
WHERE e.event_date > CURDATE()
GROUP BY e.event_name ,e.event_date,e.max_attendees
ORDER BY capacity_percentage DESC;
