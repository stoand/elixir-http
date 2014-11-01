defmodule HttpServer.Mixfile do
  use Mix.Project

  def project do
    [app: :http_server,
     version: "0.0.1",
     elixir: "~> 1.0.0",
     deps: []]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    HttpServer.start(3030)
    [applications: [:logger]]
  end
end
