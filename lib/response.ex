defmodule HttpServer.Response do
  alias HttpServer.Response

  @moduledoc """
  Sends data to an open connection
  """

  @doc """
  Sends a header which includes the specified fields

  ## Examples
      Response.header(connection, %{"Content-Type:" => "text/html"})
  """
  def header(connection, fields),
    do: header(connection, 200, "OK", fields)

  @doc """
  Sends a header with the a certain status code and status message
  
  ## Examples
      Response.header(connection, 200, "OK")
  """
  def header(connection, status_code, status_message),
    do: header(connection, status_code, status_message, %{})


  @doc """
  Sends a header with the a certain status code and status message
  that also includes header fields

  ## Examples
      Response.header(connection, 200, "OK", %{"Content-Type:" => "text/html"})
  """
  def header(connection, status_code, status_message, fields) do
    encoded_fields = fields
    |> Map.to_list
    |> Enum.map_join(fn(field) ->
      {key, value} = field
       "\n" <> key <> ": " <> to_string(value)
    end)
    data(connection, "HTTP/1.0 #{status_code} #{status_message} #{encoded_fields}\n\n")
  end

  @doc """
  Sends data to the connection

  ## Note
  This does not close the connection, to close the connection call:
      Response.close(connection)
  """
  def data(connection, data) do
    :gen_tcp.send(connection, IO.iodata_to_binary(to_char_list(data)))
  end

  @doc """
  Ends the Response and optionally sends data before ending it
  """
  def close(connection, data \\ nil) do
    if data != nil do
      data(connection, data)
    end
    :gen_tcp.close(connection)
  end
end
