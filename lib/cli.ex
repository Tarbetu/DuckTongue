defmodule DuckTongue.CLI do
  alias DuckTongue.Persistence.Word
  import DuckTongue

  def main(args) do
    {%{
       language: language,
       word: word,
       definition: definition,
       isocode: isocode
     }, _,
     _} =
      OptionParser.parse(
        args,
        switches: [
          language: :string,
          word: :string,
          definition: :string,
          isocode: :string
        ],
        aliases: [
          l: :language,
          w: :word,
          d: :definition,
          lang_fullname: :definition,
          iso_code: :isocode,
          lang_name: :isocode
        ]
      )

    action =
      case args do
        [] ->
          "random"

        _ ->
          if String.starts_with?(hd(args), "-") do
            "get"
          else
            hd(args)
          end
      end

    result =
      %DuckTongue{
        language: language,
        word: word,
        action: action,
        definition: definition,
        iso_code: isocode
      }
      |> start()
      |> process()

    with {:ok, value} <- result do
      case action do
        x when x in ["get", "random"] ->
          %Word{
            word: word,
            definition: definition
          } = value

          IO.puts("
          #{word}
          #{definition}
          ")

        "create_language" ->
          "Created: #{isocode} - #{definition}"

        "server" ->
          IO.puts("Server started on port 4444")

        _ ->
          IO.puts("")
      end
    else
      {:error, error_message} -> IO.puts(error_message)
    end
  end
end
