defmodule Response do

  def header(connection, fields),
    do: header(connection, 200, "OK", fields)

  def header(connection, status_code, status_message),
    do: header(connection, status_code, status_message, %{})

  def header(connection, status_code, status_message, fields) do
    encoded_fields = fields
    |> Map.to_list
    |> Enum.map_join(fn(field) ->
      {key, value} = field
       "\n" <> key <> ": " <> to_string(value)
    end)
    data(connection, "HTTP/1.0 #{status_code} #{status_message} #{encoded_fields}\n\n")
  end

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
    close(connection)
  end
end
