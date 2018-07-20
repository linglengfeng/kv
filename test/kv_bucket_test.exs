defmodule KV.BucketTest do
    use ExUnit.Case, async: true  # :async选项的测试用例并行执行

    # 当在回调函数里返回{:ok, bucket: bucket}的时候， ExUnit会把该返回值元祖（字典）的第二个元素merge进测试上下文中。 
    # 测试上下文是一个图，我们可以在测试用例的定义中匹配它，从而获取这个上下文的值给用例中的代码使用
    setup do
      {:ok, bucket} = KV.Bucket.start_link
      {:ok, bucket: bucket} 
    end
  
    test "stores values by key", %{bucket: bucket} do
      assert KV.Bucket.get(bucket, "milk") == nil
  
      KV.Bucket.put(bucket, "milk", 3)
      assert KV.Bucket.get(bucket, "milk") == 3
    end
end