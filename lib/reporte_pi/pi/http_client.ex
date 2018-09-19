defmodule ReportePi.Pi.HttpClient do
  use Supervisor, type: :supervisor

  def start_link(_arg) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      {ReportePi.Pi.HttpClient.DynamicWebsocket, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
