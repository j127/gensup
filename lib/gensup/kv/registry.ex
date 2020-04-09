defmodule Gensup.KV.Registry do
  @moduledoc """
  A registry for (Agent) buckets.
  """

  use GenServer

  ##########
  # Client #
  ##########
  @doc """
  Start the registry.
  """
  def start_link(opts) do
    # GenServer.start_link/3 args:
    # 1. location of server callbacks (this module)
    # 2. initialization arguments (`:ok`)
    # 3. list of any options passed in from above
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc """
  Look up the bucket pid for the `name` stored in `server`.

  Return `{:ok, pid}` if the bucket exists, else `:error`.
  """
  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  @doc """
  Ensure there is a bucket associated with the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  ##########
  # Server #
  ##########
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
