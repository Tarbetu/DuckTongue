defmodule DuckTongue.Dictionary do
  use DuckTongue.Persistence

  def create(:language, lang_s) do
    fn ->
      lang_s
      |> Query.write()
    end
    |> process(:lang, :sync)
  end

  def list(:language) do
    fn ->
      {:ok, Query.all(Language)}
    end
    |> process(:lang)
  end

  def remove(:language, lang_code) do
    with {:ok, value} <- random() do
      fn _ ->
        Query.delete_record(value)
      end
      |> process(:word, lang_code, :sync)
      :ok = remove(:language, lang_code)
      :ok
    else
      _ ->
        fn ->
          Query.delete(Language, lang_code)
        end
        |> process(:lang, :sync)
    end
  end

  def get(:word, lang_code, word_name) do
    fn lang ->
      lang
      |> Language.words()
      |> Enum.filter(&(&1.word == word_name))
      |> hd
    end
    |> process(:word, lang_code)
  end

  def put(:word, lang_code, word, definition) do
    fn lang ->
      lang
      |> Language.add_word(word, definition)
    end
    |> process(:word, lang_code, :sync)
  end

  def remove(:word, lang_code, word) do
    fn ->
      lang_code
      |> Query.delete_record()
    end
    |> process(:word, fn -> Language.get_word(lang_code, word) end, :sync)
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

  defp make_copy(table) do
    Memento.Table.set_storage_type(table, node(), :disc_only_copies)
    Memento.Table.create_copy(table, node(), :disc_only_copies)
    Memento.Table.set_storage_type(table, node(), :disc_copies)
  end

  defp process_sync_callback(:lang, callback) do
    callback |>
    Memento.Transaction.execute_sync!()
    make_copy(Language)
  end

  defp process_callback(:word, lang_code, callback) do
    lang_code = if is_function(lang_code) do
      lang_code.()
    else
      lang_code
    end

    fn ->
      with lang when lang != nil <- Query.read(Language, lang_code) do
        callback.(lang)
      else
        nil -> {:error, "Language not found"}
        x -> raise("Unexpected value #{x} while reading from language #{lang_code}!")
      end
    end
  end


  defp process(callback, :lang) do
    Memento.transaction!(callback)
  end

  defp process(callback, action = :lang, :sync) do
    process_sync_callback(action, callback)
  end

  defp process(callback, action = :word, lang_code) do
    process_callback(action, lang_code, callback)
    |> Memento.transaction!()
  end

  defp process(callback, action = :word, lang_code, :sync) do
    process_callback(action, lang_code, callback)
    |> Memento.Transaction.execute_sync!()
    make_copy(Word)
  end
end
