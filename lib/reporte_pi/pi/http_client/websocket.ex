defmodule ReportePi.Pi.HttpClient.Websocket do
  use WebSockex
  alias WebSockex.Conn
  import ReportePi.Pi.HttpClient.Request, only: [token: 0]
  @pi Application.get_env(:reporte_pi, ReportePi.Pi)

  def start_link(url) do
    conn =
      Conn.new(@pi[:url_websocket] <> url, extra_headers: [Authorization: "Basic #{token()}"])

    WebSockex.start_link(conn, __MODULE__, [])
  end

  def handle_frame({_type, msg}, state) do
    [%{"Items" => items}] = msg |> Poison.decode!() |> Map.get("Items")
    items |> Enum.map(&(Map.get(&1, "Value") |> IO.inspect()))
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
