# vim:set ft= ts=4 sw=4 et:

use Test::Nginx::Socket::Lua;
use Cwd qw(cwd);

repeat_each(2);

plan tests => repeat_each() * (3 * blocks());

my $pwd = cwd();

our $HttpConfig = qq{
    lua_package_path "$pwd/lib/?.lua;;";
};

$ENV{TEST_NGINX_RESOLVER} = '8.8.8.8';

no_long_string();
#no_diff();

run_tests();

__DATA__

=== TEST 1: crypto version
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local crypto = require "crypto"
            local crypto_hmac = require("crypto.hmac")
            ngx.say(crypto._VERSION)
        ';
    }
--- request
    GET /t
--- response_body_like chop
^\S+\ \d+\.\d+\.\d+$
--- no_error_log
[error]



=== TEST 2: resty.hipchat version
--- http_config eval: $::HttpConfig
--- config
    location /t {
        content_by_lua '
            local hipchat = require "resty.hipchat"
            ngx.say(hipchat._VERSION)
        ';
    }
--- request
    GET /t
--- response_body_like chop
^\d+\.\d+$
--- no_error_log
[error]
