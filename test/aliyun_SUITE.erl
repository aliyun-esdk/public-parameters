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
%%% created|changed : 2017-02-08 09:05
%%% coding : utf-8 
%%% ------------------------------------------------------------------ 
-module(aliyun_SUITE).
-author("qingchuwudi").

-export ([all/0, test/1]).

-include ("pub_params.hrl").

all() ->
	[test].

test(_) ->
	AccessKeyId = "testid",
	AccessKeySecret = "testsecret",
	ParamsExtra = [{"Action", "DescribeDomainRecords"},{"DomainName", "example.com"}],
	ParamsPub = #{
	    ?Format => <<"XML">>,
	    ?Version => <<"2015-01-09">>,
	    ?SignatureMethod => <<"HMAC-SHA1">>,
	    ?SignatureVersion => <<"1.0">>,
	    ?Timestamp => <<"2016-03-24T16:41:54Z">>,
	    ?SignatureNonce => <<"f59ed6a9-83fc-473b-9cc6-99c95df3856e">>
	},
  	PublicParamters = pub_params:params2(AccessKeyId, AccessKeySecret, ParamsExtra, ParamsPub),
  	ct:print("PublicParamters ~p~nend", [PublicParamters]).