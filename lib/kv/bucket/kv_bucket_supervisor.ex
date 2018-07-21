defmodule KV.Bucket.Supervisor do
    use Supervisor

    # @name KV.Bucket.Supervisor

    def start_link(opts) do
        Supervisor.start_link(__MODULE__, :ok, opts)
    end

    # 定义了函数start_bucket/0来启动每个bucket， 
    # 作为这个名为KV.Bucket.Supervisor的监督者的孩子。 
    # 函数start_bucket/0代替了注册表进程中直接调用的KV.Bucket.start_link。
    def start_bucket() do
        Supervisor.start_child(@name, [])
    end

    # restart() :: :permanent | :transient | :temporary
    def init(:ok) do
        children = [
            worker(KV.Bucket, [], restart: :temporary)#将进程标记为:temporary，意思是如果bucket进程即使挂了也不重启
        ]

        supervise(children, strategy: :simple_one_for_one)
    end
end