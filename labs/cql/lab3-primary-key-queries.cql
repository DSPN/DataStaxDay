use primary_keys_ks;

select * from sentiment1 where dt = 20160102;
select * from sentiment1 where ch = 'facebook' and dt = 20160102;
select * from sentiment1 where ch = 'facebook' and dt > 20160101;

select * from sentiment2 where dt = 20160102;
select * from sentiment2 where ch = 'facebook' and dt = 20160102;
select * from sentiment2 where ch = 'facebook' and dt > 20160101;

select * from sentiment3 where dt = 20160102;
select * from sentiment3 where ch = 'facebook' and dt = 20160102;
select * from sentiment3 where ch = 'facebook' and dt > 20160101;
select * from sentiment3 where ch = 'facebook' and cu = 'red bull' and dt >= 20160102 and dt <= 20160103;
select * from sentiment3 where ch = 'facebook' and dt >= 20160102 and dt <= 20160103;

select * from sentiment4 where dt = 20160102;
select * from sentiment4 where ch = 'facebook' and cu = 'red bull' and dt >= 20160102 and dt <= 20160103;
select * from sentiment4 where ch = 'facebook' and dt >= 20160102 and dt <= 20160103;

select * from sentiment5 where dt = 20160102;
select * from sentiment5 where ch = 'facebook' and dt = 20160102;
select * from sentiment5 where ch = 'facebook' and dt > 20160101;
select * from sentiment5 where ch = 'facebook' and dt >= 20160102 and dt <= 20160103;

