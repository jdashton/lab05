#!/usr/bin/env elixir

defmodule Lab05 do
  @doc """
  My take on [the histogram exercise]
  (http://computing.southern.edu/halterman/Courses/Fall2013/124/Labs/lab05_F13.html)
  mentioned in [this newsgroup post]
  (https://groups.google.com/d/msg/elixir-lang-talk/TTSjV0iy9yA/hpiGDZOk6DkJ)
  """
  def main(), do: parse_pars(System.argv, nil)
  
  defp parse_pars([], nil), do: histogram()
  defp parse_pars(["-h"|_t], _acc), do: show_help
  defp parse_pars(["--help"|_t], _acc), do: show_help
  defp parse_pars(x, _acc) do
    IO.puts "unexpected parameter: #{x}"
    show_help
  end
  
  defp show_help() do
    IO.puts """

      Usage:
        lab05
        
      Options:
        -h, [--help]      # Show this help message and quit.
        
      Description:
        Read integers from stdin and display a histogram.
        In the default, input may be terminated by a negative number
        or by end-of-file (Ctrl-D).

        All bits that are not parseable as integers are ignored.
        This enables culling of integers from documents containing
        other text.
    """
  end

  defp histogram() do
    IO.stream(:stdio, :line)
      |> Transform.extract_numbers()
      |> Enum.take_while(&(&1 >=0))
      |> Transform.count_ranges
      |> Output.bar_chart
  end
end

defmodule Transform do
  def extract_numbers(stream), do: Stream.flat_map(stream, &extract_numbers_from_line/1)

  defp extract_numbers_from_line(line) do
    Regex.scan( %r/(\-)?\d+/, line)
     |> Stream.map(&hd/1)
     |> Stream.map(&String.to_integer/1)
     |> Stream.reject(&(&1 == nil))
     |> Stream.map(&elem(&1, 0))
  end

  def count_ranges(numbers), do: Enum.reduce(numbers, init_dict, &inc_count/2)

  defp init_dict(), do: Enum.map(0..5, &{get_key(&1 * 100), 0}) |> HashDict.new
  
  defp inc_count(nr, dict), do: Dict.update(dict, get_key(nr), 0, &(&1 + 1))
  
  defp get_key(nr) when nr < 500 do 
    start = div(nr, 100) * 100
    sp = nr < 100 && " " || ""
    "#{start}-#{sp}#{start + 99}"
  end  
  defp get_key(_), do: "500+ "
end

defmodule Output do
  def bar_chart(data, max_bar_length // 50) do
    max_count = Enum.max(Dict.values(data) ++ [1])
    scale = max_bar_length / max_count
    Enum.each data, &print_bar(&1, scale) 
    IO.puts ""
  end
  
  defp print_bar({key, value}, scale) do
    bar = repeat("*", round(value * scale))
    c = String.at(key, 0)
    sp1 = (c < "1" || c > "4") && "  " || ""
    sp2 = value < 10 && " " || ""
    IO.puts "        #{sp1}#{key}  #{sp2}#{value}|#{bar}"
  end
  
  defp repeat(_char, 0), do: ""
  defp repeat(char, len), do: 1..len |> Enum.map_join fn _ -> "#{char}" end
end

Lab05.main()
