defmodule Mpv.Connection do
  use GenServer
  require Logger

  def start_link(socket_path, options \\ []) do
    GenServer.start_link(__MODULE__, socket_path, options)
  end

  def request(conn, request) when is_map(request) do
    GenServer.call(conn, {:request, request})
  end

  def init(socket_path) do
    {:ok, tcp} = :gen_tcp.connect({:local, socket_path}, 0, [:local, :binary])
    state = %{request_id: 1, tcp: tcp, requests: %{}}
    {:ok, state}
  end

  def handle_call({:request, request}, from, state) do
    state = send_request(request, from, state)
    {:noreply, state}
  end

  def handle_info({:tcp, _port, str}, state) do
    # TODO handle partial json strings and multiple json strings
    state =
      case Jason.decode!(str) do
        %{"request_id" => id, "error" => "success", "data" => data} ->
          send_response({:ok, data}, id, state)

        %{"request_id" => id, "error" => "success"} ->
          send_response(:ok, id, state)

        %{"request_id" => id, "error" => error} ->
          send_response({:error, error}, id, state)

        %{"request_id" => id} = payload ->
          send_response({:error, payload}, id, state)

        %{"event" => _event} ->
          # TODO publish this somewhere?
          Logger.info(str, label: "MPV event")
          state
      end

    {:noreply, state}
  end

  def handle_info(other, state) do
    Logger.error("#{__MODULE__} received unexpected message: #{inspect(other)}")
    {:noreply, state}
  end

  defp send_response(response, request_id, state) do
    from = Map.fetch!(state.requests, request_id)
    GenServer.reply(from, response)
    requests = Map.delete(state.requests, request_id)
    %{state | requests: requests}
  end

  defp send_request(request, from, %{request_id: id} = state) do
    request = Map.put(request, :request_id, id)
    requests = Map.put(state.requests, id, from)
    :ok = :gen_tcp.send(state.tcp, [Jason.encode!(request), "\n"])
    %{state | requests: requests, request_id: id + 1}
  end
end
