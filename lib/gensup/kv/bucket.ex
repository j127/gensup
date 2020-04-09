defmodule Gensup.KV.Bucket do
  use Agent

  @doc """
  Start a bucket.
  """
  def start_link(_opts) do
    Agent.start_link(fn -> %{} end)
  end

  @doc """
  Get a value from the bucket by key.
  """
  def get(bucket, key) do
    Agent.get(bucket, &Map.get(&1, key))
  end

  @doc """
  Put the value for the given key in the bucket.
  """
  def put(bucket, key, value) do
    Agent.update(bucket, &Map.put(&1, key, value))
  end

  @doc """
  Delete key from bucket.

  Returns the current value of key if it exists.

  A note from the docs:

  The second argument happens on the Agent server. Everything else
  happens on the client. If you perform expensive computations on the
  server, it can block other clients from using that server.

  Example:

  ```
  def delete(bucket, key) do
    Process.sleep(1000) # puts client to sleep
    Agent.get_and_update(bucket, fn dict ->
      Process.sleep(1000) # puts server to sleep
      Map.pop(dict, key)
    end)
  end
  ```
  """
  def delete(bucket, key) do
    Agent.get_and_update(bucket, &Map.pop(&1, key))
  end
end
