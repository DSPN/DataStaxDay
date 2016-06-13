Hands On Cassandra Consistency

Let's play with consistency!
Consistency in Cassandra refers to the number of acknowledgements replica nodes need to send to the coordinator for an operation to be successful while also providing good data (avoiding dirty reads).

We recommend a ** default replication factor of 3 and consistency level of LOCAL_QUORUM as a starting point**. You will almost always get the performance you need with these default settings.

In some cases, developers find Cassandra's replication fast enough to warrant lower consistency for even better latency SLA's. For cases where very strong global consistency is required, possibly across data centers in real time, a developer can trade latency for a higher consistency level.

Let's give it a shot.

This DeathStar is Operational!
First, we will shutdown one of the nodes so you can see the CAP theorem in action. Go to your browser, and access OpsCenter:

http://<opscenter ip address>:8888



Select Nodes tab:



The Nodes view will now appear:



Now, select one of the nodes and double-click on it:



Finally, choose the Actions… drop down and select Stop:



In CQLSH:

cqlsh> tracing on
cqlsh> consistency all

Any query will now be traced. Consistency of all means all 3 replicas need to respond to a given request (read OR write) to be successful. Let's do a SELECT statement to see the effects.

cqlsh> SELECT * FROM retailer.sales where name='<enter name>';

How did we do?

Let's compare a lower consistency level: 

cqlsh> consistency local_quorum

Quorum means majority: RF/2 + 1. In our case, 3/2 = 1 + 1 = 2. At least 2 nodes need to acknowledge the request.

Let's try the SELECT statement again. Any changes in latency?

Keep in mind that our dataset is so small, it's sitting in memory on all nodes. With larger datasets that spill to disk, the latency cost become much more drastic.

Let's try this again but this time, let's pay attention to what's happening in the trace

cqlsh> consistency local_one

cqlsh> SELECT * FROM retailer.sales where name='<enter name>';

Take a look at the trace output. Look at all queries and contact points. What you're witnessing is both the beauty and challenge of distributed systems.

cqlsh> consistency local_quorum

cqlsh> SELECT * FROM retailer.sales where name='<enter name>';

This looks much better now doesn't it? LOCAL_QUORUM is the most commonly used consistency level among developers. It provides a good level of performance and a moderate amount of consistency. That being said, many use cases can warrant CL=LOCAL_ONE.

For more detailed classed on data modeling, consistency, and Cassandra 101, check out the free classes at the DataStax Academy website:

https://academy.datastax.com
