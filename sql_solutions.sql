//User ID & Last Booked Room//
SELECT user_id, room_no
FROM (
    SELECT user_id, room_no,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY booking_date DESC) AS rn
    FROM bookings
) t
WHERE rn = 1;


//Booking ID & Total Billing (Nov 2021)//
SELECT bc.booking_id,
       SUM(i.item_rate * bc.item_quantity) AS total_bill
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
JOIN bookings b ON bc.booking_id = b.booking_id
WHERE MONTH(b.booking_date) = 11 AND YEAR(b.booking_date) = 2021
GROUP BY bc.booking_id;


//Bills > 1000 (Oct 2021)//
SELECT bill_id,
       SUM(i.item_rate * bc.item_quantity) AS bill_amount
FROM booking_commercials bc
JOIN items i ON bc.item_id = i.item_id
WHERE MONTH(bc.bill_date) = 10 AND YEAR(bc.bill_date) = 2021
GROUP BY bill_id
HAVING SUM(i.item_rate * bc.item_quantity) > 1000;


//Most & Least Ordered Item per Month (2021)//
WITH item_orders AS (
    SELECT MONTH(bc.bill_date) AS month,
           bc.item_id,
           SUM(bc.item_quantity) AS total_qty
    FROM booking_commercials bc
    WHERE YEAR(bc.bill_date) = 2021
    GROUP BY MONTH(bc.bill_date), bc.item_id
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY month ORDER BY total_qty DESC) AS most_rank,
           RANK() OVER (PARTITION BY month ORDER BY total_qty ASC) AS least_rank
    FROM item_orders
)
SELECT * FROM ranked
WHERE most_rank = 1 OR least_rank = 1;

//Second Highest Bill per Month//
WITH monthly_bills AS (
    SELECT MONTH(bc.bill_date) AS month,
           b.user_id,
           bc.bill_id,
           SUM(i.item_rate * bc.item_quantity) AS total_bill
    FROM booking_commercials bc
    JOIN bookings b ON bc.booking_id = b.booking_id
    JOIN items i ON bc.item_id = i.item_id
    WHERE YEAR(bc.bill_date) = 2021
    GROUP BY MONTH(bc.bill_date), b.user_id, bc.bill_id
),
ranked AS (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY month ORDER BY total_bill DESC) AS rnk
    FROM monthly_bills
)
SELECT * FROM ranked
WHERE rnk = 2;

//Revenue by Sales Channel//
SELECT sales_channel,
       SUM(amount) AS revenue
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY sales_channel;

//Top 10 Customers//
SELECT uid,
       SUM(amount) AS total_spent
FROM clinic_sales
WHERE YEAR(datetime) = 2021
GROUP BY uid
ORDER BY total_spent DESC
LIMIT 10;

//Month-wise Revenue, Expense, Profit//
WITH revenue AS (
    SELECT MONTH(datetime) AS month,
           SUM(amount) AS total_revenue
    FROM clinic_sales
    WHERE YEAR(datetime) = 2021
    GROUP BY MONTH(datetime)
),
expenses_cte AS (
    SELECT MONTH(datetime) AS month,
           SUM(amount) AS total_expense
    FROM expenses
    WHERE YEAR(datetime) = 2021
    GROUP BY MONTH(datetime)
)
SELECT r.month,
       r.total_revenue,
       e.total_expense,
       (r.total_revenue - e.total_expense) AS profit,
       CASE
           WHEN (r.total_revenue - e.total_expense) > 0 THEN 'Profitable'
           ELSE 'Not Profitable'
       END AS status
FROM revenue r
JOIN expenses_cte e ON r.month = e.month;

//Most Profitable Clinic per City//
WITH clinic_profit AS (
    SELECT c.city, c.cid,
           SUM(cs.amount) - COALESCE(SUM(e.amount),0) AS profit
    FROM clinics c
    JOIN clinic_sales cs ON c.cid = cs.cid
    LEFT JOIN expenses e ON c.cid = e.cid
    WHERE MONTH(cs.datetime) = 9 AND YEAR(cs.datetime) = 2021
    GROUP BY c.city, c.cid
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY city ORDER BY profit DESC) AS rnk
    FROM clinic_profit
)
SELECT * FROM ranked WHERE rnk = 1;

//Most Profitable Clinic per City//
WITH clinic_profit AS (
    SELECT c.state, c.cid,
           SUM(cs.amount) - COALESCE(SUM(e.amount),0) AS profit
    FROM clinics c
    JOIN clinic_sales cs ON c.cid = cs.cid
    LEFT JOIN expenses e ON c.cid = e.cid
    WHERE MONTH(cs.datetime) = 9 AND YEAR(cs.datetime) = 2021
    GROUP BY c.state, c.cid
),
ranked AS (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY state ORDER BY profit ASC) AS rnk
    FROM clinic_profit
)
SELECT * FROM ranked WHERE rnk = 2;

