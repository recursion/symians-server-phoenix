defmodule SymiansServer.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # create a default world and generate some locations in it
    world = Syms.create_world("default")
    Syms.World.generate(world, {30, 30, 30})

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(SymiansServer.Repo, []),
      # Start the endpoint when the application starts
      supervisor(SymiansServerWeb.Endpoint, []),
      # Start your own worker by calling: SymiansServer.Worker.start_link(arg1, arg2, arg3)
      # worker(SymiansServer.Worker, [arg1, arg2, arg3]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SymiansServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SymiansServerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
