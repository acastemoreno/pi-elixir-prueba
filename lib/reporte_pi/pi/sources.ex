defmodule ReportePi.Pi.Sources do
  use GenServer, type: :worker
  alias ReportePi.Pi.ApiClient.{Request, Channel}
  import ReportePi.Pi.ApiClient.Request, only: [headers: 0, options: 0]

  # Client Functions
  def start_link(_arg) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def webid(path) when path |> is_bitstring() do
    case path |> String.contains?("|") do
      true ->
        GenServer.call(__MODULE__, {:webid, %{path: path, type: :attributes}}, 11000)
      false ->
        GenServer.call(__MODULE__, {:webid, %{path: path, type: :points}}, 11000)
    end
  end
  def webid(_arg) do
     {:error, "Argumentos no validos"}
  end

  def value(path) when path |> is_bitstring() do
    case path |> String.contains?("|") do
      true ->
        GenServer.call(__MODULE__, {:value, %{path: path, type: :attributes}}, 11000)
      false ->
        GenServer.call(__MODULE__, {:value, %{path: path, type: :points}}, 11000)
    end
  end
  def value(_), do: {:error, "Argumentos no validos"}

  def init_channel(path) when path |> is_bitstring() do
    case path |> String.contains?("|") do
      true ->
        GenServer.call(__MODULE__, {:init_channel, %{path: path, type: :attributes}}, 11000)
      false ->
        GenServer.call(__MODULE__, {:init_channel, %{path: path, type: :points}}, 11000)
    end
  end

  def init_channel(_), do: {:error, "Argumentos no validos"}

  def remove_channel(%{path: path}) when path |> is_bitstring() do
    GenServer.call(__MODULE__, {:remove_channel, %{path: path}}, 11000)
  end

  def remove_channel(_), do: {:error, "Argumentos no validos"}

  # Callbacks Functions

  @impl true
  def init(args) do
    {:ok, args}
  end

  @impl true
  def handle_call({:webid, %{path: path} = request}, _from, old_state) do
    old_state
      |> get_source(request)
      |> webid_and_update_state(%{path: path, old_state: old_state})
  end

  def handle_call({:value, %{path: path} = request}, _from, old_state) do
    old_state
      |> get_source(request)
      |> get_value()
      |> value_and_update_state(%{path: path, old_state: old_state})
  end

  def handle_call({:init_channel, %{path: path} = request}, _from, old_state) do
    old_state
      |> get_source(request)
      |> request_channel(path)
      |> channel_and_update_state(%{path: path, old_state: old_state})
  end

  def handle_call({:remove_channel, %{path: path} = request}, _from, old_state) do
    old_state
      |> get_existing_source(request)
      |> remove_channel_from_source()
      |> remove_channel_and_update_state(%{path: path, old_state: old_state})
  end

  # Common Helper Functions
  defp webid_and_update_state({:error, message}, %{old_state: old_state}) do
    {:reply, {:error, message}, old_state}
  end
  defp webid_and_update_state({:ok, %{webid: webid} = source, true}, %{path: path, old_state: old_state}) do
    {:reply, {:ok, webid}, old_state |> Map.put(path, source)}
  end
  defp webid_and_update_state({:ok, %{webid: webid}, false}, %{old_state: old_state}) do
    {:reply, {:ok, webid}, old_state}
  end

  defp value_and_update_state({:error, message}, %{old_state: old_state}) do
    {:reply, {:error, message}, old_state}
  end
  defp value_and_update_state({:ok, value, source, true}, %{path: path, old_state: old_state}) do
    {:reply, {:ok, value}, old_state |> Map.put(path, source)}
  end
  defp value_and_update_state({:ok, value, _source, false}, %{old_state: old_state}) do
    {:reply, {:ok, value}, old_state}
  end

  defp channel_and_update_state({:error, message}, %{old_state: old_state}) do
    {:reply, {:error, message}, old_state}
  end
  defp channel_and_update_state({:ok, channel_pid, source, true}, %{path: path, old_state: old_state}) do
    {:reply, {:ok, channel_pid}, old_state |> Map.put(path, source)}
  end
  defp channel_and_update_state({:ok, channel_pid, _source, false}, %{old_state: old_state}) do
    {:reply, {:ok, channel_pid}, old_state}
  end

  defp remove_channel_and_update_state({:error, message}, %{old_state: old_state}) do
    {:reply, {:error, message}, old_state}
  end
  defp remove_channel_and_update_state({:ok, source, true}, %{path: path, old_state: old_state}) do
    {:reply, :ok, old_state |> Map.put(path, source)}
  end
  defp remove_channel_and_update_state({:ok, _source, false}, %{old_state: old_state}) do
    {:reply, :ok, old_state}
  end

  # Remove Channel Helper Functions

  defp remove_channel_from_source({:error, _msg} = response_state), do: response_state
  defp remove_channel_from_source({:ok, %{channel_pid: nil} = source}) do
    {:ok, source, false}
  end
  defp remove_channel_from_source({:ok, %{channel_pid: channel_pid} = source}) when channel_pid |> is_pid() do
    {:ok, source |> Map.put(:channel_pid, nil), true}
  end

  # Init Channel Helper Functions

  defp request_channel({:error, _msg} = response_state, _path), do: response_state
  defp request_channel({:ok, %{channel_pid: nil, webid: webid} = source, _update_state?}, path) do
    case Channel.start_child("streams/" <> webid <> "/channel?heartbeatRate=5", path) do
      {:ok, channel_pid} ->
        {:ok, channel_pid, source |> Map.put(:channel_pid, channel_pid), true}
      {:error, message} ->
        IO.inspect message
        {:error, "cannot stablish websocket conection with pi"}
    end
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

  defp get_existing_source(old_state, %{path: path}) do
    {:ok, old_state |> Map.get(path)}
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
    case path
    |> webid_url(type)
    |> Request.get(headers(), options()) do
      {:ok, %{body: body, status_code: status_code}} ->
        %{webid: body |> Map.get("WebId"), status_code: status_code}
      {:error, %{reason: reason}} ->
        {:error, reason}
    end
  end

  defp webid_url(path, :attributes) do
    "attributes?path=" <> path <> "&selectedFields=WebId"
  end
  defp webid_url(path, :points) do
    "points?path=" <> path <> "&selectedFields=WebId"
  end
end
