# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :ex_metrics,
  metrics: ["test_metric_name", "time_await"]

if File.regular?("config/#{Mix.env()}.exs") do
  import_config "#{Mix.env()}.exs"
end
