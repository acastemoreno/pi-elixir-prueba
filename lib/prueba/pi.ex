defmodule Prueba.Pi do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      worker(Prueba.Pi.Attributes, [])
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

end
