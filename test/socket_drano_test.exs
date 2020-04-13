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
            {:refs, [MyApp.Endpoint.HTTP]}
          ]
        ]
      },
      shutdown: 5000,
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
            {:refs, [MyApp.Endpoint.HTTP, MyApp.Endpoint.HTTPS]}
          ]
        ]
      },
      shutdown: 10000,
      type: :worker
    }

    assert SocketDrano.child_spec(
             strategy: {:percentage, 5, 100},
             shutdown: 10_000,
             drain_check_interval: 500,
             refs: [MyApp.Endpoint.HTTP, MyApp.Endpoint.HTTPS]
           ) == spec2
  end
end
