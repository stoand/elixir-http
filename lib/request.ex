defmodule Http.Request do
  alias Http.Request
  @moduledoc """
  Receives and parses data from an open socket
  """

  @doc false
  def data(mock_data, :once) when is_bitstring(mock_data), do: {:ok, mock_data}

  @doc """
  Recieve data from a socket\n

  ### Recieve data until the socket closes

      data = Request.data(socket)

  ### Recieve data once

      data = Request.data(socket, :once)
  """
  def data(socket, loop \\ :until_closed, previous_bytes \\ []) do
    case :gen_tcp.recv(socket, 0, 4000) do
      {:ok, bytes} when loop == :once -> {:ok, IO.iodata_to_binary(bytes)}
      {:ok, bytes} -> data(socket, true, [previous_bytes, bytes])
      #{:error, :closed} when previous_bytes == [] -> {:error, :closed}
      {:error, :closed} -> {:ok, IO.iodata_to_binary(previous_bytes)}
    end
  end

  @doc """
  Recieves data once and parses basic header information and request fields\n

  ## Examples
      Request.header(socket).method
      "GET"

  Name | Description
  --- | ---
  method | GET, POST, PUT ...
  path | The url without the query ex: http://localhost/one/two/three?test=1 -> /one/two/three
  query | The unparsed query string ex: http://localhost/one/two/three?test=1 -> test=1
  fields | Accept, Cookies ...
  """
  def header(socket) do
    {:ok, header} = data(socket, :once) # Receive only once
    [basic_info | encoded_fields] = String.split(to_string(header), "\r\n")

    [method, url | _] = String.split(basic_info)

    fields = Enum.reduce(encoded_fields, %{}, fn(field, map) ->
      case field do
        "" -> map
        _ ->
        case String.split(field, ": ") do
          [key, value] -> Map.put(map, key, value)
          _ -> map
        end
      end
    end)

    case String.split(url, "?") do
      [path, query] -> %{:method => method, :fields => fields, :path => path, :query => query}
      [path] -> %{:method => method, :fields => fields, :path => path, :query => nil}
    end
  end
  @doc ~S"""
  Parses GET or POST parameters from a string into a map\n
  Arrays can be denoted by adding '[]' to the end of the variable name

  ## Examples
      iex> Request.parse_params "a=0&b[]=1&b[]=2"
      %{"a" => "0", "b" => ["2", "1"]}
  """ 
  def parse_params(nil), do: %{}
  def parse_params(""), do: %{}
  def parse_params(encoded_params) do
    key_value_pairs = String.split(encoded_params,"&")
    Enum.reduce(key_value_pairs, %{}, fn(key_value_pair, map) ->
      case String.split(key_value_pair, "=") do
        [key, value] ->
          # Arrays in params may be encoded as:
          # ?arr[]=1&arr[]=2&arr[]=3  ==  [1, 2, 3]
          case String.ends_with?(key, "[]") do
            true ->
              trimmed_key = String.replace(key, "[]", "")
              map = Map.put_new(map, trimmed_key, [])
              Map.put(map, trimmed_key, [value | map[trimmed_key]])
            _ ->
              Map.put(map, key, value)
          end
        [key] -> Map.put(map, key, true)
      end
    end)
  end
end
