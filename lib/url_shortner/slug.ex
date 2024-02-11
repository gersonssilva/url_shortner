defmodule UrlShortner.Slug do
  @moduledoc """
  Module for generating slugs.
  """

  @slug_size_bytes 8

  @doc """
  Generates a random slug to be used as a short URL.

  The slug is generated using a cryptographically secure random number generator,
  and then encoded using Base64 URL encoding to avoid any special characters.

  The current implementation uses 8 bytes of random data, which results in a 11 character
  slug. I believe this to be good tradeoff between the slug length and the probablity of a collision.
  """

  @spec generate() :: String.t()
  def generate do
    @slug_size_bytes
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64(padding: false)
  end
end
