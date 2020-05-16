%% signal event handler.
%% Replacement for default `erl_signal_handler`.

-module(drano_signal_handler).
-behaviour(gen_event).

-include_lib("kernel/include/logger.hrl").

-export([init/1, handle_event/2, handle_info/2, handle_call/2, setup/1, terminate/2, code_change/3]).

%% Arguments:
%% ShutdownDelay - delay (in ms) before stopping the VM after `sigterm`.
%% Callback - callback handler to invoke when a `sigterm` is received

setup([{shutdown_delay, Delay}, {callback, Callback}]) ->
    ok = gen_event:swap_sup_handler(
        erl_signal_server,
        {erl_signal_handler, []},
        {drano_signal_handler,
        [Delay, Callback]}
    ),
    ok.

init({[Delay, Callback], _}) ->
    {ok, {Delay, Callback}}.

handle_event(sigusr1, S) ->
    erlang:halt("Received SIGUSR1"),
    {ok, S};
handle_event(sigquit, S) ->
    erlang:halt(),
    {ok, S};
handle_event({sigterm, test}, {_Delay, {M,F,A}} = State) ->
    logger:info("Test: SIGTERM received", []),
    erlang:apply(M,F,A),
    {ok, State};
handle_event(sigterm, {Delay, {M,F,A}} = State) ->
    logger:info("SIGTERM received. Draining and then stopping in ~p ms", [Delay]),
    erlang:apply(M,F,A),
    erlang:send_after(Delay, self(), stop),
    {ok, State};
handle_event(_SignalMsg, S) ->
    {ok, S}.

handle_info(stop, State) ->
    logger:error("SIGTERM received - shutting down", []),
    ok = init:stop(),
    {ok, State};
handle_info(_, State) ->
    {ok, State}.

handle_call(_Request, State) ->
    {ok, ok, State}.

code_change(_OldVsn, S, _Extra) ->
    {ok, S}.

terminate(_Args, _State) ->
    ok.
