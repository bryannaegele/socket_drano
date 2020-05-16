defmodule SocketDranoTest do
  use ExUnit.Case
  doctest SocketDrano

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
end
