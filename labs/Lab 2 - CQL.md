# Creating a Keyspace, Table, and Queries
Try the following CQL commands in DevCenter. In addition to DevCenter, you can also use CQLSH as an interactive command line tool for CQL access to Cassandra. Start CQLSH like this:

First run ifconfig and look to see what your 10.0.0.x IP Address is:

$ ifconfig

Make sure to replace 10.0.0.X with the IP of the respective node:

$ cqlsh 10.0.0.X


Let's make our first Cassandra Keyspace! If you are using uppercase letters, use double quotes around the keyspace.

create keyspace if not exists retailer with replication = { 'class' : 'SimpleStrategy', 'replication_factor' : 3 };

And just like that, any data within any table you create under your keyspace will automatically be replicated 3 times. Let's keep going and create ourselves a table. You can follow my example or be a rebel and roll your own.

use retailer;

CREATE TABLE retailer.sales (
    name text,
    time int,
    item text,
    price double,
    PRIMARY KEY (name, time)
) WITH CLUSTERING ORDER BY ( time DESC );

Yup. This table is very simple but don't worry, we'll play with some more interesting tables in just a minute.

Let's get some data into your table! Cut and paste these inserts into DevCenter or CQLSH. Feel free to insert your own data values, as well.

INSERT INTO retailer.sales (name, time, item, price) VALUES ('chuck', 20160205, 'Microsoft Xbox', 299.00);
INSERT INTO retailer .sales (name, time, item, price) VALUES (‘ben’, 20160204, Microsoft Surface', 999.00);
INSERT INTO retailer .sales (name, time, item, price) VALUES ('ben', 20160206, 'Music Man Stingray Bass', 1499.00);
INSERT INTO retailer .sales (name, time, item, price) VALUES ('chuck', 20160207, 'Jimi Hendrix Stratocaster', 899.00);
INSERT INTO retailer .sales (name, time, item, price) VALUES (‘chuck’, 20160208, 'Specialized Roubaix', 4599.00);

And to retrieve it:

SELECT * FROM retailer.sales WHERE name=’chuck’ AND time >=20160205 ; 

See what I did there? You can do range scans on clustering keys! Give it a try.
