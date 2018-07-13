-module(lastfm_to_slack_job).
-export([handle_info/2, init/1, start_link/0]).

start_link() ->
    gen_server:start_link(?MODULE, [], []).

init([]) ->
    {ok, erlang:send_after(1, self(), poll)}.

handle_info(poll, Prev) ->
    erlang:cancel_timer(Prev),
    update(),
    {ok, Interval} = application:get_env(lastfm_to_slack, polling_interval_ms),
    {noreply, erlang:send_after(Interval, self(), poll)};
handle_info(_, State) ->
    {noreply, State}.

update() ->
    {ok, Users} = application:get_env(lastfm_to_slack, lastfm_users_to_slack_tokens),
    update(Users).

update([{User, Token} | Rest]) ->
    {ok, Emoji} = application:get_env(lastfm_to_slack, slack_status_emoji),
    Track = lastfm_to_slack_lastfm:most_recent_track(User),
    case lastfm_to_slack_lastfm:is_playing_now(Track) of
        true ->
            lastfm_to_slack_slack:update_status(Token, lastfm_to_slack_lastfm:track_title(Track), Emoji);
        false ->
            lastfm_to_slack_slack:update_status(Token)
    end,
    update(Rest);
update([]) ->
    ok.
