# KV

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `kv` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:kv, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/kv](https://hexdocs.pm/kv).

mix.exs
当你编译代码的时候，Elixir把编译产出都置于_build目录。 但是，有些时候Elixir为了避免一些不必要的复制操作， 会在_build目录中创建一些链接指向特定文件而不是copy。 当:build_embedded选项被设置为true时可以制止这种行为， 从而在_build目录中提供执行程序所需的所有文件
类似地，当:start_permanent选项设置为true的时候，程序会以“Permanent模式”执行。 意思是如果你的程序的监督树挂掉，Erlang虚拟机也会挂掉。 注意在:dev和:test环境中，我们可能不需要这样的行为。 因为在这些环境中，为了troubleshooting等目的，需要保持虚拟机持续运行。