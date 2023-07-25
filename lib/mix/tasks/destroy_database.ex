defmodule Mix.Tasks.DestroyDatabase do
  use Mix.Task
  use DuckTongue.Persistence

  @shortdoc "Destroys Mnesia Database"
  def run(_) do
    nodes = [node()]
    Memento.start()
    Table.delete!(Language)
    Table.delete!(Word)

    Memento.stop()
    Memento.Schema.delete(nodes)
  end
end
