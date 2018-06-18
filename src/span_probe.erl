%%%
%%%Probe to trace wherever is pass to it
%%%

-module(span_probe).

-export([start_link/0, loop/1]).

-export([enabled/3, trace/5]).

start_link() ->
    Pid = spawn_link(?MODULE, loop, [{}]),
    Match = [{'_', [], [{return_trace}]}],
    %% trace all calls to all functions in Modules
    Modules = [cowboy, cowboy_req, cowboy_router, cowboy_constraints, cowboy_http, cowboy_http2, cowboy_websocket, cowboy_static, cowboy_handler, cowboy_loop, cowboy_middleware, cowboy_rest, cowboy_stream, cowboy_websocket, cowboy_router, cowboy_handler],
    lists:foreach(fun(M) -> erlang:trace_pattern({M, '_', '_'}, Match, [local]) end, Modules),
    erlang:trace(all, true, [call, timestamp, {tracer, Pid}]),
    % erlang:trace(all, true, [call, timestamp, {tracer, ?MODULE, Pid}]),
    {ok, Pid}.

loop(State) ->
    receive
      stop ->
        io:format("stop ~p~n", [State]),
        ok;
      Msg ->
        span_server:span(Msg),
        loop(State) 
   end.

enabled(Event, _Tracer, _Tracee) when Event =:= send;
                                     Event =:= trace_status ->
    io:format("Enable1"),
     trace;
enabled(_Event, _Tracer, _Tracee) ->
    io:format("Enable2"),
     disable.
trace(Tracer, Tracee, Msg, To, _Opts) when node(To) =:= node() ->
    io:format("trace1"),
     Tracer ! {my_trace, Tracee, Msg, To};
trace(_Tracer, _Tracee, _Msg, _To, _Opts) -> 
    io:format("Enable2"),
    ok.
