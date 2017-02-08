%%% ------------------------------------------------------------------ 
%%% Licensed under the Apache License, Version 2.0 (the 'License');
%%%  you may not use this file except in compliance with the License.
%%%  You may obtain a copy of the License at
%%%
%%%      http://www.apache.org/licenses/LICENSE-2.0
%%%
%%% Copyright (c) 2017 qingchuwudi <bypf2009@vip.qq.com>
%%%
%%%  Unless required by applicable law or agreed to in writing, software
%%%  distributed under the License is distributed on an 'AS IS' BASIS,
%%%  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%%%  See the License for the specific language governing permissions and
%%%  limitations under the License.
%%%
%%% @doc  
%%% @author  qingchuwudi <'bypf2009@vip.qq.com'> 
%%% @copyright 2017 qingchuwudi <bypf2009@vip.qq.com>
%%% @end
%%% created|changed : 2017-02-08 10:10
%%% coding : utf-8 
%%% ------------------------------------------------------------------ 
-module(aliyun_tests).

-include ("pub_params.hrl").
-include_lib("eunit/include/eunit.hrl").

-define (ALI_PARAMS_MAP, #{
    <<"AccessKeyId">> => <<"testid">>,
    <<"Format">> => <<"XML">>,
    <<"Signature">> => <<"r8UdtNfb0tyl3efN6W/8OVpWiVE=">>,
    <<"SignatureMethod">> => <<"HMAC-SHA1">>,
    <<"SignatureNonce">> => <<"f59ed6a9-83fc-473b-9cc6-99c95df3856e">>,
    <<"SignatureVersion">> => <<"1.0">>,
    <<"Timestamp">> => <<"2016-03-24T16:41:54Z">>,
    <<"Version">> => <<"2015-01-09">>
}).
-define (ALI_PARAMS_LIST, [
    {<<"AccessKeyId">>,<<"testid">>},
    {<<"Format">>,<<"XML">>},
    {<<"Signature">>,<<"r8UdtNfb0tyl3efN6W/8OVpWiVE=">>},
    {<<"SignatureMethod">>,<<"HMAC-SHA1">>},
    {<<"SignatureNonce">>, <<"f59ed6a9-83fc-473b-9cc6-99c95df3856e">>},
    {<<"SignatureVersion">>,<<"1.0">>},
    {<<"Timestamp">>,<<"2016-03-24T16:41:54Z">>},
    {<<"Version">>,<<"2015-01-09">>}
]).


aliyun_test_() ->
    {setup,
        fun() ->
            {ok, _} = application:ensure_all_started(pub_params),
            test1()
        end,
        fun(_State) ->
            application:stop(pub_params)
        end,
        fun aliyun_test/1}.

aliyun_test(_State) ->
    [
        ?_assertEqual(?ALI_PARAMS_MAP, test2()),
        ?_assertEqual(?ALI_PARAMS_LIST, test3())
    ].

test1() ->
    AccessKeyId = "testid",
    AccessKeySecret = "testsecret",
    ParamsExtra = [{"Action", "DescribeDomainRecords"},{"DomainName", "example.com"}],
    #{} = pub_params:params(AccessKeyId, AccessKeySecret, ParamsExtra).

test2() ->
    AccessKeyId = <<"testid">>,
    AccessKeySecret = <<"testsecret">>,
    ParamsExtra = [{"Action", "DescribeDomainRecords"},{"DomainName", "example.com"}],
    ParamsPub = #{
        ?Format => <<"XML">>,
        ?Version => <<"2015-01-09">>,
        ?SignatureMethod => <<"HMAC-SHA1">>,
        ?SignatureVersion => <<"1.0">>,
        ?Timestamp => <<"2016-03-24T16:41:54Z">>,
        ?SignatureNonce => <<"f59ed6a9-83fc-473b-9cc6-99c95df3856e">>
    },
    pub_params:params2(AccessKeyId, AccessKeySecret, ParamsExtra, ParamsPub).

test3() ->
    AccessKeyId = <<"testid">>,
    AccessKeySecret = <<"testsecret">>,
    ParamsExtra = [{"Action", "DescribeDomainRecords"},{"DomainName", "example.com"}],
    ParamsPub = #{
        ?Format => <<"XML">>,
        ?Version => <<"2015-01-09">>,
        ?SignatureMethod => <<"HMAC-SHA1">>,
        ?SignatureVersion => <<"1.0">>,
        ?Timestamp => <<"2016-03-24T16:41:54Z">>,
        ?SignatureNonce => <<"f59ed6a9-83fc-473b-9cc6-99c95df3856e">>
    },
    pub_params:params2(AccessKeyId, AccessKeySecret, ParamsExtra, ParamsPub, proplist).