ifneq (,$(wildcard ./.env))
    include .env
    export
endif

.PHONY: console setup-db server test

console:
	iex -S mix

setup-db:
	mix ecto.setup

server: setup-db
	iex -S mix phx.server

test:
	mix test
