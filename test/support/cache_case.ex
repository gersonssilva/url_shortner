defmodule UrlShortner.CacheCase do
  @moduledoc """
    A test case that clears the cache before each test.
  """

  use ExUnit.CaseTemplate

  setup do
    Cachex.clear(:shortned_urls)

    :ok
  end
end
