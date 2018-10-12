defmodule ReportePi.Pi do
  use Supervisor, type: :supervisor

  alias ReportePi.Pi.Points
  alias ReportePi.Pi.Attributes

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      {ReportePi.Pi.HttpClient, []},
      {Points, []},
      {Attributes, []}

    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def webid(%{path: path} = map) when path |> is_bitstring() do
    case path |> String.contains?("|") do
      true ->
        Attributes.webid(map)
      false ->
        Points.webid(map)
    end
  end

  def webid(_path), do: {:error, "Argumento no valido"}

  def value(%{path: path} = map) when path |> is_bitstring() do
    case path |> String.contains?("|") do
      true ->
        Attributes.value(map)
      false ->
        Points.value(map)
    end
  end

  def value(_path), do: {:error, "Argumento no valido"}
end
