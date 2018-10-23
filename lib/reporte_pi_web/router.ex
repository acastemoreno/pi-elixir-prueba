defmodule ReportePiWeb.Router do
  use ReportePiWeb, :router

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

  scope "/", ReportePiWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)
    get("/source", PiController, :source_form)
    post("/source", PiController, :source_form_post)
  end

  # Other scopes may use custom stacks.
  scope "/api", ReportePiWeb do
    pipe_through :api
  end
end
