defmodule DuckTongue do
  use DuckTongue.Persistence
  alias DuckTongue.Dictionary
  alias DuckTongue.Server
  defstruct ~w(
    language
    word
    action
    definition
  )a

  def start(state) do
    Memento.wait([Language, Word], 3000)
    {:ok, agent} = Agent.start_link(fn -> state end)
    agent
  end

  def process(agent) do
    %DuckTongue{
      action: action,
      word: word,
      language: lang,
      definition: definition,
    } = state(agent)

    case action do
      "get" ->
        {:ok, Dictionary.get_word(lang, word)}

      "put" ->
        with :ok <- Dictionary.put_word(lang, word, definition) do
          {:ok, ""}
        else
          err -> err
        end

      "create_language" ->
        {:ok, Dictionary.create_language(%Language{
           lang_code: lang,
           fullname: definition
         })}

      "server" ->
        {:ok, Server.start()}

      "random" ->
        Dictionary.random()

      "list" ->
        Dictionary.list_languages()

      action ->
        {:error, "Unknown action: #{inspect(action)}"}
    end
  end

  defp state(agent) do
    Agent.get(agent, fn s -> s end)
  end
end
