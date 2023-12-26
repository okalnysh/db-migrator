    declare @ScriptName varchar(256) = 'test3';
    set nocount on;
    set xact_abort on;

    if not exists(select 1 from okay.MigrationsLog ul where ul.ScriptName = @ScriptName)
    begin
        exec okay.SetScriptStarted @ScriptName;
        begin transaction;
        begin try

            waitfor delay '00:00:12';

            commit;
        end try
        begin catch
            if @@trancount > 0 rollback;
            throw;
        end catch;
        exec okay.SetScriptEnded @ScriptName;
    end
    go
