defmodule NoSlides.VNode do
  @behaviour :riak_core_vnode
  require Logger
  require Record

  Record.defrecord :fold_req_v2, :riak_core_fold_req_v2, Record.extract(:riak_core_fold_req_v2, from_lib: "riak_core/include/riak_core_vnode.hrl")

  def start_vnode(partition) do
    :riak_core_vnode_master.get_vnode_pid(partition, __MODULE__)
  end

  def init([partition]) do
    {:ok, %{partition: partition, data: %{}}}
  end

  def handle_command({:ping, v}, _sender, state) do
    {:reply, {:pong, v + 1}, state}
  end
  def handle_command({:put, {k, v}}, _sender, state) do
    Logger.debug("[put]: k: #{inspect k} v: #{inspect v}")
    new_state = Map.update(state, :data, %{}, fn data -> Map.put(data, k, v) end)
    {:noreply, new_state}
  end
  def handle_command({:get, k}, _sender, state) do
    Logger.debug("[get]: k: #{inspect k}")
    {:reply, Map.get(state.data, k, nil), state}
end

  def handoff_starting(_dest, state) do
    {true, state}
  end

  def handoff_cancelled(state) do
    {:ok, state}
  end

  def handoff_finished(_dest, state) do
    {:ok, state}
  end

  def handle_handoff_command(fold_req_v2() = fold_req, _sender, state) do
    Logger.debug ">>>>> Handoff V2 <<<<<<"
    foldfun = fold_req_v2(fold_req, :foldfun)
    acc0 = fold_req_v2(fold_req, :acc0)
    acc_final = state.data |> Enum.reduce(acc0, fn {k, v}, acc ->
      foldfun.(k, v, acc)
    end)
    {:reply, acc_final, state}
  end
  def handle_handoff_command(request, sender, state) do
    Logger.debug ">>> Handoff generic request <<<"
    handle_command(request, sender, state)
  end

  def is_empty(state) do
    {true, state}
  end

  def terminate(_reason, _state) do
    :ok
  end

  def delete(state) do
    {:ok, Map.put(state, :data, %{})}
  end

  def handle_handoff_data(bin_data, state) do
    {k, v} = :erlang.binary_to_term(bin_data)
    {:reply, :ok, state}
  end

  def encode_handoff_item(k, v) do
    :erlang.term_to_binary({k,v})
  end

  def handle_coverage(_req, _key_spaces, _sender, state) do
    {:stop, :not_implemented, state}
  end

  def handle_exit(_pid, _reason, state) do
    {:noreply, state}
  end

end
