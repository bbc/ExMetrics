defmodule ExMetrics.Application do
  use Application

  def start(_type, args) do
    children = children(args)

    opts = [strategy: :one_for_one, name: ExMetrics.Supervisor, max_restarts: 10_000]
    Supervisor.start_link(children, opts)
  end

  defp children(env: :test) do
    children(env: :prod) ++
      [
        Plug.Cowboy.child_spec(
          scheme: :http,
          plug: Test.Support.FakePlugApp,
          options: [port: 8300]
        )
      ]
  end

  defp children(_) do
    import Supervisor.Spec

    [
      worker(ExMetrics.Statsd.Worker, [])
    ]
  end
end
