defmodule Http.Server do
  alias Http.Server
  alias Http.Request
  alias Http.Response
  @moduledoc """
  Listens for HTTP connections and calls a callback once a client connects
  """

  @doc """
  Initialize the server

  ## Examples
      Server.start(fn(socket) ->
        Server.Response.header(socket)
        Server.Response.close(socket, "It works!")
      end, 3030)
  """
  def start(callback, port) do
     import Supervisor.Spec

     children = [
       supervisor(Task.Supervisor, [[name: Server.TaskSupervisor]]),
       worker(Task, [Server, :accept, [callback, port]])
     ]

     Supervisor.start_link(children, [strategy: :one_for_one, name: Server.Supervisor])
  end

  @doc false
  def accept(callback, port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    listen(callback, socket)
  end

  defp listen(callback, socket) do
    {:ok, listen_socket} = :gen_tcp.accept(socket)
    Task.Supervisor.start_child(Server.TaskSupervisor, fn -> callback.(listen_socket) end)
    listen(callback, socket)
  end
end
