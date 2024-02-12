defmodule UrlShortner.ShortnedUrls do
  @moduledoc """
  Context module for shortned urls.
  """

  alias UrlShortner.Schema.ShortnedUrl
  alias UrlShortner.Repo

  @spec create_shortned_url(map) :: {:ok, ShortnedUrl.t()} | {:error, Ecto.Changeset.t()}
  def create_shortned_url(attrs) do
    attrs
    |> ShortnedUrl.create_changeset()
    |> Repo.insert()
  end

  @spec get_shortned_url_by_id(String.t()) :: ShortnedUrl.t() | {:error, :not_found}
  def get_shortned_url_by_id(id) do
    case Repo.get(ShortnedUrl, id) do
      nil -> {:error, :not_found}
      shortned_url -> shortned_url
    end
  rescue
    Ecto.Query.CastError -> {:error, :not_found}
  end

  @doc """
  Get the original URL for a given slug. Uses caching to avoid hitting the database for every request.
  Only the original_url is cached to reduce the memory footprint of the cache.

  As a side-effect, the visits_count is incremented asynchronously to avoid blocking the request in case
  the database is slow to respond.
  """
  @spec get_original_url(String.t()) :: String.t() | nil
  def get_original_url(slug) do
    result =
      Cachex.fetch(:shortned_urls, slug, fn slug ->
        case Repo.get_by(ShortnedUrl, slug: slug) do
          nil ->
            {:ignore, nil}

          shortned_url ->
            async_incr_visits(shortned_url)
            {:commit, shortned_url.original_url}
        end
      end)

    case result do
      {:ignore, nil} -> nil
      {:ok, original_url} -> original_url
      {:commit, original_url} -> original_url
      original_url -> original_url
    end
  end

  @doc """
  Increment the visits count for a shortned URL asyncrhonously using a Task.
  """
  @spec async_incr_visits(ShortnedUrl.t()) :: {:ok, pid()}
  def async_incr_visits(shortned_url) do
    Task.Supervisor.start_child(UrlShortner.TaskSupervisor, fn ->
      __MODULE__.incr_visits!(shortned_url)
    end)
  end

  @doc """
  Increment the visits count of a shortned URL.
  Will raise an exception if the update fails.
  """
  @spec incr_visits!(ShortnedUrl.t()) :: ShortnedUrl.t()
  def incr_visits!(shortned_url) do
    Repo.transaction(fn ->
      shortned_url
      |> ShortnedUrl.changeset(%{visits_count: shortned_url.visits_count + 1})
      |> Repo.update!(returning: true)
    end)
  end
end
