defmodule ReportePiWeb.PointsChannel do
  use Phoenix.Channel
  alias ReportePi.Pi.Points

  def join("points:" <> path, _message, socket) do
    IO.inspect(path)
    case Points.webid(%{path: path}) do
      {:ok, _webid} ->
        Points.init_channel(%{path: path})
        {:ok, socket}
      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end

end
