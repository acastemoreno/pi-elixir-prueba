defmodule ReportePi.Interceptor.Config do
  def get, do: %{
    {ReportePiWeb.PiController, :source_form, 2} => [
      before: {ReportePi.Interceptor, :intercept_before},
      after: {ReportePi.Interceptor, :intercept_after}
    ]
  }
end
