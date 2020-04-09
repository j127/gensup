defmodule Gensup.KV.RegistryTest do
  use ExUnit.Case, async: true
  alias Gensup.KV

  setup do
    registry = start_supervised!(KV.Registry)
    %{registry: registry}
  end

  test "spawns buckets", %{registry: registry} do
    assert KV.Registry.lookup(registry, "shopping") == :error

    KV.Registry.create(registry, "shopping")
    assert {:ok, bucket} = KV.Registry.lookup(registry, "shopping")

    KV.Bucket.put(bucket, "rutabaga", 2)
    assert KV.Bucket.get(bucket, "rutabaga") == 2
  end
end
