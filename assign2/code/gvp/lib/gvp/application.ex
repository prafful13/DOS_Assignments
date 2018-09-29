defmodule Gvp.Application do
  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Gvp.Worker.start_link(arg)
      # {Gvp.Worker, arg},
      {Gvp.Gossip.Driver, {num_of_nodes, topology}},
      Gvp.Gossip.NodeSupervisor
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_all, name: Gvp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end