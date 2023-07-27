defmodule DuckTongue.Server do
  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(
    Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  def start() do
    {port, _} = Integer.parse(System.get_env("DUCK_PORT") || "4444")

    {:ok, pid} = Plug.Cowboy.http(__MODULE__, [], port: port)
    Process.monitor(pid)
    IO.puts("Server started on port #{port}")
    receive do
      {:DOWN, _, :process, ^pid, :normal} ->
        IO.puts("The server on port #{port} exit normally")

      {:DOWN, _, :process, ^pid, msg} ->
        IO.puts("""
        The server on port #{port} is down!
        Reason: #{msg}
        """)
    end
  end

  match _ do
    send_resp(conn, 200, "Welcome!")
  end
end
