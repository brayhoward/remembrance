defmodule Remembrance do
  @moduledoc """
  Documentation for Remembrance, a command-line app for setting timers.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Remembrance.main ["0", "0", "4"]
      {:ok, "0 hours 0 minutes 4 seconds"}

      iex> Remembrance.main ["-h"]
      {:ok, :help_docs}

      iex> Remembrance.main ["0", "foo", "4"]
      {:ok, :help_docs}

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
    case parse_args(args) do
      :error ->
        print_help_docs()
        {:ok, :help_docs}

      {:ok, time_map} ->
        time_map
        |> set_timeout
        |> indicate_time_elapsed
    end
  end

  #
  ## Private AF
  #

  defp set_timeout(time_map) do
    %{hr: hr, min: min, sec: sec} = time_map
    milliseconds = :timer.hms hr, min, sec
    print_timer_set_confirmation(time_map)
    :timer.sleep(milliseconds)

    time_map
  end

  defp indicate_time_elapsed(time_map) do
    print_alert_message(time_map)
    System.cmd "tput", ["\a"]
    System.cmd "say", [timer_elapsed_message(time_map)]

    {:ok, humanize_time_map(time_map)}
  end

  defp parse_args(args) do
    case List.first(args) === "-h" do
      true -> :error

      false -> process_args_list(args)
    end
  end

  defp process_args_list(args) do
    nums_list = map_to_ints(args)

    case Enum.any?( nums_list, &(:error === &1)) do
      true -> :error

      false -> {:ok, build_time_map(nums_list)}
    end
  end

  defp build_time_map([]) do
    IO.puts "No arguments given"
    # Default to 3 if no args passed
    build_time_map([3])
  end

  defp build_time_map(nums) do
    case length nums do
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

  defp map_to_ints(args) do
    Enum.map args, &(to_int &1)
  end

  defp to_int(arg) do
    case Integer.parse arg do
      {num, _} -> num

      :error -> :error
    end
  end

  # defp exit_gracfully do
  #   offer_feedback()
  #   exit(:shutdown)
  # end

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

  defp print_help_docs() do
    IO.puts """

      To set time pass whole numbers as arguments.
      First argument being the hours, second the minutes, and third the seconds.

      Example: `./remembrance 1 30 0`
      "Timer set for 1 hr 30 min 0 sec"


      If no arguments are passed the timer will default 3 minutes.

      Example: `./remembrance`
      "Timer set for 0 hr 3 min 0 sec"


      If only one argument is passed it timer will set for minutes.

      Example: `./remembrance 5`
      "Timer set for 0 hr 5 min 0 sec"


      If two arguments are passed the timer will set for hours and minutes

      Example: `./remembrance 1 30`
      "Timer set for 1 hr 30 min 0 sec"


      To set hours minutes and seconds pass three arguments.

      Example: `./remembrance 1 25 30`
      "Timer set for 1 hr 25 min 30 sec"


      Pass 0 for any time units that you do not want to set.

      Example: `./remembrance 0 0 45`
      "Timer set for 0 hr 0 min 45 sec"

      """
  end
end
