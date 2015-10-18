-module(sshrpc_util).

-include_lib("sshrpc.hrl").
-include_lib("common.hrl").

-export([mk_opts/1, otp_release/0]).

-spec mk_opts(atom()) -> [{atom(), term()}].
mk_opts(listen) ->
    mk_opts("server");
mk_opts(connect) ->
    mk_opts("client");
mk_opts(Role) when is_atom(Role) ->
    Dir = filename:join([code:lib_dir(?APP), "examples", "certs", "etc"]),
    [{active, false}, 
     {verify, 2},
     {depth, 2},
     {cacertfile, filename:join([Dir, Role, "cacerts.pem"])}, 
     {certfile, filename:join([Dir, Role, "cert.pem"])}, 
     {keyfile, filename:join([Dir, Role, "key.pem"])}];
mk_opts(_) -> exit(badssh_role).

-spec otp_release() -> integer().
otp_release() ->
    try
        erlang:list_to_integer(erlang:system_info(otp_release))
    catch
        error:badarg ->
            %% Before Erlang 17, R was included in the OTP release,
            %% which would make the list_to_integer call fail.
            %% Since we only use this function to test the availability
            %% of the show_econnreset feature, 16 is good enough.
            16
    end.




