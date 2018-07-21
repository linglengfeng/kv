OTP入门
https://github.com/straightdave/advanced_elixir

mix.exs
当你编译代码的时候，Elixir把编译产出都置于_build目录。 但是，有些时候Elixir为了避免一些不必要的复制操作， 会在_build目录中创建一些链接指向特定文件而不是copy。 当:build_embedded选项被设置为true时可以制止这种行为， 从而在_build目录中提供执行程序所需的所有文件
类似地，当:start_permanent选项设置为true的时候，程序会以“Permanent模式”执行。 意思是如果你的程序的监督树挂掉，Erlang虚拟机也会挂掉。 注意在:dev和:test环境中，我们可能不需要这样的行为。 因为在这些环境中，为了troubleshooting等目的，需要保持虚拟机持续运行。

让它不要启动我们的应用程序。 执行命令：iex -S mix run --no-start,mix help run获取更多帮助

介绍观察者工具（Observer tool。 该工具和Erlang一同推出。使用iex -S mix启动你的应用程序，输入：iex> :observer.start

give_away(Tab, Pid, GiftData) -> true
让进程Pid成为表Tab的新的拥有者。
     Types:
        Tab = tid() | atom()
         Pid = pid()
         GiftData = term()

ets:new(Name, Options)
:ets.new(:shopping, [ :bag, :protected, :named_table, read_concurrency: true,[:heir, pid, []] ])
    {heir, Pid, HeirData},{heir,none}
    这个heir属性指明当创建table的process终止时，是否有其他process来继承这个table，默认值是{heir,none},表示没有继承者，所以当创建表的process终止时，表也随之被delete；若我们指定了{heir,Pid,HeirData}，那么当创建表的process终止时，process identifer为Pid的process将会收到一个消息：{'ETS-TRANSFER',tid(),FromPid,HeirData},这样表的拥有权就转交了，
