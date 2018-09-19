defmodule ReportePi.Pi.HttpClient.Websocket do
  use WebSockex
  alias WebSockex.Conn
  import ReportePi.Pi.HttpClient.Request, only: [token: 0]
  @pi Application.get_env(:reporte_pi, ReportePi.Pi)

  def start_link(url: url, path: path) do
    conn =
      Conn.new(@pi[:url_websocket] <> url, extra_headers: [Authorization: "Basic #{token()}"])

    WebSockex.start_link(conn, __MODULE__, path)
  end

  def handle_frame({_type, msg}, path) do
    [%{"Items" => items}] = msg |> Poison.decode!() |> Map.get("Items")
    items |> Enum.map(&(get_value_and_broadcast(&1, path)))
    {:ok, path}
  end

  def handle_cast({:send, {type, msg} = frame}, path) do
    IO.puts("Sending #{type} frame with payload: #{msg}")
    {:reply, frame, path}
  end

  def terminate(reason, path) do
    IO.puts("\nSocket Terminating:\n#{inspect(reason)}\n\n#{inspect(path)}\n")
    exit(:normal)
  end

  defp get_value_and_broadcast(%{"Value" => value, "Timestamp" => timestamp}, path) do
    ReportePiWeb.Endpoint.broadcast "attributes:" <> path , "new_msg", %{"value" => value, "date" => timestamp}
  end
end
