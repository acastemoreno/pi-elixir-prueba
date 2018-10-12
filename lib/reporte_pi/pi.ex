defmodule ReportePi.Pi do
  use Supervisor, type: :supervisor

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      {ReportePi.Pi.HttpClient, []},
      {ReportePi.Pi.Points, []},
      {ReportePi.Pi.Attributes, []}

    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
