defmodule DuckTongue do
  use DuckTongue.Persistence
  alias DuckTongue.Dictionary
  alias DuckTongue.Server
  defstruct ~w(
    language
    word
    action
    definition
    iso_code
  )a
  def appname, do: "DuckTongue"

  def os do
    {family, _} = :os.type()
    family
  end

  def start(state) do
    {:ok, agent} = Agent.start_link(fn -> state end)
    agent
  end

  def process(agent) do
    %DuckTongue{
      action: action,
      word: word,
      language: lang,
      definition: definition,
      iso_code: iso_code
    } = state(agent)

    case action do
      "get" ->
        {:ok, Dictionary.get_word(lang, word)}

      "put" ->
        {:ok, Dictionary.put_word(lang, word, definition)}

      "create_language" ->
        {:ok,
         Dictionary.create_language(%Language{
           iso_code: iso_code,
           fullname: definition
         })}

      "server" ->
        {:ok, Server.start()}

      "random" ->
        {:ok, Dictionary.random()}

      _ ->
        {:error, "Unknown Action!"}
    end
  end

  defp state(agent) do
    Agent.get(agent, fn s -> s end)
  end
end
