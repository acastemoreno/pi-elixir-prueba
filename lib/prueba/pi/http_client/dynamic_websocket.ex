defmodule Prueba.Pi.HttpClient.DynamicWebsocket do
  use DynamicSupervisor
  alias Prueba.Pi.HttpClient.Websocket

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_child(url) do
    # If MyWorker is not using the new child specs, we need to pass a map:
    # spec = %{id: MyWorker, start: {MyWorker, :start_link, [foo, bar, baz]}}
    spec = {Websocket, url}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @impl true
  def init(_initial_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one
    )
  end
end
