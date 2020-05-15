defmodule ExMetrics.Statsd.Worker do
  use GenServer

  alias ExMetrics.Config

  def init(:ok) do
    set_up_statix()

    connection =
      case Config.send_metrics?() do
        true -> ExMetrics.Statsd.StatixConnection
        _ -> ExMetrics.Statsd.StatixConnectionMock
      end

    connection.init()

    {:ok, connection}
  end

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def handle_cast({statix_command, [metric, value, opts]}, connection) do
    apply(connection, statix_command, [metric, value, opts])
    {:noreply, connection}
  end

  defp set_up_statix do
    Application.put_env(:statix, :host, Config.statsd_host())
    Application.put_env(:statix, :port, Config.statsd_port())
    Application.put_env(:statix, :pool_size, Config.pool_size())
  end
end
