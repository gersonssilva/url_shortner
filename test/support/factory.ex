defmodule UrlShortner.Factory do
  alias UrlShortner.Repo
  alias UrlShortner.Schema.ShortnedUrl

  def build(:shortned_url) do
    %ShortnedUrl{
      original_url: "http://example.com"
    }
  end

  def build(factory_name, attrs \\ []) do
    factory_name |> build() |> struct!(attrs)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
