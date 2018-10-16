defmodule ReportePi.Pi.Sources do
  use GenServer, type: :worker
  alias ReportePi.Pi.HttpClient.Request
  import ReportePi.Pi.HttpClient.Request, only: [headers: 0, options: 0]
  @source_types [:attributes, :points]

  # Client Functions
  def start_link(_arg) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def webid(%{path: path, type: type}) when path |> is_bitstring() and type in @source_types do
    GenServer.call(__MODULE__, {:webid, %{path: path, type: type}})
  end

  def webid(arg) do
    IO.inspect(arg)
     {:error, "Argumentos no validos"}
  end

  def value(%{path: path, type: type}) when path |> is_bitstring() and type in @source_types do
    GenServer.call(__MODULE__, {:value, %{path: path, type: type}})
  end

  def value(_), do: {:error, "Argumentos no validos"}

  def init_channel(%{path: path, type: type}) when path |> is_bitstring() and type in @source_types do
    GenServer.call(__MODULE__, {:init_channel, %{path: path, type: type}})
  end

  def init_channel(_), do: {:error, "Argumentos no validos"}

  # Callbacks Functions

  @impl true
  def init(args) do
    {:ok, args}
  end

  @impl true
  def handle_call({:webid, %{path: path} = request}, _from, old_state) do
    old_state
      |> get_source(request)
      |> response_and_update_state(:webid, %{path: path, old_state: old_state})
  end

  def handle_call({:value, %{path: path} = request}, _from, old_state) do
    old_state
      |> get_source(request)
      |> get_value()
      |> response_and_update_state(:value, %{path: path, old_state: old_state})
  end

  def handle_call({:init_channel, %{path: path} = request}, _from, old_state) do
    old_state
      |> get_source(request)
      |> request_channel(path)
      |> response_and_update_state(:init_channel, %{path: path, old_state: old_state})
  end

  # Common Helper Functions
  defp response_and_update_state({:error, message}, _operation, %{old_state: old_state}) do
    {:reply, {:error, message}, old_state}
  end
  defp response_and_update_state({:ok, %{webid: webid} = source, true}, :webid, %{path: path, old_state: old_state}) do
    {:reply, {:ok, webid}, old_state |> Map.put(path, source)}
  end
  defp response_and_update_state({:ok, %{webid: webid}, false}, :webid, %{old_state: old_state}) do
    {:reply, {:ok, webid}, old_state}
  end
  defp response_and_update_state({:ok, value, source, true}, :value, %{path: path, old_state: old_state}) do
    {:reply, {:ok, value}, old_state |> Map.put(path, source)}
  end
  defp response_and_update_state({:ok, value, _source, false}, :value, %{old_state: old_state}) do
    {:reply, {:ok, value}, old_state}
  end
  defp response_and_update_state({:ok, channel_pid, source, true}, :init_channel, %{path: path, old_state: old_state}) do
    {:reply, {:ok, channel_pid}, old_state |> Map.put(path, source)}
  end
  defp response_and_update_state({:ok, channel_pid, _source, false}, :init_channel, %{old_state: old_state}) do
    {:reply, {:ok, channel_pid}, old_state}
  end

  # Init Channel Helper Functions

  defp request_channel({:error, _msg} = response_state, _path), do: response_state
  defp request_channel({:ok, %{channel_pid: nil, webid: webid} = source, _update_state?}, path) do
    {:ok, channel_pid} =
      ReportePi.Pi.HttpClient.DynamicWebsocket.start_child("streams/" <> webid <> "/channel", path)
    {:ok, channel_pid, source |> Map.put(:channel_pid, channel_pid), true}
  end
  defp request_channel({:ok, %{channel_pid: channel_pid} = source, update_state?}, _path) do
    {:ok, channel_pid, source, update_state?}
  end

  # Value Helper Function

  defp get_value({:error, _message} = error_message), do: error_message
  defp get_value({:ok, %{webid: webid} = source, update_state?}) do
    {:ok, request_current_value(webid), source, update_state?}
  end

  defp request_current_value(webid) do
    %{body: body, status_code: 200} =
      ("streams/" <> webid <> "/end")
      |> Request.get!(headers(), options())
    case body |> Map.get("Value") do
      value when not (value |> is_map()) ->
        value
      value ->
        Map.get(value, "Value")
    end
  end

  # Source Helper Functions

  defp get_source(old_state, %{path: path} = request) do
    old_state
      |> Map.get(path)
      |> request_source_if_necesary(request)
  end

  defp request_source_if_necesary(nil, %{type: type} = request) do
    case request_webid_and_status(request) do
      %{webid: webid, status_code: 200} ->
        {:ok, %{webid: webid, type: type, channel_pid: nil, value: nil}, true}
      _ ->
        {:error, "bad_request"}
    end
  end
  defp request_source_if_necesary(source, _request) do
    {:ok, source, false}
  end

  # Outside Helper Functions

  defp request_webid_and_status(%{path: path, type: type}) do
    %{body: body, status_code: status_code} =
      path
      |> webid_url(type)
      |> Request.get!(headers(), options())
    %{webid: body |> Map.get("WebId"), status_code: status_code}
  end

  defp webid_url(path, :attributes) do
    "attributes?path=" <> path <> "&selectedFields=WebId"
  end
  defp webid_url(path, :points) do
    "points?path=" <> path <> "&selectedFields=WebId"
  end
end
