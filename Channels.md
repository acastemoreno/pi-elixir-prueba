```elixir

{:ok, pid } = ReportePi.Pi.HttpClient.DynamicWebsocket.start_child("streams/P1AbEUElTUlYxXERFRkFVTFRcTElORUEgMVxQVU1QIDF8QUxUVVJB/channel")
ReportePi.Pi.Attributes.init_channel(%{path: "\\\\PISRV1\\Default\\Linea 1\\Pump 1|Caudal"})

ReportePi.Pi.Attributes.init_channel(%{path: "\\\\PISRV1\\Default\\Linea 2\\Pump 4|Altura"})

{:ok, pid2 } = ReportePi.Pi.HttpClient.DynamicWebsocket.start_child("streams/P1AbEUElTUlYxXERFRkFVTFRcTElORUEgMVxQVU1QIDF8Q0FVREFM/channel")

```
