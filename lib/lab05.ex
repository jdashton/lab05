defmodule Lab05 do

  def main(args) do
    args |> parse_args |> process |> categorize |> print_histogram
  end

  def parse_args(args) do
    options = OptionParser.parse(args, switches: [help: :boolean],
                                        aliases: [h: :help])
    case options do
      { [help: true], _, _ } -> :help
      _                      -> :read_stdin
    end
  end

  def parse_line(line) do
    line
    |> String.split
    |> Enum.map(&(case String.to_integer(&1) do
                    { res, _ } -> res 
                    _          -> nil
                  end))
    |> Enum.reject(&nil?/1)
  end

  def check_line(line, line_list) do
    l = parse_line(line)
    if Enum.any?(l, &(&1 < 0)) do
      [Enum.take_while(l, &(&1 >= 0))]
    else
      [ l | read_lines(line_list) ]
    end
  end

  def read_lines(line_list) do
    case IO.gets("") do
      {:error, reason}  -> IO.puts "Error: #{:file.format_error(reason)}"
      :eof              -> line_list
      line              -> check_line line, line_list
    end
  end

  @divizor 100
  @max_cats 5

  defp _catg(hash, [head | tail]) do
    _catg(Dict.update(hash, 
                          min(@max_cats, div(head, @divizor)), 
                          1, 
                          &(&1 + 1)), 
          tail)
  end
  defp _catg(hash, []), do: hash

  def categorize(num_list) do
    _catg HashDict.new, num_list
  end

  defp _stars(0), do: ""
  defp _stars(x), do: "*" <> _stars(x - 1)

  def print(k, k, scale, hash) do
    v = Dict.get(hash, k, 0)
    :io.format("~13w+  ~3w|~s~n", [k * @divizor, v, _stars(round(v * scale))])
  end

  def print(k, _, scale, hash) do
    v = Dict.get(hash, k, 0)
    kc = k * @divizor
    stars = _stars(round(v * scale))
    :io.format("~11w-~3w ~3w|~s~n", [kc, kc + @divizor - 1, v, stars])
  end

  def print_histogram(hash) do
    vals = Dict.values hash
    scale = 50 / ((Enum.empty?(vals) && 1) || Enum.max(vals))
    
    Enum.each 0..@max_cats, &print &1, @max_cats, scale, hash

    IO.puts ""
  end

  def process(:read_stdin) do
    read_lines([])
    |> List.flatten
  end

  def process(:help) do
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
    System.halt(0)
  end

end
