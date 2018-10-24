defmodule ReportePiWeb.PiController do
  use ReportePiWeb, :controller
  alias ReportePi.Pi
    require Interceptor, as: I

  I.intercept do
  def source_form(conn, _params) do
    render(conn, "source_form.html")
  end
  end

  def source_form_post(conn, %{"form" => %{"path" => path, "operation" => operation}}) do
    atom = String.to_atom(operation)

    case apply(Pi, atom, [path]) do
      {:ok, msg} -> text(conn, msg)
      {:error, msg} -> text(conn, msg)
    end
  end
end
