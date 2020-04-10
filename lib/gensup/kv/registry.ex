defmodule Gensup.KV.Registry do
  @moduledoc """
  A registry for (Agent) buckets.

  See also the GenServer cheat sheet:
  https://elixir-lang.org/cheatsheets/gen-server.pdf
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
    # The docs say that `call` probably should have been used here,
    # because you want to make sure that the server has created the
    # item. `cast` "should be used sparingly."
    GenServer.cast(server, {:create, name})
  end

  ##########
  # Server #
  ##########
  @impl true
  def init(:ok) do
    names = %{}
    refs = %{}
    {:ok, {names, refs}}
  end

  @impl true
  def handle_call({:lookup, name}, _from, state) do
    {names, _} = state
    {:reply, Map.fetch(names, name), state}
  end

  @impl true
  def handle_cast({:create, name}, {names, refs}) do
    if Map.has_key?(names, name) do
      {:noreply, {names, refs}}
    else
      # This isn't ideal because the registry will crash when the bucket crashes.
      # Fix it with supervisors.
      {:ok, bucket} = Gensup.KV.Bucket.start_link([])
      ref = Process.monitor(bucket)
      refs = Map.put(refs, ref, name)
      names = Map.put(names, name, bucket)
      {:noreply, {names, refs}}
    end
  end

  @doc """
  Delete an Agent process from the registry if it goes down.

  `handle_info` is used for all other messages a server may receive that
  aren't `call` or `cast`. (e.g., `:DOWN`) See the catch-all below.
  """
  @impl true
  def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
    {name, refs} = Map.pop(refs, ref)
    names = Map.delete(names, name)
    {:noreply, {names, refs}}
  end

  @doc """
  This catch-all clause handles unexpected messages that could crash the
  registry.
  """
  @impl true
  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
