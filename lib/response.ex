defmodule Http.Response do
  alias Http.Response

  @moduledoc """
  Sends data to an open socket
  """

  @doc """
  Sends a header which includes the specified fields

  ## Examples
      Response.header(socket, %{"Content-Type:" => "text/html"})
  """
  def header(socket, fields \\ %{}),
    do: header(socket, 200, "OK", fields)

  @doc """
  Sends a header with the a certain status code and status message
  
  ## Examples
      Response.header(socket, 200, "OK")
  """
  def header(socket, status_code, status_message),
    do: header(socket, status_code, status_message, %{})


  @doc """
  Sends a header with the a certain status code and status message
  that also includes header fields

  ## Examples
      Response.header(socket, 200, "OK", %{"Content-Type" => "text/html"})
  """
  def header(socket, status_code, status_message, fields) do
    encoded_fields = fields
    |> Map.to_list
    |> Enum.map_join(fn(field) ->
      {key, value} = field
       "\n" <> key <> ": " <> to_string(value)
    end)
    data(socket, "HTTP/1.0 #{status_code} #{status_message}#{encoded_fields}\n\n")
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
