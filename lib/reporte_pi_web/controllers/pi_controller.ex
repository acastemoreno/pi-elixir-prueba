defmodule ReportePiWeb.PiController do
  use ReportePiWeb, :controller

  def attribute_form(conn, _params) do
    render(conn, "attribute_form.html")
  end

  def attribute_form_post(conn, %{"form" => %{"path" => path, "operation" => operation}}) do
    atom = String.to_atom(operation)

    case apply(ReportePi.Pi.Attributes, atom, [%{path: path}]) do
      {:ok, msg} -> text(conn, msg)
      {:error, msg} -> text(conn, msg)
    end
  end
end