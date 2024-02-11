defmodule UrlShortner.Schema.ShortnedUrl do
  use Ecto.Schema
  import Ecto.Changeset

  alias UrlShortner.Schema.ShortnedUrl
  alias UrlShortner.Slug

  defguard is_blank(value) when is_nil(value) or value == ""

  @primary_key {:id, :binary_id, autogenerate: true}

  @type t :: %__MODULE__{
          id: String.t(),
          original_url: String.t(),
          slug: String.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  schema "shortned_urls" do
    field :original_url, :string
    field :slug, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def create_changeset(attrs) do
    %ShortnedUrl{}
    |> cast(attrs, [:original_url])
    |> validate_required([:original_url])
    |> validate_url()
    |> insert_slug()
    |> unique_constraint(:slug)
  end

  defp validate_url(%{valid?: false} = changeset), do: changeset

  defp validate_url(changeset) do
    case URI.new(changeset.changes[:original_url]) do
      {:ok, uri} -> inspect_uri(changeset, uri)
      {:error, _} -> add_error(changeset, :original_url, "is not a valid URL")
    end
  end

  defp inspect_uri(changeset, %URI{scheme: "http", host: host}) when not is_blank(host),
    do: changeset

  defp inspect_uri(changeset, %URI{scheme: "https", host: host}) when not is_blank(host),
    do: changeset

  defp inspect_uri(changeset, _uri) do
    add_error(changeset, :original_url, "is not a valid URL")
  end

  defp insert_slug(%{valid?: false} = changeset), do: changeset

  defp insert_slug(changeset) do
    put_change(changeset, :slug, Slug.generate())
  end
end
