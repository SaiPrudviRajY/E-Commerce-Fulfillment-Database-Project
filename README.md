# E-Commerce-Fulfillment-Database-Project

## Overview

This project involves the design and implementation of a database system tailored for an e-commerce platform. The documentation includes a comprehensive analysis of the database entities, their relationships, business rules, entity-relationship diagrams, stored procedures for database operations, and strategies for query optimization.

## Entities

The database system is structured around the following entities:

- Seller
- Product_Listing
- Category
- Seller_Listing
- Amazon Warehouse
- Consumer Account
- Order
- Order Details

## Business Rules

The structural business rules for each entity are as follows:

### Seller Entity:
- A seller can have multiple product listings or none.
- A product listing can be associated with only one seller at a time but can be reused by multiple sellers.
- A seller can have multiple seller listings for a product, representing different prices or conditions.

### Product Listing Entity:
- A product exactly belongs to one product listing.
- A seller can have zero or more product listings associated with them.

### Category Entity:
- A product can belong to only one category.
- A category can have one or more products associated with it.

### Seller Listing Entity:
- A seller listing can be associated with one or more products.
- A product can have zero or more seller listings associated with it.

### Amazon Warehouse Entity:
- A warehouse can hold multiple products from multiple sellers.
- A product can be stored in multiple warehouses.

### Consumer Account Entity:
- A consumer can have one or more orders.
- An order must belong to exactly one consumer.

### Order Entity:
- An order can have one or more order details.
- An order must belong to exactly one consumer.

### Order Details Entity:
- An order detail must belong to exactly one order.

## Stored Procedures

The project defines several stored procedures to facilitate various operations within the database:

### Aspect 1: New Product Created by Seller
A parameterized stored procedure available for sellers to add any new product to the database.

### Aspect 2: Amazon Receipt of Product from Seller
A stored procedure utilized when a seller delivers an item to Amazon's Warehouse, which generates a receipt and updates the seller's electronic listing.

### Aspect 3: New Consumer Account
A stored procedure to add a new consumer account to the database.

### Aspect 4: Product Purchase by Consumer
A stored procedure that is used when a consumer buys a new product.

### Aspect 5: Product Shipment by Amazon
A stored procedure that is used when a consumer purchases a new product, handling the shipment process.

## Query Optimization

The document includes discussions on optimizing database queries, such as creating indexes to improve the performance of specific queries. For instance, an index on the `Consumer_Username` column in the orders table to expedite the retrieval of orders associated with a consumer.

## Example Queries

The documentation provides example queries for operations such as:

- Updating the inventory for a seller when new products are added.
- Identifying products with inventory levels below a certain threshold.
- Filtering products based on price criteria.

## Additional Documentation

The project includes additional documentation detailing the execution of the stored procedures and the implementation of the database design.

## Author

Yerrapragada, Sai Prudvi Raj
