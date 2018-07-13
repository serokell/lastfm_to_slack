-module(lastfm_to_slack_lastfm).
-export([is_playing_now/1, most_recent_track/1, track_title/1]).

request(Params) ->
    {ok, ApiKey} = application:get_env(lastfm_to_slack, lastfm_api_key),
    {ok, ConnPid} = gun:open("ws.audioscrobbler.com", 443),
    StreamRef = gun:get(ConnPid, [<<"/2.0?">>, cow_qs:qs(Params ++ [
        {<<"api_key">>, ApiKey},
        {<<"format">>, <<"json">>}
    ])]),
    {ok, Body} = gun:await_body(ConnPid, StreamRef),
    jsone:decode(Body).

most_recent_track(User) ->
    #{<<"recenttracks">> := #{<<"track">> := [Track | _Rest]}} = request([
        {<<"limit">>, <<"1">>},
        {<<"method">>, <<"user.getrecenttracks">>},
        {<<"user">>, User}
    ]),
    Track.

is_playing_now(#{<<"@attr">> := #{<<"nowplaying">> := PlayingNow}}) ->
    PlayingNow == <<"true">>;
is_playing_now(_) ->
    false.

track_title(Track) ->
    #{<<"artist">> := #{<<"#text">> := ArtistName}, <<"name">> := TrackName} = Track,
    list_to_binary(io_lib:format(<<"~s - ~s">>, [ArtistName, TrackName])).
