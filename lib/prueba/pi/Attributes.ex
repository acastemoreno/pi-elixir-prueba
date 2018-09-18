defmodule Prueba.Pi.Attributes do
  use GenServer
  alias Prueba.Pi.HttpClient
  import Prueba.Pi.HttpClient, only: [headers: 0, options: 0]

  # Client
  def start_link() do
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

  # Helper Functions

  defp request_value({{:error, _msg}, _state} = response_state), do: response_state
  defp request_value({{:ok, webid}, state}) do
    {{:ok, get_current_value(%{webid: webid})}, state}
  end

  defp request_webid_and_update_state_if_necesary(nil, path, state) do
    case get_webid_and_status(%{path: path}) do
      %{webid: webid, status_code: 200} ->
        {{:ok, webid}, state |> Map.put(path, webid)}
      _ ->
        {{:error, "bad_request"}, state}
    end
  end
  defp request_webid_and_update_state_if_necesary(webid, _path, state) do
     {{:ok, webid}, state}
  end

  defp get_webid_and_status(%{path: path}) do
    %{body: body, status_code: status_code} =
      ("attributes?path=" <> path <>"&selectedFields=WebId")
      |> HttpClient.get!(headers(), options())
    %{webid: body |> Keyword.get(:"WebId"), status_code: status_code}
  end

  defp get_current_value(%{webid: webid}) do
    %{body: body, status_code: 200} =
      ("streams/" <> webid <>"/end")
      |> HttpClient.get!(headers(), options())
    body |> Keyword.get(:"Value")
  end

end
