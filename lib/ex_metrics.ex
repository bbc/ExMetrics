defmodule ExMetrics do
  @stat_types [:timing, :increment, :decrement, :gauge, :set, :histogram]

  @stat_types
  |> Enum.each(fn stat_type ->
    def unquote(stat_type)(metric, value \\ 1, opts \\ []) do
      GenServer.cast(
        ExMetrics.Statsd.Worker,
        {unquote(stat_type), [metric, Kernel.trunc(value), opts]}
      )
    end
  end)

  defmacro timeframe(key, do: yield) do
    quote do
      before_time = System.monotonic_time(:millisecond)
      result = unquote(yield)
      diff = (System.monotonic_time(:millisecond) - before_time) |> abs

      ExMetrics.timing(unquote(key), diff)
      result
    end
  end

  defmacro __using__(_) do
    quote do
      import ExMetrics
    end
  end
end
