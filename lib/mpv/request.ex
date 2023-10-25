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
  def get_property(prop) when prop in @properties do
    command(:get_property, [prop])
  end

  def seek(timestamp) when is_float(timestamp) do
    command(:seek, [timestamp, :absolute])
  end

  def set_property(prop, value) when prop in @properties do
    command(:set_property, [prop, value])
  end

  def valid_property?(prop) do
    prop in @properties
  end

  defp command(cmd, args) do
    %{command: [cmd | args], async: true}
  end
end
