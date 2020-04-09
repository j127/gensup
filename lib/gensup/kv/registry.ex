defmodule Gensup.KV.Registry do
  @moduledoc """
  A registry for (Agent) buckets.
  """

  use GenServer

  # Client

  # Server
  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, names) do
    {:reply, Map.fetch(names, name), names}
  end

  @impl true
  def handle_cast({:create, name}, names) do
    if Map.has_key?(names, name) do
      {:noreply, names}
    else
      {:ok, bucket} = Gensup.KV.Bucket.start_link([])
      {:noreply, Map.put(names, name, bucket)}
    end
  end
end
