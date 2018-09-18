```elixir

{:ok, pid } = Prueba.Pi.HttpClient.DynamicWebsocket.start_child("streams/P1AbEUElTUlYxXERFRkFVTFRcTElORUEgMVxQVU1QIDF8QUxUVVJB/channel")
Prueba.Pi.Attributes.init_channel(%{path: "\\\\PISRV1\\Default\\Linea 1\\Pump 1|Altura"})

Prueba.Pi.Attributes.init_channel(%{path: "\\\\PISRV1\\Default\\Linea 2\\Pump 1|Altura"})

{:ok, pid2 } = Prueba.Pi.HttpClient.DynamicWebsocket.start_child("streams/P1AbEUElTUlYxXERFRkFVTFRcTElORUEgMVxQVU1QIDF8Q0FVREFM/channel")

```
