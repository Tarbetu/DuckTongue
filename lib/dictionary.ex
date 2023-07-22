defmodule DuckTongue.Dictionary do
  use DuckTongue.Persistence

  def create_language(lang_s) do
    Language.write(lang_s)
  end

  def get_word(iso_code, word_name) do
    with {:ok, lang} <- Language.read(iso_code) do
      lang
      |> Language.words()
      |> Enum.filter(&(&1 == word_name))
    else
      nil -> {:error, "Language not found"}
      _ -> raise("Unexpected error!")
    end
  end

  def put_word(iso_code, word, definition) do
    with {:ok, lang} <- Language.read(iso_code) do
      lang
      |> Language.add_word(word, definition)
    else
      nil -> {:error, "Language not found"}
      _ -> raise("Unexpected error!")
    end
  end

  def random() do
    Language.keys()
    |> Enum.random()
    |> Language.read!()
    |> Language.words()
    |> Enum.random()
  end
end
