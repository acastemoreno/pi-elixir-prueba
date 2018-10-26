defmodule ReportePi.Pi.ApiClient.Channel do
  use DynamicSupervisor
  alias ReportePi.Pi.ApiClient.Websocket
  require WebSockex

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def start_child(url, path) do
    # If MyWorker is not using the new child specs, we need to pass a map:
    spec = %{id: path , start: {Websocket, :start_link, [url, path]}, shutdown: :infinity}
    # spec = {Websocket, url: url, path: path}
    {:ok, pid} = DynamicSupervisor.start_child(__MODULE__, spec)
    WebSockex.cast(pid, :trap_exit)
    {:ok, pid}
  end

  def trap_exit_child() do
    DynamicSupervisor.which_children(__MODULE__)
    |> Enum.map(&flag/1)
  end

  defp flag({:undefined, pid, :worker, _list_supervisors}) do
    pid
  end

  def terminate_all_children() do
    DynamicSupervisor.which_children(__MODULE__)
    |> Enum.map(&terminate_children/1)
  end

  def terminate_children({:undefined, pid, :worker, _list_supervisors}) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  @impl true
  def init(_initial_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
