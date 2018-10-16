defmodule ReportePiWeb.AttributesChannel do
  use Phoenix.Channel
  alias ReportePi.Pi.Sources

  def join("attributes:" <> path, _message, socket) do
    case Sources.webid(%{path: path, type: :attributes}) do
      {:ok, _webid} ->
        Sources.init_channel(%{path: path, type: :attributes})
        {:ok, socket}
      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end

end
