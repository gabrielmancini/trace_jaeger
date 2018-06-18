%%%-------------------------------------------------------------------
%% @doc my_otter public API
%% @end
%%%-------------------------------------------------------------------

-module(my_otter_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    Routes = [ {
        '_',
        [
            {"/", my_otter_root, []}
        ]
    } ],
    Dispatch = cowboy_router:compile(Routes),

    NumAcceptors = 10,
    TransOpts = [ {ip, {0,0,0,0}}, {port, 2938} ],
    ProtoOpts = [{env, [{dispatch, Dispatch}]}],

    {ok, _} = cowboy:start_http(chicken_poo_poo,
        NumAcceptors, TransOpts, ProtoOpts),

    my_otter_sup:start_link().
  
%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
