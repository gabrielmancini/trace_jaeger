-module(span).

-export([start/1, process/2]).

process(Request, Index) ->
  %
  Span = otter:start("radius request " ++ Index),
  timer:sleep(1000),
  io:format("start: ~p~n~n", [Span]),

  Span1 = otter:start("subspan", Span),
  timer:sleep(1000),

  otter:finish(Span1),
  otter:finish(Span).
  % % Create a valid EJson structure to encode
  % Headers = cowboy_req:headers(Request),
  % EJsonHeaders = lists:map(fun({K,V}) -> {[{K, V}]} end, Headers),

  % Json = jiffy:encode({[{<<"header">>, EJsonHeaders}]}),
  % Span1 = otter:tag(Span, "Method", Json),
  % timer:sleep(1000),
  % io:format("start: ~p~n~n", [Span1]),
  % %
  %
  % Span2 = otter:start("radius request " ++ Index, Span1),
  % timer:sleep(1000),
  % io:format("start: ~p~n~n", [Span2]),
  % %
  % %
  % Span3 = otter:log(Span2, "user db result"),
  % timer:sleep(1000),
  % io:format("start: ~p~n~n", [Span3]),
  % Span4 = otter:tag(Span3, "user db result", "ok"),
  % % Span4 = otter:start("user db result", Span),
  % timer:sleep(1000),
  % io:format("start: ~p~n~n", [Span4]),
  % %
  % %
  % Span5 = otter:tag(Span4, "final result", "error"),
  % timer:sleep(1000),
  % io:format("start: ~p~n~n", [Span5]),
  % Span6 = otter:tag(Span5, "final result reason", "unknown user"),
  % timer:sleep(1000),
  % io:format("start: ~p~n~n", [Span6]),
  %
  % otter:finish(Span6).

current(Pid, {K, V}, State) ->
  Tail = case maps:find(Pid, State) of
    {ok, Finded} ->
      Finded;
    _ ->
      {}
  end,
  maps:put(Pid, [{K, V} | Tail], State).

log(Module, Function, Args, Kind, Pid, State) ->
  io:format("Module: ~p~n", [Module]),
  io:format("Function: ~p~n", [Function]),
  % io:format("Args: ~p~n", [Args]),
  io:format("Kind: ~p~n", [Kind]),
  io:format("Pid: ~p~n", [Pid]),
  io:format("State: ~p~n", [State]),

  % case Kind of
  %   call ->
      Span = otter:start(Module),
      Span1 = otter:tag(Span, Kind, Function),
    % return_from ->
      otter:finish(Span1),
  % end.
  %
  % Span2 = otter:log(Span1, Args),
  %
  % Head = {Function, otter:finish(Span1)},
  Head = {Kind, Function},
  current(Pid, Head,  State).

start(State) ->
  F = fun(F, State) ->
    receive
      stop ->
        io:format("stop ~p~n", [State]),
        ok;
      Msg ->
        Return = case Msg of
          {trace_ts, Pid, Kind, {Module, Function, Args}, _} ->
            log(Module, Function, Args, Kind, Pid, State);
          {trace_ts, Pid, Kind, {Module, Function, Args}, _, _} ->
            log(Module, Function, Args, Kind, Pid, State);
          _ ->
            % io:format("NO PATTERN ON ~p~n", [Msg]),
            State
        end,
        io:format("Return ~p~n", [Return]),
        F(F, Return)
    end
  end,

  Tracer = proc_lib:spawn(fun() -> F(F, State) end),
  %% trace everything

  Match = [{'_', [], [{return_trace}]}],
  %% trace all calls to all functions in Modules
  Modules = [cowboy, cowboy_req, cowboy_router, cowboy_constraints, cowboy_http, cowboy_http2, cowboy_websocket, cowboy_static, cowboy_handler, cowboy_loop, cowboy_middleware, cowboy_rest, cowboy_stream, cowboy_websocket, cowboy_router, cowboy_handler],
  lists:foreach(fun(M) -> erlang:trace_pattern({M, '_', '_'}, Match, [local]) end, Modules),
  erlang:trace(all, true, [call, timestamp, {tracer, Tracer}]),
  {ok, self()}.
