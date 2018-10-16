defmodule ReportePi.Pi do
  use Supervisor, type: :supervisor

  alias ReportePi.Pi.Sources

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      {ReportePi.Pi.HttpClient, []},
      {Sources, []},

    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def webid(%{path: path} = map) when path |> is_bitstring() do
    case path |> String.contains?("|") do
      true ->
        Sources.webid(map)
      false ->
        Sources.webid(map)
    end
  end

  def webid(_path), do: {:error, "Argumento no valido"}

  def value(%{path: path} = map) when path |> is_bitstring() do
    case path |> String.contains?("|") do
      true ->
        Sources.value(map)
      false ->
        Sources.value(map)
    end
  end

  def value(_path), do: {:error, "Argumento no valido"}
end
