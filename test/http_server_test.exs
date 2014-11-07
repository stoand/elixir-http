defmodule Http.Test do
  use ExUnit.Case, async: true
  alias Http.Client
  alias Http.Request
  alias Http.Response

  doctest Client
  doctest Request

  test "Parsing Request Headers" do
    header = Request.header("GET / HTTP/1.1\r\nHost: localhost:5050")
    assert header.method == "GET"
    assert header.fields["Host"] == "localhost:5050"
  end

  test "Generating Response Headers" do
    Response.header(self(), 200, "OK", %{"Content-Type" => "text/html"})
    receive do
      generated_headers ->
        assert "HTTP/1.0 200 OK\nContent-Type: text/html\n\n" == generated_headers
    end
  end
end
