# Lab 4 - Analytics

Hands On DSE Analytics
Spark is general cluster compute engine. You can think of it in two pieces: Streaming and Batch. Streaming is the processing of incoming data (in micro batches) before it gets written to Cassandra (or any database). Batch includes both data crunching code and SparkSQL, a hive compliant SQL abstraction for Batch jobs.

It's a little tricky to have an entire class run streaming operations on a single cluster, so if you're interested in dissecting a full scale streaming app, check out this git:

https://github.com/retroryan/SparkAtScale


Spark has a REPL we can play in. To make things easy, we'll use the SQL REPL:

$ dse spark-sql --conf spark.ui.port=<Pick a random 4 digit number> --conf spark.cores.max=1

Notice the spark.ui.port flag - Because we are on a shared cluster, we need to specify a radom port so we don't clash with other users. We're also setting max cores = 1 or else one job will hog all the resources.

Try some CQL commands:

cqlsh> use retailer; 
cqlsh> SELECT * FROM <your table> WHERE...;

And something not too familiar in CQL... SELECT sum(price) FROM <your table>...;
Let's try having some fun on that Book data:

cqlsh> SELECT sum(price) FROM metadata;
cqlsh> SELECT m.title, c.city FROM metadata m JOIN clicks c ON m.asin=c.asin;
cqlsh> SELECT asin, sum(price) AS max_price FROM metadata GROUP BY asin ORDER BY max_price DESC limit 1;
