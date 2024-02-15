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

Note: Don't forget to name the database host to `db` in your `.env` file `DATABASE_URL`.

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


