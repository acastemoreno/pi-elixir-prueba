defmodule Prueba.Pi.Attributes do
  use GenServer, type: :worker
  alias Prueba.Pi.HttpClient.Request
  import Prueba.Pi.HttpClient.Request, only: [headers: 0, options: 0]

  # Client
  def start_link(_arg) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def webid(%{path: path}) when path |> is_bitstring() do
    GenServer.call(__MODULE__, {:webid, %{path: path}})
  end
  def webid(_path), do: {:error, "Argumento no valido"}

  def value(%{path: path}) when path |> is_bitstring() do
    GenServer.call(__MODULE__, {:value, %{path: path}})
  end

  def value(_path) do
    {:error, "Path no valido"}
  end

  def init_channel(%{path: path}) when path |> is_bitstring() do
    GenServer.call(__MODULE__, {:init_channel, %{path: path}})
  end

  # Callbacks

  @impl true
  def init(args) do
    {:ok, args}
  end

  @impl true
  def handle_call({:webid, %{path: path}}, _from, state) do
    {response, state} = Map.get(state, path)
      |> request_webid_and_update_state_if_necesary(path, state)
    {:reply, response, state}
  end
  def handle_call({:value, %{path: path}}, _from, state) do
    {response, state} = Map.get(state, path)
      |> request_webid_and_update_state_if_necesary(path, state)
      |> request_value()
    {:reply, response, state}
  end
  def handle_call({:init_channel, %{path: path}}, _from, state) do
    {response, state} = Map.get(state, path)
      |> request_webid_and_update_state_if_necesary(path, state)
      |> request_channel(path)
    {:reply, response, state}
  end

  # Helper Functions

  defp request_channel({{:error, _msg}, _state} = response_state, _path), do: response_state
  defp request_channel({{:ok, webid}, state}, path) do
    case state |> get_in([path, :channel_pid]) do
      nil ->
        {:ok, channel_pid} = Prueba.Pi.HttpClient.DynamicWebsocket.start_child("streams/" <> webid <>"/channel")
        state = state |> put_in([path, :channel_pid], channel_pid)
        {{:ok, "Conexión a Pi creado exitosamente"}, state}
      channel_pid when channel_pid |> is_pid() ->
        {{:ok, "La conexión a PI ya existia"}, state}
    end
  end

  defp request_value({{:error, _msg}, _state} = response_state), do: response_state
  defp request_value({{:ok, webid}, state}) do
    {{:ok, get_current_value(%{webid: webid})}, state}
  end

  defp request_webid_and_update_state_if_necesary(nil, path, state) do
    case get_webid_and_status(%{path: path}) do
      %{webid: webid, status_code: 200} ->
        {{:ok, webid}, state |> Map.put(path, %{webid: webid})}
      _ ->
        {{:error, "bad_request"}, state}
    end
  end
  defp request_webid_and_update_state_if_necesary(%{webid: webid}, _path, state) do
     {{:ok, webid}, state}
  end

  defp get_webid_and_status(%{path: path}) do
    %{body: body, status_code: status_code} =
      ("attributes?path=" <> path <>"&selectedFields=WebId")
      |> Request.get!(headers(), options())
    %{webid: body |> Map.get("WebId"), status_code: status_code}
  end

  defp get_current_value(%{webid: webid}) do
    %{body: body, status_code: 200} =
      ("streams/" <> webid <>"/end")
      |> Request.get!(headers(), options())
    case body |> Map.get("Value") do
      value when not (value |> is_map()) ->
        value
      value ->
        Map.get(value, "Value")
    end
  end

end
