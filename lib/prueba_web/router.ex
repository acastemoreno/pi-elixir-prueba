defmodule PruebaWeb.Router do
  use PruebaWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", PruebaWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/attribute", PiController, :attribute_form)
    post("/attribute", PiController, :attribute_form_post)
  end

  # Other scopes may use custom stacks.
  # scope "/api", PruebaWeb do
  #   pipe_through :api
  # end
end
