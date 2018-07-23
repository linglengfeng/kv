defmodule KV.Router do
    
    def route(bucket, mod, fun, args) do
        first = :binary.first(bucket)

        entry =
            Enum.find(table, fn {enum, node} ->
                first in enum 
            end) || no_entry_error(bucket)

        if elem(entry, 1) == node() do
            apply(mod, fun, args)
        else
            sup = {KV.RouterTasks, elem(entry, 1)}
            Task.Supervisor.async(sup, fn ->
                KV.Router.route(bucket, mod, fun, args)
            end) |> Task.await()
        end
    end

    defp no_entry_error(bucket) do
        raise "could not find entry for #{inspect bucket} in table #{inspect table}"
    end

    def table() do
        Application.get_env(:kv, :routing_table)
    end
end