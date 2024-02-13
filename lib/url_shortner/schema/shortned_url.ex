defmodule UrlShortner.Schema.ShortnedUrl do
  use Ecto.Schema
  import Ecto.Changeset

  alias UrlShortner.Schema.ShortnedUrl
  alias UrlShortner.Slug

  defguard is_blank(value) when is_nil(value) or value == ""

  @primary_key {:id, :binary_id, autogenerate: true}

  @original_url_max_length 2048

  @type t :: %__MODULE__{
          id: String.t(),
          original_url: String.t(),
          slug: String.t(),
          visits_count: integer(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @derive {
    Flop.Schema,
    filterable: [],
    sortable: [:inserted_at],
    default_order: %{
      order_by: [:inserted_at],
      order_directions: [:desc]
    },
    default_pagination_type: :first,
    pagination_types: [:first, :last],
    default_limit: 20,
    max_limit: 100
  }

  schema "shortned_urls" do
    field :original_url, :string
    field :slug, :string
    field :visits_count, :integer, default: 0

    timestamps(type: :utc_datetime)
  end

  @doc false
  def create_changeset(attrs) do
    %ShortnedUrl{}
    |> cast(attrs, [:original_url])
    |> validate_required([:original_url])
    |> validate_length(:original_url, max: @original_url_max_length)
    |> validate_url()
    |> insert_slug()
    |> unique_constraint(:slug)
  end

  def changeset(%ShortnedUrl{} = shortned_url, attrs) do
    shortned_url
    |> cast(attrs, [:visits_count])
  end

  defp validate_url(%{valid?: false} = changeset), do: changeset

  defp validate_url(changeset) do
    case URI.new(changeset.changes[:original_url]) do
      {:ok, uri} -> inspect_uri(changeset, uri)
      {:error, _} -> add_error(changeset, :original_url, "is not a valid URL")
    end
  end

  @doc """
  The function to be used to generate the cursor value for a given ShortnedUrl.
  Must return a map with the cursor fields as keys and their values as values.
  The cursor fields must be sortable.
  """
  @spec cursor_value_func(ShortnedUrl.t(), [atom()]) :: map()
  def cursor_value_func(shortned_url, _fields) do
    %{inserted_at: DateTime.to_string(shortned_url.inserted_at)}
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
