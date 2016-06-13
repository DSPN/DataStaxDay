# Lab 3 - Search

Hands On DSE Search

Search Essentials
DSE Search is awesome. You can configure which columns of which Cassandra tables you'd like indexed in lucene format to make extended searches more efficient while enabling features such as text search and geospatial search.

Let's start off by indexing the tables we've already made. Here's where the dsetool really comes in handy:

$ dsetool create_core retailer.sales generateResources=true reindex=true

If you've ever created your own Solr cluster, you know you need to create the core and upload a schema and config.xml. That generateResources tag does that for you. For production use, you'll want to take the resources and edit them to your needs but it does save you a few steps.

Now for that description of the dsetool. Use the dsetool utility for creating system keys, encrypting sensitive configuration, and performing Cassandra File System (CFS) and Hadoop-related tasks, such as checking the CFS, and listing node subranges of data in a keyspace.



This by default will map Cassandra types to Solr types for you. Anyone familiar with Solr knows that there's a REST API for querying data. In DSE Search, we embed that into CQL so you can take advantage of all the goodness CQL brings. Let's give it a shot.

cqlsh> SELECT * FROM retailer.sales WHERE solr_query='{"q":"name:*"}';

cqlsh> SELECT * FROM retailer.sales WHERE solr_query='{"q":"name:chuck", "fq":"item:*icrosof*"}';

For your reference, here's the doc that shows some of things you can do:

http://docs.datastax.com/en/datastax_enterprise/4.8/datastax_enterprise/srch/srchCql.html?scroll=srchCQL__srchSolrTokenExp

Retail Book Workshop
OK! Time to work with some more interesting data. Meet the Retail book sales data:

Note: This data is already in the DB, if you want to try it at home, click here:

https://github.com/chudro/Retail-Book-Demo

First, you’ll need to set this up within your Azure Instances. Pick your dc0vm0 node and log into it.

$ sudo apt-get install python-pip
$ sudo pip install cassandra-driver
$ sudo apt-get install git
$ git clone https://github.com/chudro/Retail-Book-Demo.git
$ cd Retail-Book-Demo/

Run ‘ifconfig’ and look to see what your 10.0.0.x address is.

$ ifconfig

Edit the solr_dataloader.py file

$ sudo vi solr_dataloader.py

Change the line cluster = Cluster(['node0','node1','node2']) to cluster = Cluster(['10.0.0.X’]) Make sure to replace 127.0.0.1 with the IP of the respective node

$ sudo python solr_dataloader.py

$ ./create_core.sh

Example page of what's in the DB:

https://www.amazon.com/Science-Closer-Look-Grade-6/dp/0022841393?ie=UTF8&keywords=0022841393&qid=1454964627&ref_=sr_1_1&sr=8-1

Create the click stream data table. Inside cqlsh, create the tables you’ll need:

use retailer;

CREATE TABLE retailer.clicks (
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

And book metadata:

CREATE TABLE retailer.metadata (
    asin text PRIMARY KEY,
    also_bought set<text>,
    buy_after_viewing set<text>,
    categories set<text>,
    imurl text,
    price double,
    solr_query text,
    title text
);

So, what are the things you can do?

Filter queries: These are awesome because the result set gets cached in memory.

SELECT * FROM retailer.metadata WHERE solr_query='{"q":"title:Noir~", "fq":"categories:Books", "sort":"title asc"}' limit 10; 

Faceting: Get counts of fields

SELECT * FROM retailer.metadata WHERE solr_query='{"q":"title:Noir~", "facet":{"field":"categories"}}' limit 10; 

Geospatial Searches: Supports box and radius

SELECT * FROM retailer.clicks WHERE solr_query='{"q":"asin:*", "fq":"+{!geofilt pt=\"37.7484,-122.4156\" sfield=location d=1}"}' limit 10; 

For more info, check out: 

https://cwiki.apache.org/confluence/display/solr/Spatial+Search

Joins: Not your relational joins. These queries 'borrow' indexes from other tables to add filter logic. These are fast!

SELECT * FROM retailer.metadata WHERE solr_query='{"q":"*:*", "fq":"{!join from=asin to=asin force=true fromIndex=retailer.clicks}area_code:415"}' limit 5; 

Fun all in one.

SELECT * FROM retailer.metadata WHERE solr_query='{"q":"*:*", "facet":{"field":"categories"}, "fq":"{!join from=asin to=asin force=true fromIndex=retailer.clicks}area_code:415"}' limit 5;

Want to see a really cool example of a live DSE Search app? Check out KillrVideo and its Git to see it in action:

http://www.killrvideo.com

https://github.com/luketillman/killrvideo-csharp
