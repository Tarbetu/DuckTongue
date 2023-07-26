defmodule DuckTongue.Persistence do
  defmacro __using__(_opts) do
    quote do
      import DuckTongue.Persistence
      alias DuckTongue.Persistence.{Language, Word}
      alias Memento.{Query, Table}
    end
  end
  alias Memento.Query

  defmodule Word do
    use Memento.Table,
    attributes: [
             :word,
             :lang_code,
             :definition
    ],
    index: [:lang_code],
    type: :set

    def language(self) do
      Query.read(Language, self.lang_code)
    end
  end

  defmodule Language do
    use Memento.Table,
    attributes: [
             :lang_code,
             :fullname
    ],
    type: :set

    def add_word(self, word, definition) do
      %Word{
        lang_code: self.lang_code,
        word: word,
        definition: definition
      }
      |> Query.write()
    end

    def words(self) do
      Query.select(Word, {:==, :lang_code, self.lang_code})
    end

    def get_word(self, word) do
      Memento.transaction! fn ->
        self = if is_binary(self) do
          Query.read(Language, self)
        else
          self
        end

        Language.words(self)
        |> Enum.filter(&(&1.word == word))
      end
    end

    def has_word(self) do
      Language.words(self)
      |> Enum.any?
    end
  end
end
