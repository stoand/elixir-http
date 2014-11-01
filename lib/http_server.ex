defmodule HttpServer do

  def start(port) do
    {ok, socket} = :gen_tcp.listen(port, [active: false])
    loop(socket)
  end

  defp loop(socket) do
    {:ok, connection} = :gen_tcp.accept(socket)
    {:ok, data} = request_data(connection)
    IO.inspect data
    handler = spawn fn -> handle(connection) end
    :gen_tcp.controlling_process(connection, handler)
    loop(socket)
  end

  defp handle(connection) do
    :gen_tcp.send(connection, response('<h1> Hello Elixir!</h2><p>Yes!</p>'))
    :gen_tcp.close(connection)
  end

  defp response(string) do
    bytes = IO.iodata_to_binary(string)
    IO.iodata_to_binary(
      to_char_list("HTTP/1.0 200 OK\nContent-Type: text/html\nContent-Length: " <> to_string(byte_size(bytes)) <>"\n\n" <> to_string(bytes))
    )
  end

  defp request_data(connection) do
    case :gen_tcp.recv(connection, 0) do
      {:ok, bytes} -> {:ok, IO.iodata_to_binary(bytes)}
      # {:ok, bytes} -> request_data(connection, [previous_bytes, bytes])
      # {:error, :closed} -> 
    end
  end
end
