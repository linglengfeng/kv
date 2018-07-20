defmodule KV.Supervisor do
    use Supervisor

    def start_link do
        Supervisor.start_link(__MODULE__, :ok)
    end

    def init(:ok) do
        # worker会调用KV.Registry.start_link(KV.Registry)时启动一个进程
        children = [
            worker(KV.Registry, [KV.Registry]),
            supervisor(KV.Bucket.Supervisor, [])
        ]

        supervise(children, strategy: :rest_for_one)
    end


end