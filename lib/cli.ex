defmodule DuckTongue.CLI do
  alias DuckTongue.Persistence.Word
  import DuckTongue
  @definition_flags ["-d", "--definition", "-d=", "--definition="]

  def main(args) do
    option = get_options(args)
    action = get_action(option, args)

    definition = get_definition(args)

    result =
      %DuckTongue{
        language: option[:language],
        word: option[:word],
        action: action,
        definition: definition
      }
      |> start()
      |> process()



    with {:ok, value} <- result do
      case action do
        x when x in ["get", "random"] ->
          %Word{
            word: word,
            definition: definition,
            lang_code: langcode
          } = value

          IO.puts("""
          #{word} - #{langcode}
          #{definition}
          """)

        "create_language" ->
          "Created: #{option[:language]} - #{option[:definition]}"

        "server" ->
          IO.puts("Server started on port 4444")

        "list" ->
          print_languages(value)

        _x ->
          IO.puts("")
      end
    else
      {:error, error_message} -> IO.puts("ERR at #{inspect(action)}: #{inspect(error_message)}")
    end
  end

  defp get_definition(args) do
    args = Enum.join(args, " ")
    if String.contains?(args, @definition_flags) do
      args
      |> OptionParser.split()
      |> Enum.filter(&(not String.starts_with?(&1, ["-l", "-w"])))
      |> Enum.drop_while(&(not String.starts_with?(&1, "-d")))
      |> Enum.join(" ")
      |> String.replace(@definition_flags, "")
    else
      nil
    end
  end

  defp get_options(args) do
    {option, _, _} =
      OptionParser.parse(
        args,
        switches: [
          language: :string,
          word: :string,
        ],
        aliases: [
          l: :language,
          w: :word,
        ]
      )

    option
  end

  defp get_action(option, args) do
    case option do
      [] ->
        if length(args) != 0 do
          hd(args)
        else
          "random"
        end

      _ ->
        if String.starts_with?(hd(args), "-") do
          "get"
        else
          hd(args)
        end
    end
  end

  defp print_languages([]), do: nil

  defp print_languages([head | tail]) do
    IO.puts "#{head.lang_code}: #{head.fullname}"
    print_languages(tail)
  end
end
