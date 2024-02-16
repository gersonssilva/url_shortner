# UrlShortner

URL shortener application, in the same vein as [bitly](https://bitly.com/) and [tinyurl](https://tinyurl.com/app).

## Setup

### Installing Elixir

It's recommended to use [asdf](https://asdf-vm.com/guide/getting-started.html) to manage the Erlang/Elixir versions installed in
your system. Please follow [these instructions](https://www.pluralsight.com/guides/installing-elixir-erlang-with-asdf) to install
the necessary plugins before installing Elixir.

Once you have `asdf` installed, you can install the necessary Erlang and Elixir versions by running the following commands in the project's root folder:

```bash
asdf install
```

After that, install the project's dependencies by running:

```bash
mix deps.get
```

### Configuring the application

The application uses environment variables for configuration.

**Important!** Be sure to create a `.env` file in the root of the project with the necessary variables. You can use the `.env.example` file as a template.


### Running the application via Docker

The quickest way to have the application and all of its dependencies running locally is to use the provided `docker-compose.yml` file. You can start the application by running the following command:

```bash
docker compose up -d --build
```

Then, you can access the application at `http://localhost:4000` (or the port you have configured in the `.env` file).

Note: Don't forget to name the database host to `db` in your `.env` file `DATABASE_HOST`.

### Running the application via mix

You can also run the application using `mix`. To do so, be sure to have the necessary dependencies e.g. Postgres installed locally with the correct configuration.

Then, you can start the application by running the following commands:

```bash
make server
```

**Tip:** You can use docker compose to start just the necessary dependencies (e.g. Postgres) and then run the application using `mix`:


```bash
docker compose up -d db

make server
```

Note: Don't forget to name the database host to `localhost` in your `.env` file `DATABASE_URL`.


## Design Considerations

* The application uses Phoenix as the web framework, and Postgres as the database.

* Shortened URls are generated using a random 8 bytes string encoded in URL-safe base64. This approach was chosen because it's simple and efficient, and it's unlikely to generate collisions. Also, it doesn't make
the shortened URL too big, which would defeat the purpose of shortening it.

* It is possible to have different entries for the same URL. This was a conscious decision as to simplify
the project's implementation. It would be possible to implement a check to avoid this if necessary.

* URL visit counts are stored in the database in the same table as the shortened URL. Updates to the counter
are handled asynchronously to avoid slowing down the request/response cycle, and still allow the request to be served from cache in case the DB is down.

* Cursor-based pagination was used to paginate the URLs list. This approach was chosen because it's more efficient than offset-based pagination, especially for large datasets. In my experience, it pays off to implement cursor-based pagination from the start, specially for datasets that are expected to grow.

* The stats CSV report generation is handled synchronously for simplicity. Currently, it is capable of exporting the current page, or any page via cursors. In a real-world scenario, it would be better to handle this asynchronously, as it could take a long time to generate the report for a large dataset.

* The UI was implemented using the default Phoenix standard of using EEx templates and Tailwind CSS.
