defmodule ReportePiWeb.AttributesChannel do
  use Phoenix.Channel
  alias ReportePi.Pi.Attributes

  def join("attributes:" <> path, _message, socket) do
    IO.inspect(path)
    case Attributes.webid(%{path: path}) do
      {:ok, _webid} ->
        Attributes.init_channel(%{path: path})
        {:ok, socket}
      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end

end
