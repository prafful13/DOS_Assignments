defmodule Chord.Application do
  use Application

  def start(_type, _args) do
    children = [
      Chord.NodeSupervisor,
      Chord.Stabilize,
      {Chord.Driver, {10000, 5, 0}}
    ]

    opts = [strategy: :one_for_all, name: Chord.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
