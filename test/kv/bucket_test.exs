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
end
