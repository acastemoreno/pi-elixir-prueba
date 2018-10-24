defmodule ReportePiWeb.SourcesChannel do
  use Phoenix.Channel
  alias ReportePi.Pi.Sources

  def join("sources:" <> path, _message, socket) do
    with {:ok, _channel} <- Sources.init_channel(path) do
         {:ok, socket}
    else
      {:error, reason} -> {:error, %{reason: reason}}
    end
  end
end
