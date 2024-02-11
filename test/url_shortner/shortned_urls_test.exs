defmodule UrlShortner.ShortnedUrlsTest do
  use UrlShortner.DataCase
  use UrlShortner.CacheCase

  import UrlShortner.Factory

  alias UrlShortner.ShortnedUrls

  describe "create_shortned_url/1" do
    test "creates a shortned url" do
      {:ok, shortned_url} =
        ShortnedUrls.create_shortned_url(%{original_url: "https://www.example.com"})

      assert shortned_url.original_url == "https://www.example.com"
      assert shortned_url.slug != nil
    end

    test "returns an error when attrs are invalid" do
      assert {:error, changeset} = ShortnedUrls.create_shortned_url(%{})
      refute changeset.valid?
      assert changeset.errors[:original_url] == {"can't be blank", [validation: :required]}
    end
  end

  describe "get_shortned_url_by_id/1" do
    test "returns a shortned url" do
      shortned_url = insert!(:shortned_url)

      assert shortned_url = UrlShortner.ShortnedUrls.get_shortned_url_by_id(shortned_url.id)
      assert shortned_url.id == shortned_url.id
    end

    test "returns an error when shortned url is not found" do
      assert {:error, :not_found} =
               UrlShortner.ShortnedUrls.get_shortned_url_by_id(Ecto.UUID.generate())
    end

    test "returns an error when id is invalid" do
      assert {:error, :not_found} = UrlShortner.ShortnedUrls.get_shortned_url_by_id("invalid")
    end
  end

  describe "get_original_url/1" do
    test "returns the associated original url" do
      shortned_url = insert!(:shortned_url)

      assert original_url = UrlShortner.ShortnedUrls.get_original_url(shortned_url.slug)
      assert original_url == shortned_url.original_url
    end

    test "returns nil when the original url is not found" do
      assert nil == UrlShortner.ShortnedUrls.get_original_url("not-found")
    end
  end
end
