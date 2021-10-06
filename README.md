# SocketDrano

Process to gracefully drain Phoenix Socket connections at shutdown.

`Plug.Cowboy.Drainer` is able to handle draining of connections as they complete during
a shutdown. Websockets, however, are long-lived connections which may not complete before
timeout periods are reached, especially if they have a heartbeat to keep alive. This library
handles both in a single dep to keep things simple.

This module provides a process that during shutdown will initiate shutdown of open Phoenix
sockets. 

Refer to the [HexDocs](https://hexdocs.pm/socket_drano) for more information and examples.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `socket_drano` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:socket_drano, "~> 0.5.0"}
  ]
end
```
