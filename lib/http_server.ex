defmodule HttpServer do

  @moduledoc
  def start(port, callback) do
    {:ok, socket} = :gen_tcp.listen(port, [active: false])
    listen(socket, callback)
  end

  defp listen(socket, callback) do
    {:ok, connection} = :gen_tcp.accept(socket)
    handler = spawn fn -> callback.(connection) end
    :gen_tcp.controlling_process(connection, handler)
    listen(socket, callback)
  end
end
