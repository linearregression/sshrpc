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

%% @doc example code for testing SSH RPC server site

-module(server_test).
-export([invoke/0, start/0, start/1]).

-include("common.hrl").

-define(TIMEOUT, 30000). % in milliseconds

%% specify server configuration key directory
%% (put id_rsa.pub, ssh_host_rsa_key{.pub}, and authorized_keys

%-define(SERVER_CONFIG,
%	"/your/server_config").

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
    application:start(sasl).

start(Type) ->
    application:start(crypto, Type),
    application:start(asn1),
    application:start(public_key, Type),
    application:start(ssh, Type),
    application:start(sasl, Type).

invoke() ->
    %Opts = sshrpc_util:mk_opts('listen'), 
    Pid = ssh:daemon({127,0,0,1}, % IP address
		     11122, % port number
		     [
		      %% server configuration directory
		      %% including the host keys
		      {system_dir, ?SERVER_CONFIG},
		      %% note: public user key (authorized_keys) must exist
		      %% in the following *user* directory for public-key auth
		      %% NOTE WELL: user key has NULL password protected
		      %%            (password-protected key not tested yet)
		      {user_dir, ?SERVER_CONFIG},
		      %%
		      %% for subsystem test
		      %%{subsystems,[sshrpc_subsystem:subsystem_spec([])]},
		      %%
		      %% the following user/password pair list of
		      %% user_password needed for
		      %% plain password-based authentication
                      %% {user_passwords,
		      %% [{"test","shiken"}]
		      %%
		      %% nodelay option required for faster immediate response!
		      %%
		      {auth_methods, "publickey"},
		      {nodelay, true},
 		      {ssh_msg_debug_fun, 
		      	   fun(_,true,M,_)-> io:format("DEBUG: ~p~n", [M]) end}
		     ]),
    Pid.

% end of file
