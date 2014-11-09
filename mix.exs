defmodule Http.Mixfile do
  use Mix.Project
  alias Http.Server
  alias Http.Response

  def project do
    [app: :http,
     version: "0.0.1",
     elixir: "~> 1.0.0",
     deps: deps]
  end

  def application() do
    [applications: [], mod: {__MODULE__, []}]
  end

  # Simple example server
  def start(_type, _args) do
    Server.start(fn(socket) ->
      Response.server_header(socket)
      Response.close(socket, "The Elixir server works!")
    end, 3030)
  end

 def deps do
    [{:earmark, "~> 0.1", only: :dev},
     {:ex_doc, "~> 0.6", only: :dev}]
  end
end
