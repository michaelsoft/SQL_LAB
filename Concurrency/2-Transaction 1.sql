
-- 2. Run this first
set transaction isolation level Repeatable read; -- Read uncommitted, Read committed, Repeatable read, Serializable
go

declare @balance decimal 
begin tran
   select @balance=balance from dbo.Account where AccountId=1

   waitfor delay '00:00:03'

   update dbo.Account set Balance = @balance - 10 where AccountId=1

commit tran