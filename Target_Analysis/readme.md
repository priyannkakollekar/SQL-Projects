# Target_Brazil_Sales_Analysis

Target is one of the world’s most recognized brands and one of America’s leading retailers.This business case has information of 100k orders from 2016 to 2018 made at Target in Brazil. Its features allows viewing an order from multiple dimensions.

Data is available in 8 csv files:

1. customers.csv<br/>
2. geolocation.csv<br/>
3. order_items.csv<br/>
4. payments.csv<br/>
5. reviews.csv<br/>
6. orders.csv<br/>
7. products.csv<br/>
9. sellers.csv<br/>


## Data Exploration 


After uploading the CSV datasets into Google Cloud, the customer dataset has been initially analyzed.  <br/><br/>
• **Customers Table:** There are around 99,441 rows representing each customer who has ordered. The table 
contains alphanumeric values, integers for pincode and string data.  <br/><br/>
• **Geolocations Table:** It contains arount 19,015 unique zipcodes, the data types are floating point for latitude and 
longitude. The name of city and state is also provided as string. <br/><br/>
• **Order Reviews:** Around 99,224 reviews are there in the table whose primary key is review_id. Foreign key is 
order_id. Each review has a review score from 1-5. And review date having datetime data type.  <br/><br/>
• **Products:** There are around 32,951 products, the fields describe the dimensions of the product in integers.<br/><br/>
• **Order_items:** This table shows for each order how many items have been ordered with the corresponding 
seller_id, order_id, product_id as the foreign keys. <br/><br/>
• **Payments:** In this table we have for each order, the payment type(string), price(float), and number of 
installments(int), with around 103886 rows.  <br/><br/>
• **Sellers:** We have the information about the sellers. Seller_id(string), zip code(int), city and state(string). <br/><br/>
• **Orders:** We have 99,441 orders with inform.  <br/><br/>

## Time Period 


From orders table we see that the time period of the date is from 2016-09-04 21:15:19 UTC to 2018-10-17 17:30:18 UTC. 
Around 2 years

## States and cities of customers 

There are around 4310 cities from where the customers ordered. 

## Trend in e-commerce 
We see that initially the volume of orders (no. of orders) was less in 2016. However, from 2017 the number of orders has 
increased rapidly. In Nov od 2017, sales peak and eventually they come back down in 2018.


## Time at which Brazilian customers tend to buy 
Extracting time from order_purchase_timestamp and using Case and when statements, we can classify the time into Dawn, 
morning, afternoon, night. By grouping by the time_of_day, we get the count of orders which is saved as sales. From this we observe 
that in afternoon Brazilian customers tend to buy more. 

## Percentage increase in cost of orders 
The percentage increase in cost of orders is first calculated by join payments table with orders. We will only take orders 
which are made from Jan to Aug (1-8). Then finally we group by year 2017 and 2018, where we aggregate the total 
payments. Using lag function, we can take the difference between the costs in 2017 and 2018 and finally we can take 
percentage. We get the answer as 136.97% from 2017 to 2018.


## Mean and sum of freight value and price.
We see that Sao Paolo state has the highest amount of total price and total freight value. We also notice an important information 
here, for SP state, the average price and average freight value is the least. Target could decrease the freight value in all the regions. 
This will increase sales as it would bring down the overall cost to customer. 

## Payment type analysis – Month over month count of different payment types
We see that no. of orders steadily increase month over month for all payment types up until august and then it 
drastically falls. Credit card payments are the highest. 
We can recommend Target to give more discounts and benefits to debit card customers, because this payment type is 
the least used.

## Payment type analysis – Count of orders based on no. of installments
We can observe the number of one-time purchases is highest. 

## Insights from the data: 
• Number of orders increased rapidly from 2016 up until 2017. However, it was less in 2018 due to the fact that 
there was no sufficient data from 2018. But overall the sales trend is upward. <br/>
• Further, we see that sales peak in the mid-year period during the months of May, July and August.  <br/>
• We can see that customers buy more during the afternoons and mornings. <br/>
• We can see that most of the customers come from the state of SP, RJ and MG which contribute to more than 60% 
of total customers. <br/>
• There is 137% increase in total cost of orders from 2017 to 2018.<br/> 
• We see that the cost of freight is around 1/6 of the price. <br/>
• The state of SP has the highest number of orders and the lowest average cost of freight.  <br/>
• We can also see that as the volume of orders decreases from state to state, the freight price increases. <br/>
• The state RR has the highest average freight cost most time taken to deliver.<br/>
• The state AM is the fastest in terms of delivery time, which is around 2.29 days. <br/>
• The number of credit card payments is the highest. Whereas payments made through debit cards are the lowest.<br/>
• We can observe the number of one-time purchases is highest. The number of purchases decreases when the 
number of installments increase. <br/>

## Recommendation: 
• We can recommend Target to give more discounts and benefits to debit card customers, because this payment 
type is least used.<br/>
• Inventory management and logistics should be improved in certain states (mentioned above), to decrease the 
delivery time.<br/>
• Estimation of delivery should be more aligned with the actual delivery time, so that customers don’t receive the 
orders at unexpected time.<br/>
• Improved logistics will also decrease the average freight costs.<br/>
• The state SP is very important for Target, since it is where most orders come from. Target should focus on 
reducing the delivery time in this region.<br/>
• The number of orders is less for products where the number of installments is more – which are generally 
higher value purchases. To increase the affordability of bigger purchases, Target should provide no cost EMI 
and discounts for purchases with 12 installments or more.<br/>
• Overall month on month sales is increasing. Therefore, Target should focus on expanding in the Brazil market 
so as to not face any shortages or delays.<br/>



