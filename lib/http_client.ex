defmodule Http.Client do
  @doc """
  Create a client connection

  ## Examples
    
      iex> {:ok, socket} = Client.connect('localhost', 3030)
      iex> {:ok, data} = Request.data(socket)
      iex> String.length(to_string data) > 0
      true
  """
  def connect(host, port) do
    :gen_tcp.connect(host, port, [:binary, packet: :line, active: false])
  end
end
