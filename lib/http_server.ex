defmodule HttpServer do
  @moduledoc """
  Manages an HTTP connection
  """

  @doc """
  Initialize the Server
  """
  def start(callback, port) do
    import Supervisor.Spec

    children = [
      supervisor(Task.Supervisor, [[name: HttpServer.TaskSupervisor]]),
      worker(Task, [HttpServer, :accept, [callback, port]])
    ]

    opts = [strategy: :one_for_one, name: HttpServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def accept(callback, port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false])
    listen(callback, socket)
  end

  defp listen(callback, socket) do
    {:ok, connection} = :gen_tcp.accept(socket)
    Task.Supervisor.start_child(HttpServer.TaskSupervisor, fn -> callback.(connection) end)
    listen(callback, socket)
  end
end
