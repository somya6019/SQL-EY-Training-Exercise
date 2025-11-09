--		QUERY 7.1
SELECT CONCAT(first_name, ' ', last_name) AS full_name, email, 'Member' AS person_type
FROM members

UNION

SELECT author_name AS full_name, NULL AS email, 'Author' AS person_type
FROM authors

ORDER BY person_type, full_name;

--		QUERY 7.2
SELECT 'Loan' AS activity_type, l.loan_date AS activity_date,
CONCAT(m.first_name, ' ', m.last_name, ' borrowed "', b.title, '"') AS description
FROM loans l JOIN members m ON l.member_id = m.member_id
JOIN book_copies bc ON l.copy_id = bc.copy_id
JOIN books b ON bc.book_id = b.book_id

UNION ALL

SELECT 'Event' AS activity_type, e.event_date AS activity_date,
CONCAT('Library hosted event: "', e.event_name, '" (', e.event_type, ')') AS description
FROM events e

UNION ALL

SELECT 'Registration' AS activity_type, er.registration_date AS activity_date,
CONCAT(m.first_name, ' ', m.last_name, ' registered for "', e.event_name, '"') AS description
FROM event_registrations er JOIN members m ON er.member_id = m.member_id
JOIN events e ON er.event_id = e.event_id

ORDER BY activity_date DESC
LIMIT 50;

--		QUERY 7.3
SELECT b.title, 'Available' AS status, COUNT(bc.copy_id) AS copy_count
FROM books b JOIN book_copies bc ON b.book_id = bc.book_id
WHERE bc.copy_id NOT IN (
    SELECT l.copy_id
    FROM loans l
    WHERE l.status = 'active'
)
GROUP BY b.book_id, b.title

UNION ALL

SELECT b.title, 'On Loan' AS status, COUNT(l.copy_id) AS copy_count
FROM books b JOIN book_copies bc ON b.book_id = bc.book_id
JOIN loans l ON bc.copy_id = l.copy_id
WHERE l.status = 'active'
GROUP BY b.book_id, b.title

ORDER BY title, status;

--		QUERY 7.4
--  1: Members with overdue books
SELECT CONCAT(m.first_name, ' ', m.last_name) AS member_name, m.email,
'Overdue' AS issue_type, COUNT(*) AS issue_count
FROM members m JOIN loans l ON m.member_id = l.member_id
WHERE l.status = 'active' AND l.due_date < CURDATE()
GROUP BY m.member_id, m.first_name, m.last_name, m.email

UNION ALL

--  2: Members with unpaid fines
SELECT CONCAT(m.first_name, ' ', m.last_name) AS member_name, m.email,
'Unpaid Fines' AS issue_type, COUNT(*) AS issue_count
FROM members m JOIN loans l ON m.member_id = l.member_id
JOIN fines f ON l.loan_id = f.loan_id
WHERE f.paid = FALSE
GROUP BY m.member_id, m.first_name, m.last_name, m.email

UNION ALL

--  3: Suspended members
SELECT CONCAT(m.first_name, ' ', m.last_name) AS member_name, m.email,
'Suspended' AS issue_type, 1 AS issue_count
FROM members m
WHERE m.status = 'suspended'

ORDER BY member_name, issue_type;

--		QUERY 7.5

    -- Top 10 most borrowed books
(
SELECT b.title, a.author_name, 'Popular' AS category, COUNT(l.loan_id) AS loan_count
FROM books b JOIN authors a ON b.author_id = a.author_id
JOIN book_copies bc ON b.book_id = bc.book_id
JOIN loans l ON bc.copy_id = l.copy_id
GROUP BY b.book_id, b.title, a.author_name
ORDER BY loan_count DESC
LIMIT 10
)
UNION ALL

    -- 10 least borrowed books
(
SELECT b.title, a.author_name, 'Unpopular' AS category, COUNT(l.loan_id) AS loan_count
FROM books b JOIN authors a ON b.author_id = a.author_id
JOIN book_copies bc ON b.book_id = bc.book_id
LEFT JOIN loans l ON bc.copy_id = l.copy_id
GROUP BY b.book_id, b.title, a.author_name
ORDER BY loan_count ASC
LIMIT 10
)
ORDER BY category, loan_count DESC;


