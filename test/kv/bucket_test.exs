defmodule Gensup.KV.BucketTest do
  use ExUnit.Case, async: true
  alias Gensup.KV

  setup do
    {:ok, bucket} = KV.Bucket.start_link([])
    %{bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    assert KV.Bucket.get(bucket, "oranges") == nil

    KV.Bucket.put(bucket, "oranges", 3)
    assert KV.Bucket.get(bucket, "oranges") == 3
  end

  test "deletes value by key", %{bucket: bucket} do
    KV.Bucket.put(bucket, "mochi", 2)
    KV.Bucket.put(bucket, "daikon", 1)

    assert KV.Bucket.get(bucket, "mochi") == 2
    assert KV.Bucket.get(bucket, "daikon") == 1

    # only delete mochi
    assert KV.Bucket.delete(bucket, "mochi") == 2
    assert KV.Bucket.get(bucket, "daikon") == 1
    assert KV.Bucket.get(bucket, "mochi") == nil
  end
end
