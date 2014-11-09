defmodule Http.Test do
  use ExUnit.Case, async: true
  alias Http.Client
  alias Http.Request
  alias Http.Response

  doctest Client
  doctest Request

  test "Parsing Request Headers on Server" do
    header = Request.client_header("GET / HTTP/1.1\r\nhost: localhost:5050")
    assert header.method == "GET"
    assert header.fields["host"] == "localhost:5050"
  end

  test "Generating Server Response Headers" do
    Response.server_header(self(), 200, "OK", %{"content-type" => "text/html"})
    receive do
      generated_headers ->
        assert "HTTP/1.0 200 OK\ncontent-type: text/html\n\n" == generated_headers
    end
  end

  test "Parsing Request Headers on Client" do
    header = Request.server_header("HTTP/1.0 200 OK\ncontent-type: text/html\n\n")
    assert header.status_code == 200
    assert header.fields["content-type"] == "text/html"
  end

  test "Generating Client Response Headers" do
    Response.client_header(self(), "GET", "/", %{"host" => "localhost:5050"})
    receive do
      generated_headers ->
        assert "GET / HTTP/1.1\r\nhost: localhost:5050" == generated_headers
    end
  end
end
