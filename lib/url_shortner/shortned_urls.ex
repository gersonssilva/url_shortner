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
end
