%% specifyclient configuration key directory
%% (put id_rsa and id_rsa.pub)

-define(CLIENT_CONFIG, "/root/.ssh").

%% specify server configuration key directory
%% (put id_rsa.pub, ssh_host_rsa_key{.pub}, and authorized_keys

-define(SERVER_CONFIG,
	"/etc/ssh").

-define(APP, sshrpc).
