defmodule ShortnedUrl.Schema.ShortnedUrlTest do
  use UrlShortner.DataCase

  alias UrlShortner.Schema.ShortnedUrl

  describe "create_changeset/1" do
    test "is invalid when original_url is missing" do
      changeset = ShortnedUrl.create_changeset(%{})
      assert changeset.errors[:original_url] == {"can't be blank", [validation: :required]}
    end

    test "is invalid when original_url is not a valid URL" do
      invalid_urls = [
        "not a url",
        "http://",
        "https://",
        "postgres://test:test@localhost:5432/test",
        "google.com"
      ]

      for url <- invalid_urls do
        changeset = ShortnedUrl.create_changeset(%{original_url: url})
        assert changeset.errors[:original_url] == {"is not a valid URL", []}
      end
    end

    test "is valid when original_url is present and valid" do
      valid_urls = ["http://google.com", "https://google.com", "https://google.com?search=test"]

      for url <- valid_urls do
        changeset = ShortnedUrl.create_changeset(%{original_url: url})
        assert changeset.valid?
      end
    end

    test "generates a unique slug" do
      changeset = ShortnedUrl.create_changeset(%{original_url: "http://example.com"})
      assert changeset.changes[:slug] != nil
    end
  end
end
