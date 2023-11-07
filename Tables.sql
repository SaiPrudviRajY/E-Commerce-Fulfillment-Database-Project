-- Tables.sql
CREATE TABLE seller ( 
  Seller_id INT DEFAULT seller_seq.NEXTVAL PRIMARY KEY, 
  Name VARCHAR(50) NOT NULL, 
  Email VARCHAR(50) NOT NULL, 
  Mobile_Number NUMBER(10) NOT NULL, 
  Address VARCHAR(100) NOT NULL 
);

CREATE TABLE Category ( 
    category_id INT  DEFAULT category_seq.NEXTVAL PRIMARY KEY NOT NULL, 
    Name VARCHAR(50) NOT NULL, 
    Description VARCHAR(100) 
);

CREATE TABLE Product_Listing ( 
  Product_ID INT DEFAULT product_id_seq.NEXTVAL PRIMARY KEY, 
  Name VARCHAR(100) NOT NULL, 
  Description VARCHAR(500) NOT NULL, 
  Base_Price NUMBER(10, 2) NOT NULL, 
  Category_ID INT NOT NULL, 
  FOREIGN KEY (Category_ID) REFERENCES Category(category_id) 
);

CREATE TABLE seller_listing ( 
  listing_id INT  DEFAULT listing_id_seq.NEXTVAL PRIMARY KEY NOT NULL, 
  product_id INT NOT NULL, 
  category_id INT NOT NULL, 
  seller_id INT NOT NULL, 
  product_condition VARCHAR(50) NOT NULL, 
  stock INT NOT NULL, 
  FOREIGN KEY (product_id) REFERENCES Product_Listing(Product_ID), 
  FOREIGN KEY (category_id) REFERENCES Category(category_id), 
  FOREIGN KEY (seller_id) REFERENCES seller(Seller_id) 
);

CREATE TABLE Amazon_Warehouse ( 
  Warehouse_id INT DEFAULT Amazon_Warehouse_id_seq.NEXTVAL PRIMARY KEY, 
  product_id INT NOT NULL, 
  listing_id INT NOT NULL, 
  seller_id INT NOT NULL, 
  receipt VARCHAR(50) DEFAULT CONCAT('A', TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISSFF')), 
  Quantity INT, 
  Time_Stamp TIMESTAMP, 
  FOREIGN KEY (product_id) REFERENCES Product_Listing(Product_ID), 
  FOREIGN KEY (listing_id) REFERENCES seller_listing(listing_id), 
  FOREIGN KEY (seller_id) REFERENCES seller(Seller_id) 
);

CREATE TABLE consumer_account ( 
  consumer_Username VARCHAR(50) PRIMARY KEY, 
  first_name VARCHAR(50) NOT NULL, 
  last_name VARCHAR(50) NOT NULL, 
  Email VARCHAR(50) NOT NULL, 
  Password VARCHAR(50) NOT NULL, 
  Phone_Number NUMBER(10) NOT NULL, 
  Billing_Address VARCHAR(100) NOT NULL, 
  Shipping_Address VARCHAR(100) NOT NULL, 
  Cart_Value NUMBER(10,2) 
);

CREATE TABLE orders ( 
  order_id INT DEFAULT orders_seq.NEXTVAL PRIMARY KEY NOT NULL, 
  Consumer_Username VARCHAR(50), 
  Cart_Value NUMBER(10, 2) NOT NULL, 
  Transaction_Status VARCHAR(20) NOT NULL, 
  Order_Date DATE NOT NULL, 
  Tracking_ID VARCHAR(50) NOT NULL, 
  order_status VARCHAR(20) NOT NULL, 
  shipping_speed VARCHAR(20) CHECK (shipping_speed IN ('super saver shipping', 'standard shipping', 'two-day', 'one-day')), 
  FOREIGN KEY (Consumer_Username) REFERENCES consumer_account(consumer_Username) 
);

CREATE TABLE order_details ( 
  product_id INT NOT NULL, 
  order_id INT NOT NULL, 
  seller_id INT NOT NULL, 
  quantity INT NOT NULL, 
  PRIMARY KEY (product_id, order_id, seller_id), 
  FOREIGN KEY (product_id) REFERENCES Product_Listing(Product_ID), 
  FOREIGN KEY (order_id) REFERENCES orders(Order_id), 
  FOREIGN KEY (seller_id) REFERENCES seller(Seller_id) 
);
