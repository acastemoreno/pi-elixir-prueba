defmodule ReportePi.Pi do
  use Supervisor, type: :supervisor

  alias ReportePi.Pi.{Sources, ApiClient}

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      {ApiClient, []},
      {Sources, []},
    ]

  Supervisor.init(children, strategy: :one_for_one)
  end
end
