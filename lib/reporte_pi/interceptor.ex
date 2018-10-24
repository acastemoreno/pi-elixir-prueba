defmodule ReportePi.Interceptor do
  def intercept_before(mfa),
    do: IO.puts "Intercepted #{inspect(mfa)} before it started."

  def intercept_after(mfa, result),
    do: IO.puts "Intercepted #{inspect(mfa)} after it completed. Its result: #{inspect(result)}"
end
