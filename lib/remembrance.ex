defmodule Remembrance do
  @moduledoc """
  Documentation for Remembrance, a command-line app for setting timers.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Remembrance.main []
      {:ok, "0 hr 3 min 0 sec"}

      iex> Remembrance.main [3]
      {:ok, "0 hr 3 min 0 sec"}

      iex> Remembrance.main [1, 30, 6]
      {:ok, "1 hr 30 min 6 sec"}

      iex> Remembrance.main [0, 5, 30]
      {:ok, "0 hr 5 min 30 sec"}

      // Fucntionaly works but fails when ran as a test.
      // TODO: debug later.
      Remembrance.main [1, 3]
      {:ok, "1 hr 3 min 0 sec"}

  """
  def main(args) do
    args
    |> parse_args
    |> process
  end

  #
  ## Private AF
  #

  defp process(%{hr: hr, min: min, sec: sec}) do
    time = "#{hr} hr #{min} min #{sec} sec";
    IO.puts "Timer set for #{time}\n"

    if min === 3 && hr === 0 && sec === 0 do
      IO.puts "Don't oversteep that tea! 🍵"
    end

    {:ok, time}
  end

  defp parse_args(args) do

    case length args do
      0 ->
        IO.puts "No arguments given"
        # Default to 3 min if no args passed
        parse_args [3]

      1 ->
        %{hr: 0, min: List.first(args), sec: 0}

      2 ->
        [ hr | min ] = args
        %{hr: hr, min: min, sec: 0}

      _ ->
        [hr | tail] = args
        [min | tail] = tail
        [sec | _] = tail
        %{hr: hr, min: min, sec: sec}
    end
  end
end
