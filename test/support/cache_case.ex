defmodule UrlShortner.CacheCase do
  use ExUnit.CaseTemplate

  setup do
    Cachex.clear(:shortned_urls)

    :ok
  end
end
