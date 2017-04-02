defmodule Remembrance do
  @moduledoc """
  Documentation for Remembrance, a command-line app for setting timers.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Remembrance.main []
      {:ok, "0 hr 3 min 0 sec"}

      iex> Remembrance.main ["3"]
      {:ok, "0 hr 3 min 0 sec"}

      iex> Remembrance.main ["1", "30", "6"]
      {:ok, "1 hr 30 min 6 sec"}

      iex> Remembrance.main ["0", "5", "30"]
      {:ok, "0 hr 5 min 30 sec"}

      iex> Remembrance.main ["1", "3"]
      {:ok, "1 hr 3 min 0 sec"}

  """
  def main(args) do
    args
    |> parse_args
    |> process
  end

  def alert_time_elapsed(), do: put_alert_message()
  #
  ## Private AF
  #

  defp process(time_map) do
    case set_timer(time_map) do
      {:ok, time_map} ->
        print_confirmation(time_map)

      error ->
        offer_feedback()
        error
    end
  end

  defp set_timer(time_map) do
    %{hr: hr, min: min, sec: sec} = time_map

    milliseconds = :timer.hms hr, min, sec

    case :timer.apply_after(milliseconds, Remembrance, :alert_time_elapsed, []) do
      {:ok, _} -> {:ok, time_map}

      error -> error
    end
  end

  defp put_alert_message() do

    IO.puts """
      Ding Ding ⏰
      Your requested time has elapsed.
    """
  end

  defp humanize_time_map(%{hr: hr, min: min, sec: sec}), do: "#{hr} hr #{min} min #{sec} sec"

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

  defp offer_feedback() do
    IO.puts """

      ERROR
      Only Pass whole numbers as arguments
      Example: `./remembrance 1 30`

      "Timer set for 1 hr 30 min 0 sec"
      """
  end

  defp exit_gracfully do
    offer_feedback()
    exit(:shutdown)
  end

  defp print_confirmation(time_map) do
    %{hr: hr, min: min, sec: sec} = time_map
    time = humanize_time_map(time_map)
    IO.puts "Timer set for #{time}\n"

    if min === 3 && hr === 0 && sec === 0 do
      IO.puts "Don't oversteep that tea! 🍵"
    end

    {:ok, time}
  end
end
