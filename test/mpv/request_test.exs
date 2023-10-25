defmodule Mpv.RequestTest do
  use ExUnit.Case, async: true
  alias Mpv.Request

  describe "get_property" do
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

  test "chapter_list" do
    assert Request.chapter_list() == %{command: [:get_property, :"chapter-list"], async: true}
  end

  test "paused?" do
    assert Request.paused?() == %{command: [:get_property, :pause], async: true}
  end

  test "seek" do
    assert Request.seek(101.1) == %{command: [:seek, 101.1, :absolute], async: true}
  end

  test "title" do
    assert Request.title() == %{command: [:get_property, :"media-title"], async: true}
  end
end
