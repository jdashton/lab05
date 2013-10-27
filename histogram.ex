#!/usr/bin/env elixir

defmodule NumbersInput do
  def start do
    IO.stream(:stdio, :line)
    |> Stream.flat_map(&tokenize/1)
    |> Stream.take_while(&(&1 > -1))
  end
  
  defp tokenize(line) do
    line
    |> String.split(" ")
    |> Stream.map(&String.to_integer/1)
    |> Stream.filter(&match?({_, _}, &1))
    |> Enum.map(&elem(&1, 0))
  end
end


defmodule Histogram do
  def compute(numbers) do
    Enum.reduce(numbers, new, &add_histogram/2)
  end

  defp new do
    (0..5)
    |> Enum.map(&{&1, 0})
    |> HashDict.new
  end

  defp add_histogram(num, histogram) do
    Dict.update(
      histogram, 
      min(5, div(num, 100)),
      1,
      &(&1 + 1)
    )
  end


  def print(histogram) do
    histogram
    |> normalize
    |> output
  end

  defp normalize(histogram) do
    max_values = max(max_values(histogram), 1)

    histogram
    |> Enum.sort(&(elem(&1, 0) < elem(&2, 0)))
    |> Enum.map(&histogram_data(&1, max_values))
  end

  defp max_values(histogram) do
    histogram
    |> Enum.max_by(&elem(&1, 1))
    |> elem(1)
  end

  defp histogram_data({region, count}, max_values) do
    {
      caption(region),
      count,
      round(count * 50 / max_values) |> stars
    }
  end


  defp caption(5), do: "500+ "
  defp caption(n), do: "#{n * 100}-" <> one_less(n)
  defp one_less(n), do: (n < 1 && " " || "") <> "#{(n + 1) * 100 - 1}"

  defp stars(n), do: :lists.duplicate(n, "*") |> Enum.join


  defp output(prepared_histogram) do
    Enum.each(prepared_histogram, &print_line/1)
    IO.puts ""
  end

  defp print_line({caption, count, stars}) do
    :io.format("~15s ~3w|~s~n", [caption, count, stars])
  end
end


NumbersInput.start
|> Histogram.compute
|> Histogram.print
