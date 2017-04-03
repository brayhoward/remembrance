defmodule Remembrance do
  @moduledoc """
  Documentation for Remembrance, a command-line app for setting timers.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Remembrance.main ["0", "0", "4"]
      {:ok, "0 hours 0 minutes 4 seconds"}

      Remembrance.main []
      {:ok, "0 hours 3 minutes 0 seconds"}

      Remembrance.main ["3"]
      {:ok, "0 hours 3 minutes 0 seconds"}

      Remembrance.main ["1", "3", "6"]
      {:ok, "1 hours 3 minutes 6 seconds"}

      Remembrance.main ["0", "5", "30"]
      {:ok, "0 hours 5 minutes 30 seondsc"}

      Remembrance.main ["1", "3"]
      {:ok, "1 hours 3 minutes 0 seconds"}

  """
  def main(args) do
    args
    |> parse_args
    |> process
  end

  #
  ## Private AF
  #

  defp process(time_map) do
    %{hr: hr, min: min, sec: sec} = time_map
    milliseconds = :timer.hms hr, min, sec
    print_timer_set_confirmation(time_map)

    :timer.sleep(milliseconds)
    indicate_time_elapsed(time_map)

    {:ok, humanize_time_map(time_map)}
  end

  defp indicate_time_elapsed(time_map) do
    print_alert_message(time_map)
    System.cmd "printf", ["\a"]
    System.cmd "say", [timer_elapsed_message(time_map)]
  end

  defp parse_args(args) do
    nums = map_to_int args

    case length nums do
      0 ->
        IO.puts "No arguments given"
        # Default to 3 min if no args passed
        parse_args ["3"]

      1 ->
        %{hr: 0, min: List.first(nums), sec: 0}

      2 ->
        [ hr | tail ] = nums
        %{hr: hr, min: List.first(tail), sec: 0}

      # Take top three args and ignore any others.
      _ ->
        [hr | tail] = nums
        [min | tail] = tail
        [sec | _] = tail
        %{hr: hr, min: min, sec: sec}
    end
  end

  defp map_to_int(args) do
    Enum.map args, &(to_int &1)
  end

  defp to_int(arg) do
    case Integer.parse arg do
      {num, _} -> num

      :error ->
        exit_gracfully()
    end
  end

  defp exit_gracfully do
    offer_feedback()
    exit(:shutdown)
  end

  ### User messaging funcitons bellow ###

  defp humanize_time_map(%{hr: hr, min: min, sec: sec}), do: "#{hr} hours #{min} minutes #{sec} seconds"

  defp print_alert_message(time_map) do
    IO.puts """
      Ding Ding ⏰
      #{timer_elapsed_message(time_map)}
    """
  end

  defp timer_elapsed_message(time_map) do
    "Your timer set for #{humanize_time_map(time_map)} has elapsed."
  end

  defp print_timer_set_confirmation(time_map) do
    %{hr: hr, min: min, sec: sec} = time_map
    time = humanize_time_map(time_map)
    IO.puts "Timer set for #{time}\n"

    if min === 3 && hr === 0 && sec === 0 do
      IO.puts "Don't oversteep that tea! 🍵"
    end

    {:ok, time}
  end

  defp offer_feedback() do
    IO.puts """

      ERROR
      Only Pass whole numbers as arguments
      Example: `./remembrance 1 30`

      "Timer set for 1 hr 30 min 0 sec"
      """
  end
end
