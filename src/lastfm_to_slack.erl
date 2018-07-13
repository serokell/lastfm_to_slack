-module(lastfm_to_slack).
-export([start/2, stop/1]).

-behaviour(application).

start(_Type, _Args) ->
    lastfm_to_slack_sup:start_link().

stop(_State) ->
    ok.
