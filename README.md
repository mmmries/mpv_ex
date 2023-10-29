# Mpv

A little library for interacting with [MPV](mpv.io) to play media
This library assumes that mpv is already installed on your system, it then starts an mpv process and communicates with the [JSON IPC](https://mpv.io/manual/stable/#json-ipc) protocol to discover metadata about the media and control playback.

## Example

```elixir
{:ok, mpv} = Mpv.start_link("my_podcast.mp3")
{:ok, 358.182} = Mpv.duration(mpv) # the duration in seconds
{:ok, "Why Elixir Is Awesome"} = Mpv.title(mpv) # get the title of the track
:ok = Mpv.play(mpv) # start playing the audio
:timer.sleep(1_000)
:ok = Mpv.pause(mpv) # pause the audio
{:ok, 1.0} = Mpv.position(mpv) # get the current playback position
:ok = Mpv.stop(mpv)
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `mpv` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:mpv, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/mpv>.

