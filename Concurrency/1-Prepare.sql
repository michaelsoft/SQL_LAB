-- 1. Preparation
create database Test
go

create table Account (AccountID int primary key, Balance decimal)
go

insert into Account 
  select 1, 100

select * from dbo.Account

update dbo.Account set Balance = 100 where AccountId=1

