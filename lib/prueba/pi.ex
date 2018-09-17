defmodule Prueba.Pi do
  use GenServer
  alias Prueba.Pi.HttpClient

  # Client

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get_by_path(path) when path |> is_bitstring() do
    GenServer.call(__MODULE__, {:get_by_path, path})
  end

  def get_by_path(_path) do
    {:error, "Path no valido"}
  end

  # Callbacks

  @impl true
  def init(args) do
    {:ok, args}
  end

  @impl true
  def handle_call({:get_by_path, path}, _from, state) do
    {_webid, value} = Map.get(state, path)
                      |> get_webid_value(path)
    {:reply, value, state |> Map.put(path, value)}
  end

  # Helper Functions

  defp get_webid_value(nil, path) do
    webid = HttpClient.get_webid(path)
    get_webid_value(%{webid: webid}, path)
  end
  defp get_webid_value(%{webid: webid}, path) do
    {webid, HttpClient.current_value(path)}
  end

end
