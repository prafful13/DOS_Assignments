defmodule Scheduler do
  def run(n, module, func, args, k) do
    # IO.puts(Node.connect(:"aswin@Aswins-MacBook-Pro"))

    IO.puts(Node.connect(:prafful@Prafful))
    IO.inspect(Node.list())
    IO.puts(Node.self())


    if (ConnectNode.connect() == true) do
      run_multiple_node(n, module, func, args, k)
    else
      run_single_node(n, module, func, args, k)
    end
  end

  defp run_single_node(n, module, func, args, k) do
    1..n
    |> Enum.map(fn _ -> spawn(module, func, [self()]) end)
    |> schedule_processes(args, k, [])
  end

  defp run_multiple_node(n, module, func, args, k) do

  #{args1,args2} = Enum.split_with(args,fn(x) -> rem(x, 2) == 0 end)
  processes1 = 1..round(Float.ceil(n/2))
    |> Enum.map(fn _ -> Node.spawn(:prafful@Prafful  ,module, func, [self()]) end)

      #schedule_processes(args1, k, [])
  processes2 = round(Float.ceil(n/2))+1..n
    |> Enum.map(fn _ -> spawn(module, func, [self()]) end)
  processes = processes1 ++ processes2

  #IO.inspect [length(processes), length(processes1), length(processes2)]

  schedule_processes(processes,args, k, [])

  end

  defp schedule_processes(processes, args, k, results) do
    receive do
      {:ready, pid} when args != [] ->
        [next | tail] = args
        send(pid, {:work, next, k, self()})
        schedule_processes(processes, tail, k, results)

      {:ready, pid} ->
        send(pid, {:shutdown})

        if length(processes) > 1 do
          schedule_processes(List.delete(processes, pid), args, k, results)
        else
          results
        end

      {:answer, number, comp, pid} ->
        if comp == 0 do
          schedule_processes(List.delete(processes, pid), args, k, [number] ++ results)
        else
          schedule_processes(List.delete(processes, pid), args, k, results)
        end
    end
  end
end

defmodule ConnectNode do
  def connect do
    Node.connect(:prafful@Prafful)
  end
end

defmodule Worker do
  def work(scheduler) do
    send(scheduler, {:ready, self()})

    receive do
      {:work, i, k, client} ->
        sum = calc(i, k, i)
        m = :math.sqrt(sum)
        comp = m - :math.floor(m)
        send(client, {:answer, i, comp, self()})

        # IO.puts(Node.self())

        work(scheduler)

      {:shutdown} ->
        exit(:normal)
    end
  end

  # very inefficient, deliberately
  defp calc(i, k, j) do
    if(i == j + k - 1) do
      i * i
    else
      i * i + calc(i + 1, k, j)
    end
  end
end


defmodule Multi_test do
  def find(n,k) do
    #args = System.argv()
args = System.argv()
# IO.puts String.to_integer(Enum.at(args, 1))
# 1_000_000
n = String.to_integer(Enum.at(args, 0))
to_calculate = Enum.map(1..n, fn x -> x end)
# 4
k = String.to_integer(Enum.at(args, 1))

{time, result} =
  :timer.tc(
    Scheduler,
    :run,
    [100, Worker, :work, to_calculate, k]
  )

    :io.format("~6B    ~.6f~n", [100, time / 1_000_000.0])
  end
end

