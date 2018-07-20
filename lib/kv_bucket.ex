defmodule KV.Bucket do

    def start_link() do
        Agent.start_link(fn -> %{} end, name: __MODULE__)
    end

    def get(bucket, k) do
        Agent.get(bucket, &(Map.get(&1, k)))
    end

    def put(bucket, k, v) do
        Agent.update(bucket, &(Map.put(&1, k, v)))
    end

    def delete(bucket, k) do
        Agent.get_and_update(bucket, &(Map.pop(&1, k)))
    end
end
