    use Pipedrive;
    go

    declare @ScriptName varchar(256) = 'test3';
    set nocount on;
    set xact_abort on;

    if not exists(select 1 from utils.UpdateScriptsLog ul where ul.ScriptName = @ScriptName)
    begin
        exec utils.UpdateScriptStarted @ScriptName;
        begin transaction;
        begin try

            select 3;

            commit;
        end try
        begin catch
            if @@trancount > 0 rollback;
            throw;
        end catch;
        exec utils.UpdateScriptEnded @ScriptName;
    end
    go
