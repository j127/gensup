defmodule Gensup.KV.Supervisor do
  use Supervisor
  alias Gensup.KV

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, :ok, opts)
  end

  @impl true
  def init(:ok) do
    children = [
      # "we can name a process after the module that implements it"
      # That makes it so you don't need to look up the PID from the supervisor.
      # iex> KV.Supervisor.start_link([])
      # {:ok, #PID<0.66.0>}
      # iex> KV.Registry.create(KV.Registry, "shopping")
      # :ok
      # iex> KV.Registry.lookup(KV.Registry, "shopping")
      # {:ok, #PID<0.70.0>}
      {KV.Registry, name: Gensup.KV.Registry}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
