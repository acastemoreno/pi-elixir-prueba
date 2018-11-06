defmodule ReportePi.Pi.ApiClient.Channel do
  use Supervisor, type: :supervisor
  alias ReportePi.Pi.ApiClient.Channel.DynamicWebsocket

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_channel(url, path) do
    DynamicWebsocket.start_child(url, path)
  end

  @impl true
  def init(_arg) do
    children = [
      {DynamicWebsocket, []}
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
