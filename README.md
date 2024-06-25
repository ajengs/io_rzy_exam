# Razoyo Full stack developer exam

## How to run the application

You will need the following installed:

  * Elixir
  * Postgres

### To start your Phoenix server

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

> NOTE: 
> `mix setup` will create **new account** on Banking API and seed the data **based on the newly created account**.
> `mix run priv/repo/seeds.exs` will always reset the data and seed it with **newly created account**.

## How to test
  * Run `mix test --trace`

## Assumptions
  * Secret word should be valid word. This will be validated through [Words API](https://www.wordsapi.com/). If word is invalid, we will not send `Authorize` request to Banking API. This is to reduce failure attempt on authorization request and reduce possibility of account being frozen.
  * Maximum failure attempts is 5. To avoid account being frozen, user cannot try to authorize when they already failed 4 times. 
  * Failure attempts will be reset 1 hour after last attempt. After 1 hour (configurable), user can try to authorize again.  
  * Accounts that are already authorized cannot be authorized again.
  * Accounts that are already transferred cannot be transferred or authorized again.

## Learn more

  * Requirements: https://exam.razoyo.com/fullstack
  * Banking API: [API Reference](https://editor.swagger.io/?url=https%3A%2F%2Fstorage.googleapis.com%2Frazoyo-exam-spec%2Fbanking.yaml%3Fv%3D22.05.06)
  