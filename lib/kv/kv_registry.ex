defmodule KV.Registry do
    use GenServer

    def start_link(table, event_manager, buckets, opts \\ []) do
        # {:ok, manager} = :gen_event.start_link()
        # GenServer.start_link(__MODULE__, manager, name: name)

        # 1. We now expect the table as argument and pass it to the server
        GenServer.start_link(__MODULE__, {table, event_manager, buckets}, opts)
    end
    
    def stop(server) do
        GenServer.stop(server)
    end

    def lookup(table, name) do
        # GenServer.call(server, {:lookup, name})

        # 2. lookup now expects a table and looks directly into ETS.
        # No request is sent to the server.
        case :ets.lookup(table, name) do
            [{^name, bucket}] -> {:ok, bucket}
            [] -> :error
        end
    end

    def create(server, name) do
        GenServer.call(server, {:create, name})
    end

    def init({table, event_manager, buckets}) do
        refs = :ets.foldl(fn {name, pid}, acc ->
            Map.put(acc, Process.monitor(pid), name) 
        end, Map.new, table)
        # 用:ets.foldl/3来遍历表中所有条目，类似于Enum.reduce/3。
        # 它为每个条目执行提供的函数，并且用一个累加器累加结果。 在函数回调中，
        # 我们监视每个表中的pid，并相应地更新存放引用信息的字典。 如果有某个条目是挂掉的，
        # 我们还能收到:DOWN消息，稍后可以清除它们。
        
        {:ok, %{names: table, refs: refs, events: event_manager, buckets: buckets}}
    end

    # 4. The previous handle_call callback for lookup was removed
    # def handle_call({:lookup, name}, _from, state) do
    #     {:reply, Map.fetch(state.names, name), state}
    # end

    def handle_call({:create, name}, _from, state) do
        # if Map.has_key?(state.names, name) do
        #     {:noreply, state}
        # else
        #     {:ok, pid} = KV.Bucket.Supervisor.start_bucket()
        #     ref = Process.monitor(pid) # 开始监视调用进程中的给定项
        #     refs = Map.put(state.refs, ref, name)
        #     names = Map.put(state.names, name, pid)
        #     # 3. Push a notification to the event manager on create
        #     # :gen_event.sync_notify(state.events, {:create, name, pid})# 向事件管理器发送事件通知
        #     {:noreply, %{state | names: names, refs: refs}}
        # end

        # 5. Read and write to the ETS table instead of the HashDict
        case :ets.lookup(state.names, name) do
            {:ok, pid} -> 
                {:noreply, state}
            :error ->
                {:ok, pid} = KV.Bucket.Supervisor.start_bucket()
                ref = Process.monitor(pid)
                refs = Map.put(state.refs, ref, name)
                :ets.insert(state.names, {name, pid})
                :gen_event.sync_notify(state.events, {:create, name, pid})
                {:noreply, %{state | refs: refs}}
        end
    end

    # Process.monitor(pid),一旦被监视的进程死亡，将以下形式向监视进程传递消息：
    # {:DOWN, ref, :process, object, reason}
    def handle_info({:DOWN, ref, :process, pid, _reason}, state) do
        # 5. Delete from the ETS table instead of the HashDict
        {name, refs} = Map.pop(state.refs, ref)
        :ets.delete(state.names, name)
        :gen_event.sync_notify(state.events, {:exit, name, pid})
        {:noreply, %{state | refs: refs}}
    end

    def handle_info(_msg, state) do
        {:noreply, state}
    end
end

defmodule Forwarder do
    use GenEvent
  
    def handle_event(event, parent) do
      send parent, event
      {:ok, parent}
    end
end