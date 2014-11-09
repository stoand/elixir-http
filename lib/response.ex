defmodule Http.Response do
  @moduledoc """
  Sends data to an open socket
  """

  @doc """
  Sends a server header which includes the specified fields

  ## Examples
      Response.server_header(socket, %{"Content-Type:" => "text/html"})
  """
  def server_header(socket, fields \\ %{}),
    do: server_header(socket, 200, "OK", fields)

  @doc """
  Sends a server header with the a certain status code and status message
  that also includes header fields

  ## Examples
      Response.server_header(socket, 200, "OK", %{"content-type" => "text/html"})
  """
  def server_header(socket, status_code, status_message, fields \\ %{}) do
    data(socket, "HTTP/1.0 #{status_code} #{status_message}#{encode_fields(fields)}\n\n")
  end

  @doc """
  Sends a client header with the a certain status code and status message
  that also includes header fields

  ## Examples
      Response.client_header(socket, "GET", "/data/posts")
  """
  def client_header(socket, method, url, fields \\ %{}) do
    data(socket, "#{method} #{url} HTTP/1.1\r#{encode_fields(fields)}")
  end

  defp encode_fields(fields) do
    fields |> Map.to_list
    |> Enum.map_join(fn(field) ->
      {key, value} = field
       "\n" <> String.downcase(key) <> ": " <> to_string(value)
    end)
  end

  @doc """
  Sends data to the socket

  ## Note
  This does not close the socket, to close the socket call:
      Response.close(socket)
  """
  @doc false
  def data(pid, data) when is_pid(pid), do: send(pid, data)
  def data(socket, data) do
    :gen_tcp.send(socket, IO.iodata_to_binary(to_char_list(data)))
  end

  @doc """
  Ends the response and optionally sends data before ending it
  """
  def close(socket, data \\ nil) do
    if data != nil do
      data(socket, data)
    end
    :gen_tcp.close(socket)
  end
end
