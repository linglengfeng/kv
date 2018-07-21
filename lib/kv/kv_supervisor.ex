defmodule KV.Supervisor do
    use Supervisor

    @manager_name KV.EventManager
    @registry_name KV.Registry
    @ets_registry_name KV.Registry
    @bucket_sup_name KV.Bucket.Supervisor

    def start_link do
        Supervisor.start_link(__MODULE__, :ok)
    end

    def init(:ok) do
        # # worker会调用KV.Registry.start_link(KV.Registry)时启动一个进程
        # children = [
        #     # worker(KV.Registry, [KV.Registry]),
        #     supervisor(KV.Bucket.Supervisor, [])
        # ]

        ets = :ets.new(@ets_registry_name, [:set, :public, :named_table, read_concurrency: true])

        children = [
            worker(GenEvent, [[name: @manager_name]]),
            supervisor(KV.Bucket.Supervisor, [[name: @bucket_sup_name]]),
            worker(KV.Registry, [@ets_registry_name, @manager_name,
                                @bucket_sup_name, [name: @registry_name]])
        ]
        supervise(children, strategy: :one_for_one)
    end


end