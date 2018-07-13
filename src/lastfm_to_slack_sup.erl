-module(lastfm_to_slack_sup).
-export([start_link/0, init/1]).

-behaviour(supervisor).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    Flags = #{strategy => one_for_all, intensity => 5, period => 5},
    Specs = [#{id => lastfm_to_slack_job,
	       start => {lastfm_to_slack_job, start_link, []}}],
    {ok, {Flags, Specs}}.
