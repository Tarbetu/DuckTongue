defmodule DuckTongue.Dictionary do
  use DuckTongue.Persistence

  def create_language(lang_s) do
    Memento.Transaction.execute_sync!(fn ->
      lang_s
      |> Query.write()
    end)
    make_copy(Language)
  end

  def get_word(lang_code, word_name) do
    process_word(lang_code, fn lang ->
      lang
      |> Language.words()
      |> Enum.filter(&(&1.word == word_name))
      |> hd
    end)
  end

  def put_word(lang_code, word, definition) do
    process_word(lang_code, :sync, fn lang ->
      lang
      |> Language.add_word(word, definition)
    end)
  end

  def random() do
    try do
      Memento.transaction!(fn ->
        {
          :ok,
          Query.all(Language)
          |> Enum.filter(&Language.has_word(&1))
          |> Enum.random()
          |> Language.words()
          |> Enum.random()
        }
      end)
    rescue
      Enum.EmptyError -> {:error, "There is no word yet"}
    end
  end

  def list_languages() do
    Memento.transaction!(fn ->
      {:ok, Query.all(Language)}
    end)
  end

  defp make_copy(table) do
    Memento.Table.set_storage_type(table, node(), :disc_only_copies)
    Memento.Table.create_copy(table, node(), :disc_only_copies)
    Memento.Table.set_storage_type(table, node(), :disc_copies)
  end

  defp process_callback(lang_code, callback) do
    fn ->
      with lang when lang != nil <- Query.read(Language, lang_code) do
        callback.(lang)
      else
        nil -> {:error, "Language not found"}
        x -> raise("Unexpected value #{x} while reading from language #{lang_code}!")
      end
    end
  end

  defp process_word(lang_code, callback) do
    process_callback(lang_code, callback)
    |> Memento.transaction!()
  end

  defp process_word(lang_code, :sync, callback) do
    process_callback(lang_code, callback)
    |> Memento.Transaction.execute_sync!()
    make_copy(Word)
  end
end
