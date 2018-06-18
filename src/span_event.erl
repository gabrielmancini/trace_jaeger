-module(span_event).

-behaviour(gen_event).

-export([code_change/3, handle_call/2, handle_event/2,
         handle_info/2, init/1, start_link/0, terminate/2]).

start_link() ->
  {ok, Pid} = gen_event:start_link({local, ?MODULE}),
  io:format("Start Link ~n"),
  %% The scoreboard will always be there
  gen_event:add_sup_handler(?MODULE, ?MODULE, [Pid]),
  {ok, Pid}.

notify() ->
  io:format("notify ~n"),
  gen_event:notify(?MODULE, {whatisthat}).


% gen_event callbacks
%
init(Pid) ->
  io:format("init gen_event ~p~n", [Pid]),
  Match = [{'_', [], [{return_trace}]}],
  % trace all calls to all functions in Modules
  Modules = [cowboy, cowboy_req, cowboy_router, cowboy_constraints, cowboy_http, cowboy_http2, cowboy_websocket, cowboy_static, cowboy_handler, cowboy_loop, cowboy_middleware, cowboy_rest, cowboy_stream, cowboy_websocket, cowboy_router, cowboy_handler],
  lists:foreach(fun(M) -> erlang:trace_pattern({M, '_', '_'}, Match, [local]) end, Modules),
  % erlang:trace(all, true, [call, timestamp, {tracer, ?MODULE, notify}]),
  % erlang:trace(all, false, [call, timestamp, {tracer, ?MODULE, notify}]),
  erlang:trace(all, true, [call, timestamp, {tracer, Pid}]),
  {ok, Pid}.

handle_event(Event, Count) ->
    io:format("** handle_event got event ~p~n", [Event]),
    {ok, Count}.

handle_call(Request, Count) ->
    io:format("** got request ~p~n", [Request]),
    {ok, Count, Count}.

code_change(_OldVsn, State, _Extra) -> {ok, State}.

handle_info(Info, State) ->
  io:format("** handle_info got request ~p~n", [Info]),
  {noreply, State}.

terminate(_Args, _State) -> ok.
