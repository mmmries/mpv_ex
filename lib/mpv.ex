defmodule Mpv do
  @spec binary_path :: Path.t()
  def binary_path do
    Application.get_env(:mpv, :binary_path)
  end

  def sample_path do
    {:ok, dir} = File.cwd()
    Path.join(dir, "tmp/sample.mp3")
  end
end
