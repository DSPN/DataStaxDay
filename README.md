Welcome to the DataStax Labs!
===================
![icon](http://i.imgur.com/FoIOBlt.png)

In this session, you'll learn all about DataStax Enterprise. It's a mix between presentation and hands-on. This is your reference for the hands-on content. Feel free to bookmark this page for future reference! 

----------


Hands On Setup
-------------
You should have a 3 node cluster provisioning in Microsoft Azure. Log in to your Microsoft Azure Portal. If you don't see it on the main dashboard, go into your "Resource Groups" to find the cluster that you provisioned. Within your Resource Group, you should see four Virtual Machines - one named "OpsCenter" and three named "dc0vm0", "dc0vm1", and "dc0vm2." 

Take the public IP address from the OpsCenter node and add :8888 to it in your browser. i.e. type 13.67.227.135:8888 in your browser - this will take you to OpsCenter, the visual monitoring and management tool for your cluster. From either OpsCenter or your Azure portal, you can find the external IP addresses of your nodes, which will be used to access them.

#### Accessing your nodes via Terminal (Mac users)

You will be using SSH in Terminal to access your nodes. You will need the external IP address of the node and the username/password you supplied during the provisioning process. In Terminal type the command, then hit enter: 
```
ssh <username>@<external IP address>
``` 

So if your username is datastax, and IP address is 13.67.227.135 like above, the command will be: 
```
ssh datastax@13.67.227.135
```

You'll be prompted for your password - enter it and you will be brought to a command line where you should see (if you are accessing dc0vm0):
```
<user>@dc0vm0:~$
```

#### Accessing your nodes via PuTTY (Windows users)

If necessary, download PuTTY [here](http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html). Within PuTTY, enter the external IP address of your node in the "Host Name (or IP address)" box. Make sure the Port is 22 and the "Connection Type" is set to "SSH." Select "Open," which will be followed by a security prompt about accepting the RSA key of the server - select "Yes." Then you will be brought to a command line window asking for your username, followed by your password. After the correct credentials are enetered you will be brought to command line for your server:
```
<user>@dc0vm0:~$
```



----------


Hands On DSE Cassandra 
-------------------

Cassandra is the brains of DSE. It's an awesome storage engine that handles replication, availability, structuring, and of course, storing the data at lightning speeds. It's important to get yourself acquainted with the Cassandra to fully utilize the power of the DSE Stack. 


#### Enable Search and Analytics on your cluster

Stop DSE
```
sudo service dse stop
```
Edit /etc/default/dse to enable Search and analytics. Set SOLR_ENABLED and SPARK_ENABLED equal to 1
```
sudo nano /etc/default/dse
```

Start DSE
```
sudo service dse start
```
***MAKE SURE TO DO THIS TO ALL 3 OF YOUR DSE NODES***

#### Create a Keyspace, Table, and Queries 

You will be accessing DSE through **CQLSH**. This is an interactive command line tool for CQL (Cassandra Query Language) access to DSE. Start CQLSH with the following command in your command line terminal of your node:
```
cqlsh
```

Let's make our first Cassandra Keyspace!
```
CREATE KEYSPACE amp_event WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 3 };
```

And just like that, any data within any table you create in the amp_event keyspace will automatically be replicated 3 times. 

> **Hint** - SimpleStrategy is OK for a cluster using a single data center, but in the real world with multiple datacenters you would use the ```NetworkTopologyStrategy``` replication strategy. In fact, even if you start out on your development path with just a single data center, if there is even a chance that you might go to multiple data centers in the future, then you should use NetworkTopologyStrategy from the outset.

Let's keep going and create ourselves a table. You can follow my example or be a rebel and roll your own. 

```
CREATE TABLE amp_event.sales (
	name text,
	time int,
	item text,
	price double,
	PRIMARY KEY (name, time)
) WITH CLUSTERING ORDER BY ( time DESC );
```

Let's get some data into your table! Cut and paste these inserts into CQLSH. Feel free to insert your own data values, as well. 

```
INSERT INTO amp_event.sales (name, time, item, price) VALUES ('marc', 20150205, 'Apple Watch', 299.00);
INSERT INTO amp_event.sales (name, time, item, price) VALUES ('marc', 20150204, 'Apple iPad', 999.00);
INSERT INTO amp_event.sales (name, time, item, price) VALUES ('rich', 20150206, 'Music Man Stingray Bass', 1499.00);
INSERT INTO amp_event.sales (name, time, item, price) VALUES ('marc', 20150207, 'Jimi Hendrix Stratocaster', 899.00);
INSERT INTO amp_event.sales (name, time, item, price) VALUES ('rich', 20150208, 'Santa Cruz Tallboy 29er', 4599.00);
```

At the moment we're prefixing the keyspace name to the table name in our CQL commands e.g. ```amp_event.sales```.

Let's make it a little easier - we can set our ***default*** keyspace so that we dont need to type it in every time.

```
use amp_event;
```
You can check the tables that are in that keyspace like this:
```
describe tables
```

> Of course, if there are tables with the **same name** in **other** keyspaces it may be wiser to continue to use a keyspace prefix to avoid inadvertently modifying the data in the wrong table!

We can check how many rows there are in our table after the insert of five rows:
```
select count(*) from sales;
```

> Be careful with ```count(*)``` - it will scan the entire cluster. This wouldnt be a good idea in a big cluster with millions or billions of rows!

To retrieve data:

```
SELECT * FROM sales where name='marc' AND time >=20150205 ;
```

> See what I did there? You can do range scans on clustering keys! Give it a try.

----------


Hands On Cassandra Primary Keys (Homework)
-------------------

***The secret sauce of the Cassandra data model: Primary Key***

There are just a few key concepts you need to know when beginning to data model in Cassandra. But if you want to know the real secret sauce to solving your use cases and getting great performance, then you need to understand how Primary Keys work in Cassandra. 

Check out [this exercise for understanding how primary keys work](https://github.com/robotoil/Cassandra-Primary-Key-Exercise/blob/master/README.md) and the types of queries enabled by different primary keys.

----------


Hands On Cassandra Consistency 
-------------------

#### Let's play with consistency!

Consistency in Cassandra refers to the number of acknowledgements replica nodes need to send to the coordinator for an operation to be successful while also providing good data (avoiding dirty reads). 

We recommend a ** default replication factor of 3 and consistency level of LOCAL_QUORUM as a starting point**. You will almost always get the performance you need with these default settings.

In some cases, developers find Cassandra's replication fast enough to warrant lower consistency for even better latency SLA's. For cases where very strong global consistency is required, possibly across data centers in real time, a developer can trade latency for a higher consistency level. 

Let's give it a shot. 

**In CQLSH**:

```
tracing on
consistency all
```

>Any query will now be traced. **Consistency** of all means all 3 replicas need to respond to a given request (read OR write) to be successful. 

Let's do a **SELECT** statement to see the effects:

```
SELECT * FROM amp_event.sales where name='rich';
```

How did we do? On my test cluster, I received the expected two results in 6530 microseconds:
```
Request complete | 2016-06-06 17:24:10.560530 |  13.67.225.95 |           6530
```
> Take a look at the trace output. Look at all queries and contact points. What you're witnessing is both the beauty and challenge of distributed systems.

Let's compare a lower consistency level. Use the following command:

```
consistency local_quorum
```

>Quorum means majority: RF/2 + 1. In our case, 3/2 = 1 + 1 = 2. At least 2 nodes need to acknowledge the request. 

Let's try the **SELECT** statement again. Any changes in latency? Again I received the expected two results, but this time in 4448 microseconds:

```
SELECT * FROM amp_event.sales where name='rich';
```

```
Request complete | 2016-06-06 17:25:53.372448 |  13.67.225.95 |           4448
```

> Keep in mind that our dataset is so small, it's sitting in memory on all nodes. With larger datasets that spill to disk, the latency cost become much more drastic. 

> **LOCAL_QUORUM** is the most commonly used consistency level among developers. It provides a good level of performance and a moderate amount of consistency. That being said, many use cases can warrant  **CL=LOCAL_ONE**. 

Let's try this one last time:

```
consistency local_one
```

```
SELECT * FROM amp_event.sales where name='rich';
```

Only needing to receive an acknowledgement from one node dropped our query response time to 778 microseconds:

```
Request complete | 2016-06-06 17:29:05.488778 |  13.67.225.95 |            778
```

To turn off tracing, simply run:
```
tracing off
```

For more detailed classed on data modeling, consistency, and Cassandra 101, check out the free classes at the [DataStax Academy] https://academy.datastax.com website. 

----------


Hands On DSE Search.
-------------
DSE Search is awesome. You can configure which columns of which Cassandra tables you'd like indexed in **lucene** format to make extended searches more efficient while enabling features such as text search and geospatial search. 

Let's start off by indexing the tables we've already made. Here's where the dsetool really comes in handy:

```
dsetool create_core amp_event.sales generateResources=true reindex=true
```

>If you've ever created your own Solr cluster, you know you need to create the core and upload a schema and config.xml. That **generateResources** tag does that for you. For production use, you'll want to take the resources and edit them to your needs but it does save you a few steps. 

This by default will map Cassandra types to Solr types for you. Anyone familiar with Solr knows that there's a REST API for querying data. In DSE Search, we embed that into CQL so you can take advantage of all the goodness CQL brings. Let's give it a shot. 

```
SELECT * FROM amp_event.sales WHERE solr_query='{"q":"name:*"}';
```

Your output will look like this:

```
 name | time     | item                      | price | solr_query
------+----------+---------------------------+-------+------------
 marc | 20150207 | Jimi Hendrix Stratocaster |   899 |       null
 marc | 20150205 |               Apple Watch |   299 |       null
 rich | 20150208 |   Santa Cruz Tallboy 29er |  4599 |       null
 rich | 20150206 |   Music Man Stingray Bass |  1499 |       null
 marc | 20150204 |                Apple iPad |   999 |       null

(5 rows)
```

Now let's try a filter query to return only the items purchased by Marc from Apple:

```
SELECT * FROM amp_event.sales WHERE solr_query='{"q":"name:marc", "fq":"item:*pple*"}';

 name | time     | item        | price | solr_query
------+----------+-------------+-------+------------
 marc | 20150205 | Apple Watch |   299 |       null
 marc | 20150204 |  Apple iPad |   999 |       null

(2 rows)
```

We can also now control how the data is sorted based on a column value:

```
SELECT * FROM amp_event.sales WHERE solr_query='{"q":"name:marc", "fq":"item:*pple*", "sort":"price desc"}';

 name | time     | item        | price | solr_query
------+----------+-------------+-------+------------
 marc | 20150204 |  Apple iPad |   999 |       null
 marc | 20150205 | Apple Watch |   299 |       null

(2 rows)
```

> For your reference, [here's the doc](http://docs.datastax.com/en/datastax_enterprise/4.8/datastax_enterprise/srch/srchCql.html?scroll=srchCQL__srchSolrTokenExp) that shows some of things you can do.

#### (Homework) Metadata and clickstream DSE Search Exercise

This exercise includes clickstream and metadta information publicly shared by Amazon. The instructions for the exercise are in a separate GitHub repo found [HERE](https://github.com/Marcinthecloud/Solr-Amazon-Book-Demo).

Following the instructions on that repo (at another time) will show you another example that has multiple table structures, more data, and also examples of more complex queries that are possible with DSE Search. 

Here's a preview of the table structures and the more complex search queries that you can perform:

***Clickstream Data Table***
```
CREATE TABLE amazon.clicks (
    asin text,
    seq timeuuid,
    user uuid,
    area_code text,
    city text,
    country text,
    ip text,
    loc_id text,
    location text,
    location_0_coordinate double,
    location_1_coordinate double,
    metro_code text,
    postal_code text,
    region text,
    solr_query text,
    PRIMARY KEY (asin, seq, user)
) WITH CLUSTERING ORDER BY (seq DESC, user ASC);
```

***Book Metadata Table*** 

```
CREATE TABLE amazon.metadata (
    asin text PRIMARY KEY,
    also_bought set<text>,
    buy_after_viewing set<text>,
    categories set<text>,
    imurl text,
    price double,
    solr_query text,
    title text
);
```

***Query Examples***
> Filter queries: These are awesome because the result set gets cached in memory. 
```
SELECT * FROM amazon.metadata WHERE solr_query='{"q":"title:Noir~", "fq":"categories:Books", "sort":"title asc"}' limit 10; 
```
> Faceting: Get counts of fields 
```
SELECT * FROM amazon.metadata WHERE solr_query='{"q":"title:Noir~", "facet":{"field":"categories"}}' limit 10; 
```
> Geospatial Searches: Supports box and radius
```
SELECT * FROM amazon.clicks WHERE solr_query='{"q":"asin:*", "fq":"+{!geofilt pt=\"37.7484,-122.4156\" sfield=location d=1}"}' limit 10; 
```
> Joins: Not your relational joins. These queries 'borrow' indexes from other tables to add filter logic. These are fast! 
```
SELECT * FROM amazon.metadata WHERE solr_query='{"q":"*:*", "fq":"{!join from=asin to=asin force=true fromIndex=amazon.clicks}area_code:415"}' limit 5; 
```
> Fun all in one. 
```
SELECT * FROM amazon.metadata WHERE solr_query='{"q":"*:*", "facet":{"field":"categories"}, "fq":"{!join from=asin to=asin force=true fromIndex=amazon.clicks}area_code:415"}' limit 5;
```

Want to see a really cool example of a live DSE Search app? Check out [KillrVideo](http://www.killrvideo.com/) and its [Git](https://github.com/luketillman/killrvideo-csharp) to see it in action. 

----------


Hands On DSE Analytics
--------------------

Spark is general cluster compute engine. You can think of it in two pieces: **Streaming** and **Batch**. **Streaming** is the processing of incoming data (in micro batches) before it gets written to Cassandra (or any database). **Batch** includes both data crunching code and **SparkSQL**, a hive compliant SQL abstraction for **Batch** jobs. 

It's a little tricky to have an entire class run streaming operations on a single cluster, so if you're interested in dissecting a full scale streaming app, check out [THIS git](https://github.com/retroryan/SparkAtScale).  

>Spark has a REPL we can play in. To make things easy, we'll use the SQL REPL. We just need to run one command to bing the local IP to the Spark REPL before accessing it (a bind error will occur if this step is skipped):
```
export SPARK_LOCAL_IP=`ip add|grep inet|grep global|awk '{ print $2 }'|cut -d '/' -f 1`
```

```
dse spark-sql
```

Try some CQL commands

```
use amp_event;
```

And something not too familiar in CQL...
```
SELECT sum(price) FROM sales;
```

Something more complex:
```
select name, item, sum(price) AS max_price FROM sales GROUP BY name,item ORDER BY max_price DESC limit 3;

rich    Santa Cruz Tallboy 29er 4599.0                                          
rich	Music Man Stingray Bass	1499.0
marc	Apple iPad	999.0
```

> This is a small example of how Spark can be used to expand the capabilities of Cassandra. In DSE Analytics, you can leverage that integration to eliminate the need for ETL while performing stream analytics, batch analytics, leverage Spark's Machine Learning library, and more.
  
----------


Getting Started With DSE Ops
--------------------

Most of us love to have tools to monitor and automate database operations. For Cassandra, that tool is DataStax OpsCenter. If you prefer to roll with the command line, then two core utilities you'll need to understand are nodetool and dsetool.

**Utilities you'll want to know:**
```
nodetool  //Cassandra's main utility tool
dsetool   //DSE's main utility tool
```
**nodetool Examples:**
```
nodetool status  //shows current status of the cluster 

nodetool tpstats //shows thread pool status - critical for ops
```

**dsetool Examples:**
```
dsetool status //shows current status of cluster, including DSE features

dsetool create_core //will create a Solr schema on Cassandra data for Search
```

**The main log you'll be taking a look at for troubleshooting outside of OpsCenter:**
```
/var/log/cassandra/system.log
```

