defmodule Mix.Tasks.CreateDatabase do
  use Mix.Task
  use DuckTongue.Persistence

  @shortdoc "Create Mnesia Database"
  def run(_) do
    if path = Application.get_env(:mnesia, :dir) do
      :ok = File.mkdir_p!(path)
    end

    nodes = [node()]
    Memento.stop()
    Memento.Schema.create(nodes)
    Memento.start()

    Table.create!(Language, disc_copies: nodes)
    Table.create!(Word, disc_copies: nodes)
  end
end
