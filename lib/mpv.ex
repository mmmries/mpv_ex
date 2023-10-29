defmodule Mpv do
  @spec binary_path :: Path.t()
  def binary_path do
    Application.get_env(:mpv, :binary_path)
  end

  def chapter_list(mpv) do
    request(mpv, Mpv.Request.chapter_list())
  end

  def close(mpv) do
    GenServer.stop(mpv)
  end

  def duration(mpv) do
    request(mpv, Mpv.Request.duration())
  end

  def open(path) do
    GenServer.start_link(__MODULE__, path)
  end

  def position(mpv) do
    request(mpv, Mpv.Request.position())
  end

  def request(mpv, request) do
    GenServer.call(mpv, {:request, request})
  end

  def seek(mpv, position) do
    request(mpv, Mpv.Request.seek(position))
  end

  def title(mpv) do
    request(mpv, Mpv.Request.title())
  end

  def wait_for_ready(mpv) do
    wait_for_ready(mpv, 20, 25)
  end

  def wait_for_ready(mpv, attempts, delay) do
    case request(mpv, Mpv.Request.get_property(:"mpv-version")) do
      {:ok, _str} ->
        :ok

      {:error, :not_ready} ->
        if attempts > 0 do
          Process.sleep(delay)
          wait_for_ready(mpv, attempts - 1, delay)
        else
          {:error, :timeout}
        end

      {:error, other} ->
        {:error, other}
    end
  end

  ## GenSerer stuff
  use GenServer
  require Logger

  @max_connection_attempts 50
  @socket_check_delay 10

  @impl GenServer
  def init(path) do
    nuid = :crypto.strong_rand_bytes(12) |> Base.encode16()
    socket_path = Path.join("/tmp", nuid)

    args = [
      "--no-video",
      "--pause",
      "--no-audio-display",
      "--terminal=no",
      path,
      "",
      ~s[--input-ipc-server=#{socket_path}]
    ]

    port = Port.open({:spawn_executable, binary_path()}, [:binary, :exit_status, args: args])
    schedule_socket_check()

    {:ok, %{port: port, socket_path: socket_path, connection: nil, socket_attempts: 0}}
  end

  @impl GenServer
  def handle_call({:request, _request}, _from, %{error: error} = state) do
    {:reply, {:error, error}, state}
  end

  def handle_call({:request, _request}, _from, %{connection: nil} = state) do
    {:reply, {:error, :not_ready}, state}
  end

  def handle_call({:request, request}, _from, %{connection: conn} = state) do
    {:reply, Mpv.Connection.request(conn, request), state}
  end

  @impl GenServer
  def handle_info(:check_socket_path, %{socket_attempts: @max_connection_attempts} = state) do
    state = Map.put(state, :error, "timed out starting mpv")
    {:noreply, state}
  end

  def handle_info(:check_socket_path, state) do
    case File.exists?(state.socket_path) do
      true ->
        {:ok, conn} = Mpv.Connection.start_link(state.socket_path)
        {:noreply, %{state | connection: conn}}

      false ->
        schedule_socket_check()
        {:noreply, %{state | socket_attempts: state.socket_attempts + 1}}
    end
  end

  def handle_info(other, state) do
    Logger.info("Got: #{inspect(other)}")
    {:noreply, state}
  end

  defp schedule_socket_check() do
    Process.send_after(self(), :check_socket_path, @socket_check_delay)
  end
end
