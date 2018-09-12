defmodule Prueba.Pi do
  use HTTPoison.Base
  @pi Application.get_env(:prueba, __MODULE__)
  @expected_fields ~w(
   Timestamp UnitsAbbreviation Good Questionable Substituted Annotated Value
 )

  def current_value() do
    headers = ["Authorization": "Basic #{token()}", "User-Agent": "Elixir", "Cache-Control": "no-cache"]
    options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 1000]

    ("streams/F1AbECwsLXOZBzkK2ic-Q7erHKQtKI4Kmqt6BGAxgAMKZ0ImQX1rzxrnz-lk8C71yE4R82QUElTUlYxXERFRkFVTFRcTElORUEgMVxQVU1QIDF8QUxUVVJB/end")
    |> get!(headers, options)
  end

  def token do
    (@pi[:user]<>":"<>@pi[:password])
    |> Base.encode64()
  end

  def process_url(url) do
    @pi[:url] <> url
  end

  def process_response_body(body) do
    body
    |> Poison.decode!
    |> Map.take(@expected_fields)
    |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
  end

end