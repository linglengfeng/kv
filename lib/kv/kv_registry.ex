defmodule KV.Registry do
    use GenServer

    def start_link(name) do
        {:ok, manager} = :gen_event.start_link()
        # 1. start_link now expects the event manager as argument
        GenServer.start_link(__MODULE__, manager, name: name)
    end
    
    def stop(server) do
        GenServer.stop(server)
    end

    def lookup(server, name) do
        GenServer.call(server, {:lookup, name})
    end

    def create(server, name) do
        GenServer.cast(server, {:create, name})
    end

    def init(events) do
        # 2. The init callback now receives the event manager.
        #    We have also changed the manager state from a tuple
        #    to a map, allowing us to add new fields in the future
        #    without needing to rewrite all callbacks.
        names = Map.new
        refs  = Map.new
        {:ok, %{names: names, refs: refs, events: events}}
    end

    def handle_call({:lookup, name}, _from, state) do
        {:reply, Map.fetch(state.names, name), state}
    end

    def handle_cast({:create, name}, state) do
        if Map.has_key?(state.names, name) do
            {:noreply, state}
        else
            {:ok, pid} = KV.Bucket.Supervisor.start_bucket()
            ref = Process.monitor(pid) # 开始监视调用进程中的给定项
            refs = Map.put(state.refs, ref, name)
            names = Map.put(state.names, name, pid)
            # 3. Push a notification to the event manager on create
            # :gen_event.sync_notify(state.events, {:create, name, pid})# 向事件管理器发送事件通知
            {:noreply, %{state | names: names, refs: refs}}
        end
    end

    # Process.monitor(pid),一旦被监视的进程死亡，将以下形式向监视进程传递消息：
    # {:DOWN, ref, :process, object, reason}
    def handle_info({:DOWN, ref, :process, pid, _reason}, state) do
        {name, refs} = Map.pop(state.refs, ref)
        names = Map.delete(state.names, name)
        # 4. Push a notification to the event manager on exit
        # :gen_event.sync_notify(state.events, {:exit, name, pid})
        {:noreply, %{state | names: names, refs: refs}}
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