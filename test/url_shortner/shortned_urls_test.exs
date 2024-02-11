defmodule UrlShortner.ShortnedUrlsTest do
  use UrlShortner.DataCase

  describe "create_shortned_url/1" do
    test "creates a shortned url" do
      attrs = %{
        original_url: "https://www.example.com"
      }

      assert {:ok, shortned_url} = UrlShortner.ShortnedUrls.create_shortned_url(attrs)
      assert shortned_url.original_url == "https://www.example.com"
      assert shortned_url.slug != nil
    end

    test "returns an error when attrs are invalid" do
      attrs = %{}

      assert {:error, changeset} = UrlShortner.ShortnedUrls.create_shortned_url(attrs)
      refute changeset.valid?
      assert changeset.errors[:original_url] == {"can't be blank", [validation: :required]}
    end
  end

  describe "get_shortned_url_by_id/1" do
    test "returns a shortned url" do
      {:ok, shortned_url} = UrlShortner.ShortnedUrls.create_shortned_url(%{
        original_url: "https://www.example.com"
      })

      assert shortned_url = UrlShortner.ShortnedUrls.get_shortned_url_by_id(shortned_url.id)
      assert shortned_url.id == shortned_url.id
    end

    test "returns an error when shortned url is not found" do
      assert {:error, :not_found} = UrlShortner.ShortnedUrls.get_shortned_url_by_id(Ecto.UUID.generate())
    end

    test "returns an error when id is invalid" do
      assert {:error, :not_found} = UrlShortner.ShortnedUrls.get_shortned_url_by_id("invalid")
    end
  end
end