defmodule Chord.Application do
  use Application

  def start(_type, _args) do
    children = [
      Chord.NodeSupervisor,
      Chord.Stabilize,
      {Chord.Driver, {1000, 25, 0}}
    ]

    opts = [strategy: :one_for_one, name: Chord.Supervisor]
    Supervisor.start_link(children, opts)
  end
end