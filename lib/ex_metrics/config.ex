defmodule ExMetrics.Config do
  def send_metrics? do
    Application.fetch_env!(:ex_metrics, :send_metrics)
  end

  def statsd_host do
    Application.get_env(:ex_metrics, :statsd_host, "localhost")
  end

  @spec statsd_port() :: any()
  def statsd_port do
    Application.get_env(:ex_metrics, :statsd_port, 8125)
  end

  def pool_size do
    Application.get_env(:ex_metrics, :pool_size, 1)
  end
end
