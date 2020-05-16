defmodule SocketDrano.DranoSignalHandlerTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureLog

  test "SIGTERM starts draining, then stops after delay" do
    delay = 5

    :drano_signal_handler.setup(
      shutdown_delay: delay,
      callback: {__MODULE__, :test_callback, [self()]}
    )

    assert capture_log(fn ->
             :gen_event.notify(:erl_signal_server, {:sigterm, :test})
             Process.sleep(50)
           end) =~ "SIGTERM received"

    assert_receive :callback_called
  end

  def test_callback(pid) do
    send(pid, :callback_called)
  end
end
