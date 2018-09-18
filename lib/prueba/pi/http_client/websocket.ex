defmodule Prueba.Pi.HttpClient.Websocket do
  use WebSockex
  alias WebSockex.Conn
  import Prueba.Pi.HttpClient.Request, only: [token: 0]
  @pi Application.get_env(:prueba, Prueba.Pi)

  def start_link(url) do
    conn =
      Conn.new(@pi[:url_websocket] <> url, extra_headers: [Authorization: "Basic #{token()}"])

    WebSockex.start_link(conn, __MODULE__, [])
  end

  def handle_frame({type, msg}, state) do
    IO.puts(
      "Received Message - Type: #{inspect(type)} -- Message: #{inspect(msg |> Poison.decode!())}"
    )

    {:ok, state}
  end

  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.puts("Sending #{type} frame with payload: #{msg}")
    {:reply, frame, state}
  end

  def terminate(reason, state) do
    IO.puts("\nSocket Terminating:\n#{inspect(reason)}\n\n#{inspect(state)}\n")
    exit(:normal)
  end
end
