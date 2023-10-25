defmodule Mpv.ConnectionTest do
  use ExUnit.Case, async: true
  alias Mpv.Connection

  describe "handling JSON payloads from the mpv process" do
    test "parsing individual messages with data" do
      state = %{requests: %{1 => self_from()}, partial: nil}
      str = Jason.encode!(%{request_id: 1, error: "success", data: 100.0}) <> "\n"
      {:noreply, state} = Connection.handle_info({:tcp, nil, str}, state)
      assert_received {_ref, {:ok, 100.0}}
      assert state.requests == %{}
    end

    test "parsing successful command responses" do
      state = %{requests: %{1 => self_from()}, partial: nil}
      str = Jason.encode!(%{request_id: 1, error: "success"}) <> "\n"
      {:noreply, state} = Connection.handle_info({:tcp, nil, str}, state)
      assert_received {_ref, :ok}
      assert state.requests == %{}
    end

    test "parsing failed command responses" do
      state = %{requests: %{1 => self_from()}, partial: nil}
      str = Jason.encode!(%{request_id: 1, error: "wat"}) <> "\n"
      {:noreply, state} = Connection.handle_info({:tcp, nil, str}, state)
      assert_received {_ref, {:error, "wat"}}
      assert state.requests == %{}
    end

    test "receiving multiple json payloads" do
      state = %{requests: %{1 => self_from()}, partial: nil}

      str =
        [
          Jason.encode!(%{request_id: 1, error: "wat"}),
          "\n",
          Jason.encode!(%{event: "event_name"}),
          "\n"
        ]
        |> IO.iodata_to_binary()

      {:noreply, state} = Connection.handle_info({:tcp, nil, str}, state)
      assert_received {_ref, {:error, "wat"}}
      assert state.requests == %{}
    end

    test "receiving partial json payloads" do
      state = %{requests: %{1 => self_from()}, partial: nil}
      str = Jason.encode!(%{request_id: 1, error: "wat"}) <> "\n"
      {s1, s2} = String.split_at(str, 6)
      {:noreply, state} = Connection.handle_info({:tcp, nil, s1}, state)
      assert state.partial == s1
      {:noreply, state} = Connection.handle_info({:tcp, nil, s2}, state)
      assert_received {_ref, {:error, "wat"}}
      assert state.partial == nil
      assert state.requests == %{}
    end

    defp self_from do
      {self(), make_ref()}
    end
  end
end
