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

  def get_by_path(path) do
    {:error, "Path no valido"}
  end

  # Callbacks

  @impl true
  def handle_call({:get_by_path, path}, _from, state) when state[path] != nil do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:get_by_path, path}, _from, state) do
    HttpClient.
    {:reply, state, state}
  end
end
