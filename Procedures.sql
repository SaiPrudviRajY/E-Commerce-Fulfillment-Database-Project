-- Procedures.sql

CREATE OR REPLACE PROCEDURE ADD_NEW_PRODUCT ( 
  product_name IN VARCHAR2, 
  product_description IN VARCHAR2, 
  base_price IN NUMBER, 
  category_id IN NUMBER, 
  seller_id IN NUMBER, 
  product_condition IN VARCHAR2 DEFAULT NULL, 
  stock IN NUMBER DEFAULT NULL, 
  warehouse_stock IN NUMBER DEFAULT NULL 
) IS 
  listing_id NUMBER; 
  existing_listing_id NUMBER; 
BEGIN 
  -- Check if the product is already listed by another seller 
  BEGIN 
    SELECT listing_id 
    INTO existing_listing_id 
    FROM seller_listing 
    WHERE product_id = (SELECT Product_ID FROM Product_Listing WHERE Name = product_name) 
       AND seller_id != ADD_NEW_PRODUCT.seller_id 
    FETCH FIRST ROW ONLY; 
  EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
      existing_listing_id := NULL; 
  END; 
   
  IF existing_listing_id IS NOT NULL THEN 
    -- The product is already listed by another seller, reuse the same listing 
    listing_id := existing_listing_id; 
  ELSE 
    -- The product is not yet sold on Amazon, create a new listing 
    INSERT INTO Product_Listing (Product_ID, Name, Description, Base_Price, Category_ID) 
    VALUES (product_id_seq.NEXTVAL, product_name, product_description, base_price, category_id); 
     
    SELECT Product_ID INTO listing_id FROM Product_Listing WHERE Name = product_name; 
     
    INSERT INTO seller_listing (listing_id, product_id, category_id, seller_id, Product_condition, Stock) 
    VALUES (listing_id_seq.NEXTVAL, listing_id, category_id, seller_id, product_condition, stock); 
  END IF; 
   
  -- Update stock based on warehouse stock 
  UPDATE seller_listing sl 
  SET sl.stock = warehouse_stock 
  WHERE sl.listing_id = listing_id 
  AND EXISTS (SELECT 1 FROM amazon_warehouse aw WHERE aw.product_id = sl.product_id); 
END ADD_NEW_PRODUCT;
/

CREATE OR REPLACE PROCEDURE RECEIVE_PRODUCT ( 
  p_product_id IN INT, 
  p_seller_id IN INT, 
  p_quantity IN INT 
) AS 
  v_listing_id seller_listing.listing_id%TYPE; 
BEGIN 
  -- Get the listing_id of the corresponding seller_listing 
  SELECT listing_id 
  INTO v_listing_id 
  FROM seller_listing 
  WHERE product_id = p_product_id AND seller_id = p_seller_id; 
 
  -- Insert product delivery information into the Amazon_Warehouse table 
  INSERT INTO Amazon_Warehouse (product_id, listing_id, seller_id, receipt, quantity, Time_Stamp) 
  VALUES (p_product_id, v_listing_id, p_seller_id, CONCAT('A', TO_CHAR(SYSTIMESTAMP, 'YYYYMMDDHH24MISSFF')), p_quantity, SYSTIMESTAMP); 
 
  -- Update the stock of the corresponding seller_listing 
  UPDATE seller_listing 
  SET stock = stock + p_quantity 
  WHERE product_id = p_product_id AND seller_id = p_seller_id; 
 
  DBMS_OUTPUT.PUT_LINE('Product received and stock updated successfully.'); 
EXCEPTION 
  WHEN OTHERS THEN 
    -- Rollback the transaction in case of any errors 
    ROLLBACK; 
    DBMS_OUTPUT.PUT_LINE('Error while receiving product: ' || SQLERRM); 
END RECEIVE_PRODUCT;
/

CREATE OR REPLACE PROCEDURE ADD_NEW_CUSTOMER_ACCOUNT ( 
  p_username IN VARCHAR2, 
  p_first_name IN VARCHAR2, 
  p_last_name IN VARCHAR2, 
  p_email IN VARCHAR2, 
  p_password IN VARCHAR2, 
  p_phone_number IN NUMBER, 
  p_billing_address IN VARCHAR2, 
  p_shipping_address IN VARCHAR2 
) AS 
BEGIN 
  -- Insert the new customer account into the database 
  INSERT INTO consumer_account (consumer_Username, First_Name, Last_Name, Email, Password, Phone_Number, Billing_Address, Shipping_Address) 
  VALUES (p_username, p_first_name, p_last_name, p_email, p_password, p_phone_number, p_billing_address, p_shipping_address); 
   
  -- Commit the transaction 
  COMMIT; 
   
  DBMS_OUTPUT.PUT_LINE('New customer account created successfully.'); 
EXCEPTION 
  WHEN OTHERS THEN 
    -- Rollback the transaction in case of any errors 
    ROLLBACK; 
    DBMS_OUTPUT.PUT_LINE('Error while creating new customer account: ' || SQLERRM); 
END ADD_NEW_CUSTOMER_ACCOUNT;
/

CREATE OR REPLACE PROCEDURE PURCHASE_PRODUCT (  
  in_consumer_username IN VARCHAR2,  
  in_product_id IN INT,  
  in_seller_id IN INT,  
  in_quantity IN INT, 
  in_shipping_speed IN VARCHAR2 
)  
IS  
  v_product_price NUMBER(10,2);  
  v_order_id NUMBER;  
BEGIN  
  -- Get the price of the product  
  SELECT Base_Price  
  INTO v_product_price  
  FROM Product_Listing  
  WHERE Product_ID = in_product_id;  
   
  -- Update the consumer's cart value  
  UPDATE consumer_account  
  SET Cart_Value = Cart_Value + (v_product_price * in_quantity)  
  WHERE consumer_Username = in_consumer_username;  
   
  -- Create a new order record  
  INSERT INTO orders (Consumer_Username, Cart_Value, Transaction_Status, Order_Date, Tracking_ID, order_status, shipping_speed)  
  VALUES (in_consumer_username, v_product_price * in_quantity, 'Pending', SYSDATE, 'N/A', 'Pending', in_shipping_speed);  
  v_order_id := orders_seq.CURRVAL;  
   
  -- Insert the order details  
  INSERT INTO order_details (product_id, order_id, seller_id, quantity)  
  VALUES (in_product_id, v_order_id, in_seller_id, in_quantity);  
   
  -- Update the warehouse stock  
  UPDATE Amazon_Warehouse  
  SET Quantity = Quantity - in_quantity  
  WHERE product_id = in_product_id  
  AND listing_id = (SELECT MAX(listing_id) FROM seller_listing WHERE product_id = in_product_id AND seller_id = in_seller_id);  
   
  COMMIT;  
  DBMS_OUTPUT.PUT_LINE('Purchase completed successfully.');  
EXCEPTION  
  WHEN OTHERS THEN  
    ROLLBACK;  
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);  
END PURCHASE_PRODUCT;
/

CREATE OR REPLACE PROCEDURE SHIP_ORDER (  
  p_order_id IN orders.Order_id%TYPE  
)  
IS  
  v_tracking_id VARCHAR2(20); 
  v_shipping_speed VARCHAR2(50); 
BEGIN  
  -- Get the shipping speed for the given order 
  SELECT shipping_speed INTO v_shipping_speed FROM orders WHERE order_id = p_order_id; 
   
  -- Generate the tracking_id using the sequence  
  SELECT 'TRK' || LPAD(tracking_id_seq.NEXTVAL, 5, '0')  
  INTO v_tracking_id  
  FROM dual;  
  
  UPDATE orders  
  SET Order_Status = 'Shipped',  
      Tracking_ID = v_tracking_id  
  WHERE Order_id = p_order_id;  
  
  DBMS_OUTPUT.PUT_LINE('Order ' || p_order_id || ' shipped successfully with tracking ID: ' || v_tracking_id || ' and shipping speed: ' || v_shipping_speed);  
EXCEPTION  
  WHEN OTHERS THEN  
    DBMS_OUTPUT.PUT_LINE('Error while shipping order: ' || SQLERRM);  
END SHIP_ORDER;
/
