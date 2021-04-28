defmodule ExMetrics.Statsd.Worker do
  use GenServer

  alias ExMetrics.Config

  # TODO: what the best way to add the Logger?
  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # public function to help with debugging
  def ports do
    {:links, ports} = Process.whereis(__MODULE__) |> Process.info(:links)

    ports |> Enum.filter(&is_port(&1))
  end

  def init(:ok) do
    set_up_statix()

    Logger.info("Starting worker")

    connection =
      case Config.send_metrics?() do
        true -> ExMetrics.Statsd.StatixConnection
        _ -> ExMetrics.Statsd.StatixConnectionMock
      end

    connection.init()
    monitor_ports()

    {:ok, connection}
  end

  def handle_cast({statix_command, [metric, value, opts]}, connection) do
    apply(connection, statix_command, [metric, value, opts])

    {:noreply, connection}
  end

  def handle_info({:DOWN, _ref, :port, port, :normal}, connection) do
    Logger.info("Handled :DOWN message from port: #{inspect(port)}")
    # would not make sense to try sending metrics at this stage...

    {:stop, :DOWN, connection}
  end

  def handle_info({:EXIT, port, :normal}, connection) do
    Logger.info("handle_info: EXIT")
    # would not make sense to try sending metrics at this stage...

    {:stop, :EXIT, connection}
  end

  def handle_info(msg, connection) do
    Logger.info("Unhandled message: #{inspect(msg)}")

    {:noreply, connection}
  end

  defp monitor_ports() do
    ports() |> Enum.each(&Port.monitor(&1))
  end

  defp set_up_statix do
    Application.put_env(:statix, :host, Config.statsd_host())
    Application.put_env(:statix, :port, Config.statsd_port())
    Application.put_env(:statix, :pool_size, Config.pool_size())
  end
end
