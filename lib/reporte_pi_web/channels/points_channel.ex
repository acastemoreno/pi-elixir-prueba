defmodule ReportePiWeb.PointsChannel do
  use Phoenix.Channel
  alias ReportePi.Pi.Sources

  def join("points:" <> path, _message, socket) do
    case Sources.webid(%{path: path, type: :points}) do
      {:ok, _webid} ->
        Sources.init_channel(%{path: path, type: :points})
        {:ok, socket}
      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end

end
