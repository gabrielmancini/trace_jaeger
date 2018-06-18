%%%-------------------------------------------------------------------
%% @doc my_otter top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(my_otter_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    {ok, { {one_for_all, 0, 1}, [
       {span_probe, {span_probe, start_link, []}, permanent, infinity, worker, [span_probe]},
       % {span, {span, start, [maps:new()]}, permanent, infinity, worker, [span]},
       {span_server, {span_server, start_link, []}, permanent, infinity, worker, [span_server]}
       % {span_event, {span_event, start_link, []}, permanent, infinity, worker, [span_event]}
    ]} }.

%%====================================================================
%% Internal functions
%%====================================================================
