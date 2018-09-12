defmodule Prueba.Pi do
  @pi Application.get_env(:prueba, __MODULE__)

  def current_value() do
    headers = ["Authorization": "Basic #{token()}", "User-Agent": "Elixir"]
    options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 1000]

    (@pi[:url] <> "streams/F1AbECwsLXOZBzkK2ic-Q7erHKQtKI4Kmqt6BGAxgAMKZ0ImQX1rzxrnz-lk8C71yE4R82QUElTUlYxXERFRkFVTFRcTElORUEgMVxQVU1QIDF8QUxUVVJB/value")
    |> HTTPoison.get(headers, options)
  end

  def token do
    (@pi[:user]<>":"<>@pi[:password])
    |> Base.encode64()
  end

end
