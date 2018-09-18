defmodule PruebaWeb.PiController do
  use PruebaWeb, :controller

  def attribute_form(conn, _params) do
    render(conn, "attribute_form.html")
  end

  def attribute_form_post(conn, %{"form" => %{"tag" => tag}}) do
    case Prueba.Pi.Attributes.webid(%{path: tag}) do
      {:ok, webid} -> text conn, webid
      {:error, msg} -> text conn, msg
    end
  end
end
