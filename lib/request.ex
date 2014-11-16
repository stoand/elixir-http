defmodule Http.Request do
  @moduledoc """
  Receives and parses data from an open socket
  """

  @doc false
  def data(mock_data, :once) when is_bitstring(mock_data), do: {:ok, mock_data}

  @doc """
  Recieve data from a socket\n

  ### Recieve data until the socket closes

      {:ok, data} = Request.data(socket)

  ### Recieve data once

      {:ok, data} = Request.data(socket, :once)
  """
  def data(socket, loop \\ :until_closed, previous_bytes \\ []) do
    case :gen_tcp.recv(socket, 0, 4000) do
      {:ok, bytes} when loop == :once -> {:ok, IO.iodata_to_binary(bytes)}
      {:ok, bytes} -> data(socket, true, [previous_bytes, bytes])
      {:error, :closed} when previous_bytes == [] -> {:error, :closed}
      {:error, :closed} -> {:ok, IO.iodata_to_binary(previous_bytes)}
    end
  end

  @doc """
  Recieves data once and parses the client header information and request fields\n
  ## Examples
      Request.client_header(socket).method
      "GET"
  Name | Description
  --- | ---
  method | GET, POST, PUT ...
  path | The url without the query ex: http://localhost/one/two/three?test=1 -> /one/two/three
  query | The unparsed query string ex: http://localhost/one/two/three?test=1 -> test=1
  fields | Accept, Cookies ...
  """
  def client_header(socket) do
    {:ok, header} = data(socket, :once) # Receive only once
    [basic_info | encoded_fields] = String.split(to_string(header), "\r\n")

    [method, url | _] = String.split(basic_info)

    fields = parse_header_fields(encoded_fields)

    case String.split(url, "?") do
      [path, query] -> %{method: method, fields: fields, path: path, query: query}
      [path] -> %{method: method, fields: fields, path: path, query: nil}
    end
  end

  @doc """
  Recieves data once and parses the client header information and request fields\n
  ## Examples
      Request.server_header(socket).status_code
      
  Name | Description
  --- | ---
  status_code | 200, 400, 404 ...
  status_message |  OK, Invalid Url ...
  fields | content-type, content-length ...
  """
  def server_header(socket) do
    {:ok, header} = data(socket, :once)
    [_http_version, status_code | status_message_and_encoded_fields] = String.split(header, " ")
    [status_message | encoded_fields] = String.split(Enum.join(status_message_and_encoded_fields, " "), "\n") 
    %{status_code: String.to_integer(status_code), status_message: status_message, fields: parse_header_fields(encoded_fields)}
  end

  def parse_header_fields(encoded_fields) do
    Enum.reduce(encoded_fields, %{}, fn(field, map) ->
      case field do
        "" -> map
        _ ->
        case String.split(field, ": ") do
          [key, value] -> Map.put(map, key, value)
          _ -> map
        end
      end
    end)
  end

  @doc ~S"""
  Parses GET or POST parameters from a string into a map\n
  Arrays can be denoted by adding '[]' to the end of the variable name

  ## Examples
      iex> Request.parse_params "a=0&b[]=1&b[]=2"
      %{"a" => "0", "b" => ["2", "1"]}
  """ 
  def parse_params(nil), do: %{}
  def parse_params(encoded_params) do
    key_value_pairs = String.split(encoded_params,"&")
    Enum.reduce(key_value_pairs, %{}, fn(key_value_pair, map) ->
      case String.split(key_value_pair, "=") do
        ["" | _] -> map
        [key, value] ->
          # Arrays in params may be encoded as:
          # ?arr[]=1&arr[]=2&arr[]=3  ==  [1, 2, 3]
          case String.ends_with?(key, "[]") do
            true ->
              trimmed_key = String.downcase(String.replace(key, "[]", ""))
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
