ifneq (,$(wildcard ./.env))
    include .env
    export
endif

console:
	iex -S mix

server:
	iex -S mix phx.server

test:
	mix test
