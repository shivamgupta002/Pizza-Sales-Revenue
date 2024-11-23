-- Question 1->Retrieve the total number of orders placed.
SELECT
    COUNT(order_id)
FROM
    order_details;

-- Question 2-> Calculate the total revenue generated from pizza sales.
SELECT
    round(sum(order_details.quantity * pizzas.price), 2) as total_sales
FROM
    order_details
    JOIN pizzas on pizzas.pizza_id = order_details.pizza_id;

-- Question 3->Identify the highest-priced pizza.
SELECT
    pizza_types.name,
    pizzas.price
from
    pizza_types
    JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
order BY
    pizzas.price DESC
limit
    1;

-- Question 4->Join relevant tables to find the category-wise distribution of pizzas.
SELECT
    category,
    COUNT(name) AS name
from
    pizza_types
GROUP BY
    category;

-- Question 5->List the top 5 most ordered pizza types along with their quantities.
SELECT
    pizza_types.name,
    sum(order_details.quantity) as quantity
FROM
    pizza_types
    JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details on pizzas.pizza_id = order_details.pizza_id
GROUP by
    pizza_types.name
order BY
    quantity DESC
LIMIT
    5;

-- Question 6-> Determine the distribution of orders by hour of the day.
SELECT
    HOUR(order_time) as hour,
    COUNT(order_id) as order_count
FROM
    orders
GROUP BY
    HOUR(order_time);

-- Question 7-> Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT
    pizza_types.category,
    sum(order_details.quantity) AS quantity
FROM
    order_details
    JOIN pizzas on pizzas.pizza_id = order_details.pizza_id
    JOIN pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
GROUP by
    pizza_types.category
order by
    quantity DESC;

-- Question 8->Identify the most common pizza size ordered.
SELECT
    pizzas.size,
    COUNT(order_details.order_details_id) as order_count
from
    pizzas
    JOIN order_details on pizzas.pizza_id = order_details.pizza_id
GROUP BY
    pizzas.size
ORDER BY
    order_count DESC
LIMIT
    1;

-- Question 9->Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT
    avg(quantity)
FROM
    (
        SELECT
            orders.order_date,
            sum(order_details.quantity) AS quantity
        FROM
            orders
            JOIN order_details on orders.order_id = order_details.order_id
        GROUP BY
            orders.order_date
    ) AS order_quantity;

-- Question 10->Determine the top 3 most ordered pizza types based on revenue.
SELECT
    pizza_types.name,
    sum(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
    JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
    JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP by
    pizza_types.name
order BY
    revenue DESC
LIMIT
    3;

-- Question 11->Calculate the percentage contribution of each pizza type to total revenue.
SELECT
    pizza_types.category,
    round(
        sum(order_details.quantity * pizzas.price) / (
            SELECT
                round(sum(order_details.quantity * pizzas.price), 2) as total_sales
            FROM
                order_details
                JOIN pizzas on pizzas.pizza_id = order_details.pizza_id
        ) * 100,
        2
    ) AS revenue
FROM
    pizza_types
    JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY
    pizza_types.category
order BY
    revenue;

-- Question 12->Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT
    name,
    revenue
FROM
    (
        SELECT
            category,
            name,
            revenue,
            rank() over(
                partition BY category
                order BY
                    revenue DESC
            ) as ranking
        FROM
            (
                SELECT
                    pizza_types.category,
                    pizza_types.name,
                    sum((order_details.quantity) * pizzas.price) AS revenue
                FROM
                    pizza_types
                    JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
                    JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
                GROUP BY
                    pizza_types.category,
                    pizza_types.name
            ) AS a
    ) as b
WHERE
    ranking <= 3;