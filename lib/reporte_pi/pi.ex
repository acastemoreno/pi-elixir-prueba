defmodule ReportePi.Pi do
  use Supervisor, type: :supervisor

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      {ReportePi.Pi.Attributes, []},
      {ReportePi.Pi.HttpClient, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
