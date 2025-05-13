defmodule SocketDranoTest do
  use ExUnit.Case
  doctest SocketDrano

  setup do
    # Detach the Phoenix.Logger handler for [:phoenix, :channel_joined]
    :telemetry.detach({Phoenix.Logger, [:phoenix, :channel_joined]})
    :ok
  end

  test "it starts" do
    spec = %{
      id: SocketDrano,
      start: {
        SocketDrano,
        :start_link,
        [
          [
            {:strategy, {:percentage, 25, 100}},
            {:name, SocketDrano},
            {:drain_check_interval, 1000},
            {:shutdown_delay, 5000},
            {:refs, [MyApp.Endpoint.HTTP]}
          ]
        ]
      },
      type: :worker
    }

    assert SocketDrano.child_spec(refs: [MyApp.Endpoint.HTTP]) == spec
  end

  test "it takes opts" do
    spec2 = %{
      id: SocketDrano,
      start: {
        SocketDrano,
        :start_link,
        [
          [
            {:name, SocketDrano},
            {:strategy, {:percentage, 5, 100}},
            {:drain_check_interval, 500},
            {:shutdown_delay, 10_000},
            {:refs, [MyApp.Endpoint.HTTP, MyApp.Endpoint.HTTPS]}
          ]
        ]
      },
      type: :worker
    }

    assert SocketDrano.child_spec(
             strategy: {:percentage, 5, 100},
             drain_check_interval: 500,
             shutdown_delay: 10_000,
             refs: [MyApp.Endpoint.HTTP, MyApp.Endpoint.HTTPS]
           ) == spec2
  end

  test "sockets are monitored and shed" do
    Application.ensure_started(:telemetry)

    :telemetry.attach(
      "monitor_start",
      [:socket_drano, :monitor, :start],
      &__MODULE__.handle_event/4,
      %{pid: self()}
    )

    :telemetry.attach(
      "monitor_stop",
      [:socket_drano, :monitor, :stop],
      &__MODULE__.handle_event/4,
      %{pid: self()}
    )

    assert SocketDrano.socket_count() == :not_running

    spec = SocketDrano.child_spec(refs: [], shutdown_delay: 10_000)
    start_supervised!(spec)
    disconnects_pid = spawn_link(fn -> disconnects([]) end)

    refute SocketDrano.draining?()

    sockets =
      Enum.map(1..1000, fn id ->
        spawn_link(fn -> start_socket_process(id, disconnects_pid) end)
        id
      end)

    Process.sleep(100)

    assert SocketDrano.socket_count() == 1000

    SocketDrano.start_draining()

    Process.sleep(500)

    assert SocketDrano.draining?()

    send(disconnects_pid, {:get_ids, self()})

    receive do
      {:disconnected_ids, ids} ->
        assert Enum.sort(ids) == Enum.sort(sockets)
    after
      10000 ->
        flunk()
    end
  end

  def start_socket_process(id, monitor_pid) do
    socket = %Phoenix.Socket{
      transport: :websocket,
      transport_pid: self(),
      endpoint: __MODULE__,
      channel: __MODULE__,
      channel_pid: self(),
      topic: "room:lobby",
      serializer: Phoenix.Socket.V2.JSONSerializer
    }

    :telemetry.execute([:phoenix, :channel_joined], %{}, %{socket: socket})

    receive do
      %Phoenix.Socket.Broadcast{event: "disconnect"} ->
        send(monitor_pid, {:disconnect, id})
    end
  end

  def disconnects(ids) do
    receive do
      {:disconnect, id} ->
        disconnects([id | ids])

      {:get_ids, caller} ->
        send(caller, {:disconnected_ids, ids})
    end
  end

  def handle_event(event, measurements, meta, config) do
    send(config.pid, {:event, event, measurements, meta, config})
  end
end
