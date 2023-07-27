defmodule DuckTongue.Server do
  use Plug.Router
  import DuckTongue

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

      other -> IO.inspect("#{other}")
    end
  end

  match _ do
    body = for {key, val} <- conn.body_params, into: %{} do
      {String.to_atom(key), val}
    end

    result = struct(DuckTongue, body)
    |> start()
    |> process()
    |> jsonize_result()

    send_resp(conn, 200, result)
  end

  def jsonize_result(process_result) do
    {result, msg} = process_result
    {:ok, json} = Jason.encode %{
      result: result,
      content: msg
    }
    json
  end
end
