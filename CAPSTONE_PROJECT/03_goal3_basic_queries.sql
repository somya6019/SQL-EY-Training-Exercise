-- 		QUERY 3.1
SELECT first_name, last_name, email, membership_type
FROM members
WHERE status = 'active'
ORDER BY last_name, first_name;

--		QUERY 3.2
SELECT b.title, a.author_name, b.publication_year, b.genre
FROM books b JOIN authors a ON a.author_id = b.author_id
WHERE b.publication_year > 2000
ORDER BY b.publication_year DESC; 

--		QUERY 3.3
SELECT b.title, a.author_name, b.genre, b.total_copies
FROM books b JOIN authors a ON a.author_id = b.author_id
WHERE genre = 'fiction'
ORDER BY title; 

-- 		QUERY 3.4
SELECT CONCAT(m.first_name,' ',m.last_name) AS Name,b.title , l.loan_date,l.due_date, DATEDIFF(CURDATE(),l.due_date) AS days_overdue
FROM members m JOIN loans l ON l.member_id = m.member_id
JOIN book_copies bc ON bc.copy_id = l.copy_id
JOIN books b ON b.book_id = bc.book_id
WHERE l.status = 'active' AND DATEDIFF(CURDATE(),l.due_date) > 0
ORDER BY days_overdue DESC;

--		QUERY 3.5
SELECT first_name, last_name, join_date, membership_type
FROM members
WHERE join_date >= DATE_SUB(curdate(),INTERVAL 180 day)
ORDER BY join_date DESC;

-- 		QUERY 3.6
SELECT b.title, bc.copy_number, bc.book_condition, bc.acquisition_date
FROM books b JOIN book_copies bc ON bc.book_id = b.book_id
WHERE bc.book_condition IN ('poor','fair')
ORDER BY bc.book_condition DESC, bc.acquisition_date;

--		QUERY 3.7
SELECT CONCAT(m.first_name,' ',m.last_name) AS name, f.fine_amount, f.fine_reason, l.loan_date
FROM fines f JOIN loans l ON l.loan_id = f.loan_id
JOIN members m ON m.member_id = l.member_id
WHERE f.paid = 0
ORDER BY f.fine_amount DESC
LIMIT 10;

--		QUERY 3.8
SELECT event_name, event_date, event_type, max_attendees
FROM events
WHERE event_date > CURDATE() AND event_date <= DATE_ADD(CURDATE(),INTERVAL 30 DAY)
ORDER BY event_date;



