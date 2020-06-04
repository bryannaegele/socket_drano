defmodule SocketDrano.DranoSignalHandlerTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureLog

  test "SIGTERM starts draining, then stops after delay" do
    delay = 1000

    :drano_signal_handler.setup(
      shutdown_delay: delay,
      callback: {__MODULE__, :test_callback, [self()]}
    )

    assert capture_log(fn ->
             :gen_event.notify(:erl_signal_server, {:sigterm, :test})
             Process.sleep(500)
           end) =~ "SIGTERM received"

    assert_receive :callback_called, 1000
  end

  def test_callback(pid) do
    Process.sleep(1000)
    send(pid, :callback_called)
  end
end
