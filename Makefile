ifneq (,$(wildcard ./.env))
    include .env
    export
endif

.PHONY: console server test

console:
	iex -S mix

server:
	iex -S mix phx.server

test:
	mix test
