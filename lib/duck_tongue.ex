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
        {:ok, Dictionary.get(:word, lang, word)}

      "put" ->
        with :ok <- Dictionary.put(:word, lang, word, definition) do
          {:ok, ""}
        else
          err -> err
        end
      "random" ->
        Dictionary.random()

      "list" ->
        Dictionary.list(:language)

      "remove" ->
        if lang || not word do
          {Dictionary.remove(:language, lang), ""}
        else
          {Dictionary.remove(:word, lang, word), ""}
        end

      "create_language" ->
        {:ok, Dictionary.create(:language, %Language{
           lang_code: lang,
           fullname: definition
         })}

      "server" ->
        {:ok, Server.start()}

      action ->
        {:error, "Unknown action: #{action}"}
    end
  end

  defp state(agent) do
    Agent.get(agent, fn s -> s end)
  end
end
