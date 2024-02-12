defmodule UrlShortner.ShortnedUrlsTest do
  use UrlShortner.DataCase, async: false
  use UrlShortner.CacheCase

  import UrlShortner.Factory

  alias UrlShortner.{Repo, ShortnedUrls}

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

      # Small wait for the Cachex process to finish using the DB connection,
      # avoiding error logs during tests
      Process.sleep(100)
    end

    test "returns nil when the original url is not found" do
      assert nil == UrlShortner.ShortnedUrls.get_original_url("not-found")
    end
  end

  describe "incr_visits!/1" do
    test "increments the visits count for a shortned url" do
      shortned_url = insert!(:shortned_url)

      assert shortned_url.visits_count == 0

      assert {:ok, shortned_url} = UrlShortner.ShortnedUrls.incr_visits!(shortned_url)

      assert shortned_url.visits_count == 1
    end

    test "raises an exception when the update fails" do
      shortned_url = build(:shortned_url)

      assert 0 == shortned_url.visits_count

      assert_raise Ecto.NoPrimaryKeyValueError, fn ->
        UrlShortner.ShortnedUrls.incr_visits!(shortned_url)
      end
    end
  end

  describe "async_incr_visits/1" do
    test "increments the visits count for a shortned url asynchronously" do
      shortned_url = insert!(:shortned_url)

      assert shortned_url.visits_count == 0

      assert {:ok, _pid} = ShortnedUrls.async_incr_visits(shortned_url)

      assert Liveness.eventually(
               fn ->
                 shortned_url = Repo.reload!(shortned_url)
                 shortned_url.visits_count == 1
               end,
               250,
               2
             )
    end
  end
end
