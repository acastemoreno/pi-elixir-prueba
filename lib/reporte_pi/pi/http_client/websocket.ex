defmodule ReportePi.Pi.HttpClient.Websocket do
  use WebSockex
  alias WebSockex.Conn
  import ReportePi.Pi.HttpClient.Request, only: [token: 0]
  @pi Application.get_env(:reporte_pi, ReportePi.Pi)

  def start_link(url: url, path: path) do
    conn =
      Conn.new(@pi[:url_websocket] <> url, extra_headers: [Authorization: "Basic #{token()}"])

    WebSockex.start_link(conn, __MODULE__, %{path: path})
  end


  @impl true
  def handle_frame({_type, msg}, %{path: path} = state) do
    [%{"Items" => items}] = msg |> Poison.decode!() |> Map.get("Items")
    value = items |> Enum.map(&(get_value_and_broadcast(&1, path))) |> List.last
    {:ok, state |> Map.put(:value, value)}
  end

  @impl true
  def handle_cast({:send, {type, msg} = frame}, state) do
    IO.puts("Sending #{type} frame with payload: #{msg}")
    {:reply, frame, state}
  end

  @impl true
  def terminate(reason, state) do
    IO.puts("\nSocket Terminating:\n#{inspect(reason)}\n\n#{inspect(state)}\n")
    exit(:normal)
  end

  defp get_value_and_broadcast(%{"Value" => value, "Timestamp" => timestamp}, path) do
    ReportePiWeb.Endpoint.broadcast "points:" <> path , "new_msg", %{"value" => value, "date" => timestamp}
    value
  end
end
