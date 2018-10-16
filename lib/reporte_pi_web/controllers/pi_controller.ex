defmodule ReportePiWeb.PiController do
  use ReportePiWeb, :controller
  alias ReportePi.Pi

  def attribute_form(conn, _params) do
    render(conn, "attribute_form.html")
  end

  def attribute_form_post(conn, %{"form" => %{"path" => path, "operation" => operation}}) do
    atom = String.to_atom(operation)

    case apply(Pi, atom, [%{path: path, type: :attributes}]) do
      {:ok, msg} -> text(conn, msg)
      {:error, msg} -> text(conn, msg)
    end
  end

  def point_form(conn, _params) do
    render(conn, "point_form.html")
  end

  def point_form_post(conn, %{"form" => %{"path" => path, "operation" => operation}}) do
    atom = String.to_atom(operation)

    case apply(Pi, atom, [%{path: path, type: :points}]) do
      {:ok, msg} -> text(conn, msg)
      {:error, msg} -> text(conn, msg)
    end
  end
end
