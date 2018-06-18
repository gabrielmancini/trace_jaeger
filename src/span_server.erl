-module(span_server).

-behaviour(gen_server).

%% API
-export([
         start_link/0,
         span/1
        ]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

log({trace_ts, Pid, Kind, {Module, Function, _Args}, _Bytes, _}) ->
    log({trace_ts, Pid, Kind, {Module, Function, _Args}, _Bytes});
log({trace_ts, Pid, Kind, {Module, Function, _Args}, _}) ->
    io:format("~n Kind: ~p~n", [Kind]),
    io:format("Module: ~p~n", [Module]),
    io:format("Function: ~p~n", [Function]),
    % io:format("Args: ~p~n", [Args]),
    io:format("Pid: ~p~n", [Pid]).

span(Msg) ->
  log(Msg),
  gen_server:cast(?SERVER, Msg).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
    {ok, []}.

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast({trace_ts, Pid, _Kind, {Module, Function, _Args}, _}, State) ->
    Key = get_key(Pid, Module, Function),
    Value = case State of
                [] -> [otter:start(Key)];
                [Span|Tail] -> [otter:start(Key, Span),Span|Tail]
            end,
    {noreply, Value};
handle_cast({trace_ts, _Pid, _Kind, {_Module, _Function, _Args}, _, _}, State) ->
    Value = case State of
                [] -> [];
                [Span|Tail] -> 
                    otter:finish(Span),
                    Tail
            end,
    {noreply, Value};
handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
%%%

get_key(Pid, Module, Function) ->
    Title = pid_to_list(Pid) ++ " - " ++ atom_to_list(Module),
    Title ++ " - " ++ atom_to_list(Function).
