defmodule MpvTest do
  use ExUnit.Case

  test "opening a simple audio file" do
    {:ok, mpv} = Mpv.open(fixture("Frogs-At-Night.mp3"))
    assert :ok = Mpv.wait_for_ready(mpv)
    # give time for mpv to finish loading the file
    :timer.sleep(100)
    assert {:ok, "Frogs At Night"} = Mpv.title(mpv)
    assert {:ok, 42.684082} = Mpv.duration(mpv)
    assert {:ok, 0.0} = Mpv.position(mpv)
    assert {:ok, nil} = Mpv.seek(mpv, 13.125)
    assert {:ok, 13.125} = Mpv.position(mpv)
    assert {:ok, []} = Mpv.chapter_list(mpv)
    assert :ok = Mpv.close(mpv)
    assert Process.alive?(mpv) == false
  end

  test "opening an audio file with chapters" do
    {:ok, mpv} = Mpv.open(fixture("auphonic_chapters_demo.mp3"))
    assert :ok = Mpv.wait_for_ready(mpv)
    # give time for mpv to finish loading the file
    :timer.sleep(100)
    assert {:ok, "Auphonic Chapter Marks Demo"} = Mpv.title(mpv)
    assert {:ok, chapters} = Mpv.chapter_list(mpv)
    assert length(chapters) == 9
    assert hd(chapters) == %{"time" => -0.025056, "title" => "Intro"}
  end

  defp fixture(name) do
    Path.join([__DIR__, "fixtures", name])
  end
end
