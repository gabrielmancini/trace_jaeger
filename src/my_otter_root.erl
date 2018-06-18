-module(my_otter_root).

-export([init/2]).

init(Req, Opts) ->
    Req2 = cowboy_req:reply(200,
        [{<<"content-type">>, <<"text/plain">>}],
        <<"Hello Otter">>,
        Req),
    % span:process(Req, "1"),
    % span:process(Req, "2"),
    % span:process(Req, "3"),
    {ok, Req2, Opts}.
