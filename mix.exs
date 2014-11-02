defmodule HttpServer.Mixfile do
  use Mix.Project

  def project do
    [app: :http_server,
     version: "0.0.1",
     elixir: "~> 1.0.0",
     deps: deps()]
  end

  def application do
    """
    HttpServer.start(3030, fn(c) ->

      header = Request.header(c)
      IO.inspect header

      Response.header(c, %{"Content-Type" => "text/html"})
      Response.close(c, "Welcome to Elixir")
    end)
    """
    [applications: [:logger]]
  end

 def deps do
    [{:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.6", only: :dev}]
  end
end
