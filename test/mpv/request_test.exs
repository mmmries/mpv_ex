defmodule Mpv.RequestTest do
  use ExUnit.Case, async: true
  alias Mpv.Request

  test "pause property" do
    assert Request.get_property(:pause) == %{command: [:get_property, :pause], async: true}
  end

  test "volume property" do
    assert Request.get_property(:volume) == %{command: [:get_property, :volume], async: true}
  end

  test "time-pos property" do
    assert Request.get_property(:"time-pos") == %{
             command: [:get_property, :"time-pos"],
             async: true
           }
  end
end
