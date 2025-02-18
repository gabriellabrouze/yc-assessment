defmodule YC.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      YCWeb.Telemetry,
      YC.Repo,
      {DNSCluster, query: Application.get_env(:yc_assessment, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: YC.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: YC.Finch},
      # Start a worker by calling: YC.Worker.start_link(arg)
      # {YC.Worker, arg},
      # Start to serve requests, typically the last entry
      YCWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: YC.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    YCWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
