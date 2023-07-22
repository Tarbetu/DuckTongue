use Amnesia

defdatabase DuckTongue.Persistence do
  deftable(Language)

  deftable Word,
           [
             {:id, autoincrement},
             :language_id,
             :word,
             :definition
           ],
           type: :bag do
    @type t :: %Word{
            id: non_neg_integer,
            language_id: non_neg_integer,
            word: String.t(),
            definition: String.t()
          }

    def language(self) do
      Language.read(self.language_id)
    end
  end

  deftable Language,
           [
             :iso_code,
             :fullname
           ],
           type: :ordered_set do
    @type t :: %Language{
            iso_code: atom(),
            fullname: String.t()
          }

    def add_word(self, word, definition) do
      %Word{
        language_id: self.id,
        word: word,
        definition: definition
      }
      |> Word.write()
    end

    def words(self) do
      Word.read(self.id)
    end

    def get_word(self, word) do
      Language.words(self)
      |> Enum.filter(&(&1.word == word))
    end
  end
end
