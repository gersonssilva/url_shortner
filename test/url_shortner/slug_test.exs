defmodule UrlShortner.SlugTest do
  use ExUnit.Case

  alias UrlShortner.Slug

  test "generates a slug with 11 characters" do
    assert String.length(Slug.generate()) == 11
  end

  test "generates a URL-safe slug" do
    assert Regex.match?(~r/^[A-Za-z0-9_-]+$/, Slug.generate())
  end
end
