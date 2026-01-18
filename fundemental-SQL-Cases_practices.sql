# 1. Find ids where today's temperature is higher than yesterday
SELECT w1.id
FROM Weather w1
JOIN Weather w2
ON w1.recordDate = DATE_ADD(w2.recordDate, INTERVAL 1 DAY)
WHERE w1.temperature > w2.temperature;


# 2. Calculate average processing time per machine by pairing start and end logs
SELECT a1.machine_id, ROUND(AVG(a2.timestamp-a1.timestamp), 3) AS  processing_time
FROM Activity a1
JOIN Activity a2
ON a1.machine_id = a2.machine_id
AND a1.process_id = a2.process_id
AND a1.activity_type = 'start'
AND a2.activity_type = 'end'
GROUP BY a1.machine_id;

# 3. Find employees with bonus less than 1000 or no bonus record
SELECT e.name, b.bonus
FROM Employee e
LEFT JOIN Bonus b
ON e.empId = b.empId
WHERE b.bonus < 1000
OR b.bonus IS NULL;

# 4. Find managers with at Least 5 Direct Reports
SELECT e1.name
FROM Employee e1
JOIN Employee e2
ON e2.managerId = e1.id
GROUP BY e1.id
HAVING COUNT(e1.id)>=5;

# 5. Calculate the confirmation rate of users
SELECT s.user_id, 
ROUND(
    COALESCE(
    SUM(CASE WHEN c.action = 'confirmed' THEN 1 ELSE 0 END) -- count confirmed actions
    / NULLIF(COUNT(c.action),0), -- avoid division by zero
    0),
2
) AS confirmation_rate
FROM Signups s
LEFT JOIN Confirmations c
ON s.user_id = c.user_id
GROUP BY s.user_id;

# 6. Evaluate the average experience years for the first project
SELECT 
p.project_id,
ROUND(AVG(e.experience_years), 2) AS average_years
FROM Project p
LEFT JOIN Employee e
ON e.employee_id = p.employee_id
GROUP BY p.project_id;

# 7. Elvaluate query performance by measuring queries quality and proportion of poorly rated queries
SELECT 
query_name,
ROUND(AVG(rating/position), 2) AS quality,
ROUND(AVG(rating < 3 )* 100, 2) AS poor_query_percentage
FROM Queries
GROUP BY query_name;

# 8. Count monthly total and approved transcations
SELECT
DATE_FORMAT(trans_date,'%Y-%m')AS month,
country,
COUNT(state)AS trans_count,
COUNT(CASE WHEN state = 'approved' THEN 1 END )AS approved_count,
SUM(amount)AS trans_total_amount,
SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END) AS approved_total_amount
FROM Transactions
GROUP BY month, country;

# 9. Calculate Porportion of customers whose first order of food immediate delivery arrived on time
SELECT
    ROUND(SUM(
    CASE 
    WHEN d.order_date = d.customer_pref_delivery_date 
    THEN 1    
     ELSE 0 END)/ COUNT(*) * 100, 2
     ) AS immediate_percentage
FROM Delivery d
JOIN (
    SELECT customer_id, MIN(order_date) AS first_order_date
    FROM Delivery
    GROUP BY customer_id
) f
ON d.customer_id = f.customer_id
AND d.order_date = f.first_order_date;

# 10. Calculate the fraction of players who return the day after their first login
SELECT ROUND(SUM(next_day) / COUNT(*), 2) 
AS fraction 
FROM( 
    SELECT player_id,
    MAX(CASE 
    WHEN DATE_ADD(t.first_date, INTERVAL 1 DAY) = event_date 
    THEN 1 ELSE 0 END) AS next_day
FROM (
    SELECT player_id, event_date, 
    MIN(event_date) OVER (PARTITION BY player_id) AS first_date
FROM Activity
) t
GROUP BY player_id
)t2;


#11. Calculate average selling price
 SELECT 
p.product_id,
ROUND(IFNULL(SUM(p.price*u.units)/SUM(u.units),0), 2) AS average_price
FROM Prices p
LEFT JOIN UnitsSold u
ON p.product_id = u.product_id
AND u.purchase_date BETWEEN p.start_date AND p.end_date
GROUP BY p.product_id;


# 12. Calculate percentage of users attended a contest
# Write your MySQL query statement below
SELECT 
r.contest_id, 
ROUND(COUNT(r.user_id) * 100 / (SELECT COUNT(*) FROM Users), 2) AS percentage
FROM Register r
GROUP BY r.contest_id
ORDER BY percentage DESC, r.contest_id ASC;

# 13. Retrieve the sales records for each product in its first year of sale
SELECT
s.product_id,
t.first_year,
s.quantity,
s.price
FROM Sales s
JOIN(
    SELECT
    product_id,
    MIN(year) AS first_year
    FROM Sales
    GROUP BY product_id
     ) t
ON s.product_id = t.product_id
AND s.year = t.first_year

# 14. Identify classes that have at least 5 students enrolled.
SELECT class
FROM Courses
GROUP BY class
HAVING COUNT(*) >= 5;


# 15. Identify biggest number
SELECT MAX(num) AS num
FROM( 
SELECT num
FROM MyNumbers
GROUP BY num
HAVING COUNT(*) = 1
) t;

# 16. Identify customers who have purchased all available products.
SELECT customer_id
FROM Customer
GROUP BY customer_id
HAVING COUNT(DISTINCT product_key) = (SELECT COUNT(*) FROM Product);

# 17. Detect numbers that appear at least three times
SELECT DISTINCT l1.num AS ConsecutiveNums
FROM Logs l1
JOIN Logs l2
ON l1.id + 1 = l2.id
JOIN Logs l3
ON l3.id = l1.id + 2 
WHERE l1.num = l2.num
AND l2.num = l3.num;

# 18. Retrieve each product's price as a specific date
SELECT 
p1.product_id, 
COALESCE(p3.new_price, 10) AS price
FROM (SELECT DISTINCT product_id
      FROM Products 
) p1
LEFT JOIN (
    SELECT product_id,
    MAX(change_date) AS last_date
    FROM Products
    WHERE change_date <= '2019-08-16'
    GROUP BY product_id
) p2
ON p1.product_id = p2.product_id
LEFT JOIN Products p3
ON p3.product_id = p2.product_id
AND p3.change_date = p2.last_date;


# 19. Identify last person who can be accomodated to the queue without the cumulative weight exceeding the lmit
SELECT person_name
FROM(
SELECT
Turn,
person_name,
SUM(Weight) OVER (ORDER BY Turn
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
AS Total_Weight 
FROM Queue) t
WHERE Total_Weight <= 1000
ORDER BY Turn DESC
LIMIT 1;

# 20. Categorize accounts into income bands and count how many counts that fall into each category
SELECT c.category,
COUNT(a.account_id) AS accounts_count
FROM(
SELECT 'High Salary' AS category
UNION ALL 
SELECT 'Low Salary' 
UNION ALL 
SELECT 'Average Salary'
) c
LEFT JOIN Accounts a
ON c.category = CASE WHEN income < 20000 THEN 'Low Salary'
     WHEN income >= 20000 AND income <= 50000 THEN 'Average Salary'
ELSE 'High Salary'
END 
GROUP BY c.category;


# 21. Swap seat assignment for every pair of adjacent students
Retrieve employees with their primary department
SELECT 
CASE WHEN id % 2 = 1 AND id < (SELECT COUNT(*) from Seat) THEN id + 1
WHEN id % 2 = 0 THEN id - 1
ELSE id
END AS id, student
FROM Seat
ORDER BY id ASC;


# 22. Identify the most active user number based on the number of movie rating submitted
(SELECT u.name AS results
FROM MovieRating mr
JOIN Users u
ON mr.user_id = u.user_id
GROUP BY u.name
ORDER BY COUNT(*) DESC, u.name ASC
LIMIT 1)
UNION ALL
(SELECT m.title AS results
FROM MovieRating mr
JOIN Movies m
ON mr.movie_id = m.movie_id
WHERE mr.created_at LIKE '%2020-02%'
GROUP BY m.title
ORDER BY AVG(rating) DESC, m.title ASC
LIMIT 1);


# 23. Identify the use with highest number of friends
SELECT id, num
FROM(
    SELECT id, COUNT(DISTINCT friend_id) AS num
FROM(
    SELECT requester_id AS id, accepter_id AS friend_id
FROM RequestAccepted
UNION ALL
SELECT accepter_id AS id, requester_id AS friend_id
FROM RequestAccepted
) t
GROUP BY id
) t2
WHERE num = (SELECT MAX(num)
    FROM(
        SELECT id, COUNT(DISTINCT friend_id) AS num
             FROM(
    SELECT requester_id AS id, accepter_id AS friend_id
FROM RequestAccepted
UNION ALL
SELECT accepter_id AS id, requester_id AS friend_id
FROM RequestAccepted
) t
             GROUP BY id)t3);


# 24. Finf users with valid e-mails
SELECT *
FROM Users
WHERE REGEXP_LIKE(mail COLLATE utf8mb3_bin, '^[A-Za-z][A-Za-z0-9\\._\\-]*@leetcode(?:\\.com)?$');


# 25.Group sold products by the date
SELECT
sell_date,
COUNT(DISTINCT product) AS num_sold,
GROUP_CONCAT(
    DISTINCT product
    SEPARATOR ','
) AS products
FROM Activities
GROUP BY sell_date
ORDER BY sell_date;