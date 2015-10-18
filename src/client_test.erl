%% Copyright (c) 2009-2010 Kenji Rikitake. All Rights Reserved.
%%
%% The contents of this file are subject to the Erlang Public License,
%% Version 1.1, (the "License"); you may not use this file except in
%% compliance with the License. You should have received a copy of the
%% Erlang Public License along with this software. If not, it can be
%% retrieved online at http://www.erlang.org/.
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and limitations
%% under the License.

%% @author Kenji Rikitake <kenji.rikitake@acm.org>
%% @copyright 2009-2010 Kenji Rikitake

%% @doc example code for testing SSH RPC client site
%% TODO: this code must be OTP-nized!

-module(client_test).
-export([startup/0, linkup/0, test/2, test/0]).

-export([start/0, start/1]).

-include("sshrpc.hrl").
-include("common.hrl").

-define(TIMEOUT, 30000). % in milliseconds

%% specifyclient configuration key directory
%% (put id_rsa and id_rsa.pub)

%-define(CLIENT_CONFIG, "/your/client_config").

-spec startup() -> ok.

startup() ->
    ok = crypto:start(),
    ok = ssh:start().

%%--------------------------------------------------------------------
-spec start() -> ok | {error, term()}.
-spec start(permanent | transient | temporary) -> ok | {error, term()}.
%%
%% Description: Starts the ssh application. Default type
%% is temporary. see application(3)
%%--------------------------------------------------------------------
start() ->
    application:start(crypto),
    application:start(asn1),
    application:start(public_key),
    application:start(ssh),
    ssh:start().

start(Type) ->
    application:start(crypto, Type),
    application:start(asn1),
    application:start(public_key, Type),
    application:start(ssh, Type),
    ssh:start().

-spec linkup() -> {pid(), term()}.

linkup() ->
    %Opts = sshrpc_util:mk_opts('connect'),
%sshrpc_client:start_channel("127.0.0.1", 11122,[{user_dir, "/root/.ssh"},{user_interaction, false}, {silently_accept_hosts, true},{nodelay, true},{ssh_msg_debug_fun,fun(_,true,M,_)-> io:format("DEBUG: ~p~n", [M]) end}]).

    {ok, Pid, Cm} = sshrpc_client:start_channel("127.0.0.1", % server address
		     11122, % port number
		     [
		      %% note: private user key (id_rsa) and
		      %% public host key (known_hosts) must exist
		      %% in the "user_dir" for public-key auth
		      %% NOTE WELL: user key has NULL password protected
		      %%            (password-protected is UNSUPPORTED)
		      {user_dir, ?CLIENT_CONFIG},
		      {user_interaction, false},
		      {silently_accept_hosts, true},
		      {subsystems,[sshrpc_subsystem:subsystem_spec([])]},
		      %% the following user/password pair needed for
		      %% plain password-based authentication
		      %% {user,"test"}
		      %% {password,"shiken"}
		      %%
		      %% nodelay must be set true for immediate response!
		      {nodelay, true},
 		      {ssh_msg_debug_fun, 
		      	   fun(_,true,M,_)-> io:format("DEBUG: ~p~n", [M]) end}

		     ]),
    io:format("Pid: ~p Cm: ~p ~n", [Pid, Cm]),
    {Pid, Cm}.

-spec test(non_neg_integer(), non_neg_integer()) -> ok.

test(M,N) ->
    {Pid, _Cm} = linkup(),
    Status = lists:map(
	       fun(X) ->
		       Reply = sshrpc_client:sync_call(Pid, lists, seq, [1, M]),
		       io:format("NR: ~p Time: ~p~n", [X, erlang:timestamp()]),
		       io:format("Reply: ~p~n", [Reply])
	       end,
	       lists:seq(1,N)),
    io:format("Time: ~p Status: ~p~n", [erlang:timestamp(),Status]),
    sshrpc_client:stop_channel(Pid).

-spec test() -> ok.

test() ->
    start(),
    linkup(),
    test(1,1).


%% end of file
