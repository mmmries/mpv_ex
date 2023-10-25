defmodule Mpv.Request do
  @properties [
    :chapter,
    :"chapter-list",
    :chapters,
    :duration,
    :"media-title",
    :metadata,
    :pause,
    :seekable,
    :"time-pos",
    :"time-remaining",
    :"track-list",
    :volume
  ]

  def chapter_list do
    get_property(:"chapter-list")
  end

  def duration do
    get_property(:duration)
  end

  def get_property(prop) when prop in @properties do
    command(:get_property, [prop])
  end

  def pause do
    set_property(:pause, true)
  end

  def position do
    get_property(:"time-pos")
  end

  def paused? do
    get_property(:pause)
  end

  def seek(timestamp) when is_float(timestamp) do
    command(:seek, [timestamp, :absolute])
  end

  def set_property(prop, value) when prop in @properties do
    command(:set_property, [prop, value])
  end

  def title do
    get_property(:"media-title")
  end

  def unpause do
    set_property(:pause, false)
  end

  def valid_property?(prop) do
    prop in @properties
  end

  defp command(cmd, args) do
    %{command: [cmd | args], async: true}
  end
end
