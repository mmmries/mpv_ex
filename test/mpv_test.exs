defmodule MpvTest do
  use ExUnit.Case

  test "returns the mpv path" do
    assert is_binary(Mpv.binary_path())
  end
end
