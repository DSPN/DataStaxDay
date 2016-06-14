create keyspace if not exists primary_keys_ks with replication = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 };

use primary_keys_ks;

create table sentiment1 (
body text,         // social message body text
dt int,            // date of message
ch text,           // social channel
cu text,           // customer
sent text,         // sentiment indicator
primary key (dt)
);

create table sentiment2 (
body text,
dt int,
ch text,
cu text,
sent text,
primary key ((ch,dt))
);

create table sentiment3 (
body text,
dt int,
ch text,
cu text,
sent text,
primary key (ch,dt)
);

create table sentiment4 (
body text,
dt int,
ch text,
cu text,
sent text,
primary key (ch,cu,dt)
);

create table sentiment5 (
body text,
dt int,
ch text,
cu text,
sent text,
primary key ((ch,dt),cu)
);

begin batch
insert into sentiment1 (body,dt,ch,cu,sent) values ('I am feeling sick.',20160102,'twitter','red bull','negative');
insert into sentiment2 (body,dt,ch,cu,sent) values ('I am feeling sick.',20160102,'twitter','red bull','negative');
insert into sentiment3 (body,dt,ch,cu,sent) values ('I am feeling sick.',20160102,'twitter','red bull','negative');
insert into sentiment4 (body,dt,ch,cu,sent) values ('I am feeling sick.',20160102,'twitter','red bull','negative');
insert into sentiment5 (body,dt,ch,cu,sent) values ('I am feeling sick.',20160102,'twitter','red bull','negative');
apply batch;

begin batch
insert into sentiment1 (body,dt,ch,cu,sent) values ('That was sick!',20160101,'facebook','red bull','positive');
insert into sentiment2 (body,dt,ch,cu,sent) values ('That was sick!',20160101,'facebook','red bull','positive');
insert into sentiment3 (body,dt,ch,cu,sent) values ('That was sick!',20160101,'facebook','red bull','positive');
insert into sentiment4 (body,dt,ch,cu,sent) values ('That was sick!',20160101,'facebook','red bull','positive');
insert into sentiment5 (body,dt,ch,cu,sent) values ('That was sick!',20160101,'facebook','red bull','positive');
apply batch;

begin batch
insert into sentiment1 (body,dt,ch,cu,sent) values ('I feel sick, too.',20160102,'facebook','dew tour','negative');
insert into sentiment2 (body,dt,ch,cu,sent) values ('I feel sick, too.',20160102,'facebook','dew tour','negative');
insert into sentiment3 (body,dt,ch,cu,sent) values ('I feel sick, too.',20160102,'facebook','dew tour','negative');
insert into sentiment4 (body,dt,ch,cu,sent) values ('I feel sick, too.',20160102,'facebook','dew tour','negative');
insert into sentiment5 (body,dt,ch,cu,sent) values ('I feel sick, too.',20160102,'facebook','dew tour','negative');
apply batch;

begin batch
insert into sentiment1 (body,dt,ch,cu,sent) values ('Dude, you are sick.',20160103,'facebook','red bull','positive');
insert into sentiment2 (body,dt,ch,cu,sent) values ('Dude, you are sick.',20160103,'facebook','red bull','positive');
insert into sentiment3 (body,dt,ch,cu,sent) values ('Dude, you are sick.',20160103,'facebook','red bull','positive');
insert into sentiment4 (body,dt,ch,cu,sent) values ('Dude, you are sick.',20160103,'facebook','red bull','positive');
insert into sentiment5 (body,dt,ch,cu,sent) values ('Dude, you are sick.',20160103,'facebook','red bull','positive');
apply batch;

begin batch
insert into sentiment1 (body,dt,ch,cu,sent) values ('How sick was that?',20160103,'facebook','monster energy','positive');
insert into sentiment2 (body,dt,ch,cu,sent) values ('How sick was that?',20160103,'facebook','monster energy','positive');
insert into sentiment3 (body,dt,ch,cu,sent) values ('How sick was that?',20160103,'facebook','monster energy','positive');
insert into sentiment4 (body,dt,ch,cu,sent) values ('How sick was that?',20160103,'facebook','monster energy','positive');
insert into sentiment5 (body,dt,ch,cu,sent) values ('How sick was that?',20160103,'facebook','monster energy','positive');
apply batch;

