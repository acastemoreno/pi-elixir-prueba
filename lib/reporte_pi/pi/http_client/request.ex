defmodule ReportePi.Pi.HttpClient.Request do
  use HTTPoison.Base
  @pi Application.get_env(:reporte_pi, ReportePi.Pi)
  @expected_fields ~w(
   Timestamp UnitsAbbreviation Good Questionable Substituted Annotated Value WebId
  )

  def token do
    (@pi[:user] <> ":" <> @pi[:password])
    |> Base.encode64()
  end

  def headers do
    [
      Authorization: "Basic #{token()}",
      "User-Agent": "Elixir",
      "Cache-Control": "no-cache",
      Accept: "Application/json; Charset=utf-8"
    ]
  end

  def options do
    [ssl: [{:versions, [:"tlsv1.2"]}]]
  end

  def process_url(url) do
    (@pi[:url] <> url) |> URI.encode()
  end

  def process_response_body(body) do
    body
    |> Poison.decode!()
    |> Map.take(@expected_fields)
  end
end
