defmodule SocketDrano.Plug do
  @moduledoc """
  Closes connections with keep-alive set on the connection.
  [Do not use this in combination with HTTP2](https://tools.ietf.org/html/rfc7540#section-8.1.2.2)
  """

  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    if SocketDrano.draining?() do
      put_resp_header(conn, "connection", "close")
    else
      conn
    end
  end
end
