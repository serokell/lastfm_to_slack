-module(lastfm_to_slack_slack).
-export([update_status/1, update_status/3]).

update_status(Token) ->
    update_status(Token, <<>>, <<>>).

update_status(Token, Text, Emoji) ->
    {ok, ConnPid} = gun:open("slack.com", 443),
    StreamRef = gun:post(ConnPid, [<<"/api/users.profile.set?">>, cow_qs:qs([
        {<<"profile">>, jsone:encode(#{<<"status_text">> => Text, <<"status_emoji">> => Emoji})},
        {<<"token">>, Token}
    ])], []),
    gun:await_body(ConnPid, StreamRef).
