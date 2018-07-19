defmodule KVRegistryTest do
    use ExUnit.Case, async: true
  
    setup do
        # {:ok, registry} = KVRegistry.start_link() # registry is pid
        # {:ok, registry: registry} 
        {:ok, manager} = GenEvent.start_link()
        {:ok, registry} = KVRegistry.start_link(manager)

        GenEvent.add_mon_handler(manager, Forwarder, self())
        {:ok, registry: registry}
    end

    test "spawns buckets", %{registry: registry} do
        assert KVRegistry.lookup(registry, "shopping") == :error

        KVRegistry.create(registry, "shopping")
        assert {:ok, bucket} = KVRegistry.lookup(registry, "shopping")

        KVBucket.put(bucket, "milk", 1)
        assert KVBucket.get(bucket, "milk") == 1
    end

    test "removes buckets on exit", %{registry: registry} do
        KVRegistry.create(registry, "shopping")
        {:ok, bucket} = KVRegistry.lookup(registry, "shopping")
        Agent.stop(bucket)
        assert KVRegistry.lookup(registry, "shopping") == :error
    end

    test "sends events on create and crash", %{registry: registry} do
        KVRegistry.create(registry, "shopping")
        {:ok, bucket} = KVRegistry.lookup(registry, "shopping")
        assert_receive {:create, "shopping", ^bucket}
      
        Agent.stop(bucket)
        assert_receive {:exit, "shopping", ^bucket} # 默认是500毫秒超时时间
    end

end