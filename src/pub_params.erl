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
%%% @doc  pub_params API - 签名计算
%%% @author  qingchuwudi <'bypf2009@vip.qq.com'> 
%%% @copyright 2017 qingchuwudi <bypf2009@vip.qq.com>
%%% @end
%%% created|changed : 2017-02-07 09:21
%%% coding : utf-8 
%%% ------------------------------------------------------------------ 
-module(pub_params).
-author("qingchuwudi").

-export ([
	params/4, params/5,
	params2/5, params2/6
]).

-export ([to_uri/1]).

-include ("pub_params.hrl").

-type options() :: proplist | map.
-type params() :: proplists:proplist() | maps:map().
-type method() :: list() | binary(). % "GET" | "POST" | <<"GET">> | <<"POST">>


-define (APP, ?MODULE).
-define (HH,  1000000000000000). % 10^15
-define (DEFAULT_OPTION, map).

% 名称				类型		是否必须	描述
%%-----------------------------------------------------------------------------------
% Format			String	  否		返回值的类型，支持JSON与XML。默认为XML
% Version			String	  是		API版本号，为日期形式：YYYY-MM-DD，本版本对应为2015-01-09
% AccessKeyId		String	  是		阿里云颁发给用户的访问服务所用的密钥ID
% Signature			String	  是		签名结果串，关于签名的计算方法，请参见 签名机制。
% SignatureMethod	String	  是		签名方式，目前支持HMAC-SHA1
% Timestamp			String	  是		请求的时间戳。日期格式按照ISO8601标准表示，并需要使用UTC时间。格式为YYYY-MM-DDThh:mm:ssZ 例如，2015-01-09T12:00:00Z（为UTC时间2015年1月9日12点0分0秒）
% SignatureVersion	String	  是		签名算法版本，目前版本是1.0
% SignatureNonce	String	  是		唯一随机数，用于防止网络重放攻击。用户在不同请求间要使用不同的随机数值

%%@doc 公共参数使用默认值，同时http请求带有其它参数，返回值格式默认
-spec params(AccessKeyId, AccessKeySecret, Method, ParamsExtra) -> PublicParams when
		AccessKeyId :: string(),
		AccessKeySecret :: string(),
		Method :: method(),
		ParamsExtra :: params(),
		PublicParams :: params().
params(AccessKeyId, AccessKeySecret, Method, ParamsExtra) ->
	true = method_check(Method),
	params(AccessKeyId, AccessKeySecret, Method, ParamsExtra, ?DEFAULT_OPTION).

%%@doc 公共参数使用默认值，同时http请求带有其它参数
-spec params(AccessKeyId, AccessKeySecret, Method, ParamsExtra, Opt) -> PublicParams when
		AccessKeyId :: string(),
		AccessKeySecret :: string(),
		Method :: method(),
		ParamsExtra :: params(),
		Opt :: options(),
		PublicParams :: params() .
params(AccessKeyId, AccessKeySecret, Method, ParamsExtra, Opt) ->
	{ok, Vals} = application:get_env(?APP, params),
	true = public_params_check(Vals),
	Timestamp = etime:local2utc(),
	Nonce1 = uuid:get_v4(),
	SignatureNonce = uuid:uuid_to_string(Nonce1),

	ParamsPub = Vals#{
		?AccessKeyId => AccessKeyId,
		?Timestamp => Timestamp,
		?SignatureNonce => SignatureNonce
	},
	ParamsPub1 = to_utf8_bin(ParamsPub),
	Signature = sign(AccessKeySecret, Method, ParamsExtra, ParamsPub1),
	ParamsPub2 = ParamsPub1#{ ?Signature => Signature },
	params_return(ParamsPub2, Opt).


%%@doc 所有参数自定义，返回值格式默认
params2(AccessKeyId, AccessKeySecret, Method, ParamsExtra, ParamsPub) ->
	true = public_params_check(ParamsPub),
	true = method_check(Method),
	params2(AccessKeyId, AccessKeySecret, Method, ParamsExtra, ParamsPub, ?DEFAULT_OPTION).

%%@doc 所有参数自定义
-spec params2(AccessKeyId, AccessKeySecret, Method, ParamsExtra, ParamsPub, Opt) -> PublicParams when
		AccessKeyId :: list(), 
		AccessKeySecret :: list(), 
		Method :: method(),
		ParamsExtra :: params(), 
		ParamsPub :: params(),
		Opt :: options(),
		PublicParams :: params().
params2(AccessKeyId, AccessKeySecret, Method, ParamsExtra, ParamsPub, Opt) ->
	ParamsPub1 = if
		is_map(ParamsPub) ->
			to_utf8_bin(ParamsPub#{?AccessKeyId => AccessKeyId});
		is_list(ParamsPub) ->
			to_utf8_bin([{?AccessKeyId, AccessKeyId}| ParamsPub])
	end,
	Signature = sign(AccessKeySecret, Method, ParamsExtra, ParamsPub1),
	ParamsPub2 = ParamsPub1#{ ?Signature => Signature },
	params_return(ParamsPub2, Opt).

%%%
%%% return proplists:proplist() / maps:map()
%%%

params_return(ParamsPub, map) ->
	ParamsPub;
params_return(ParamsPub, proplist) ->
	maps:to_list(ParamsPub).

%%%
%%% check paramiters
%%%

%%@private check public paramiters
public_params_check(#{?Format := _, 
					  ?Version := _, 
					  ?SignatureMethod := _, 
					  ?SignatureVersion := _ 
					}) ->
	true;
public_params_check(#{?Format := _,
					  ?Version := _, 
					  ?AccessKeyId := _, 
					  ?SignatureMethod := _, 
					  ?Timestamp := _, 
					  ?SignatureVersion := _, 
					  ?SignatureNonce := _
				}) ->
	true;
public_params_check(_) ->
	false.

method_check("GET") -> true;
method_check("POST") -> true;
method_check(<<"GET">>) -> true;
method_check(<<"POST">>) -> true;
method_check(_) -> false.

%%% 
%%% Calc. SignatureNonce
%%%

sign(AccessKeySecret, Method, ParamsExtra, Params) when is_map(ParamsExtra) ->
	StringToSign1 = maps:merge(ParamsExtra, Params),
	StringToSign2 = to_uri(StringToSign1),
	StringToSign3 = binary_to_list(StringToSign2),
	StringToSign4 = http_uri:encode(StringToSign3),
	StringToSign5 = binary:list_to_bin([Method, <<"&">>, <<"%2F">>, <<"&">>, StringToSign4]),
	Key = binary:list_to_bin([AccessKeySecret, <<"&">>]),
	Signature1 = crypto:hmac(sha, Key, StringToSign5),
	base64:encode(Signature1);

sign(AccessKeySecret, Method, ParamsExtra, Params) when is_list(ParamsExtra) ->
	ParamsExtra1 = maps:from_list(ParamsExtra),
	sign(AccessKeySecret, Method, ParamsExtra1, Params).

%%% 
%%% ParamsExtra : encode to utf8
%%%

%%@doc map/list 格式的http参数表转换为 uri
-spec to_uri(Params) -> URI when
		Params :: params(),
		URI :: string().
to_uri(Params) when is_map(Params) ->
	UriList = lists:sort([encode1(K,V) ||{K,V}<-maps:to_list(Params)]),
	list2uri(UriList);
to_uri(Params) when is_list(Params) ->
	UriList = lists:sort([encode1(K,V) ||{K,V}<-Params]),
	list2uri(UriList).


-spec to_utf8_bin(Params) -> ParamsRes when
		Params :: params(),
		ParamsRes :: params().
to_utf8_bin(Params) when is_map(Params) ->
	maps:from_list([encode3(K,V) ||{K,V}<-maps:to_list(Params)]);
to_utf8_bin(Params) when is_list(Params) ->
	lists:sort([encode3(K,V) ||{K,V}<-Params]).

encode1(K, V) ->
	{http_uri:encode(binary_to_list(
		unicode:characters_to_binary(K)
		)), 
	 http_uri:encode(binary_to_list(
		unicode:characters_to_binary(V)
	))}.

encode3(K, V) ->
	{unicode:characters_to_binary(K), 
	 unicode:characters_to_binary(V)}.

%%%
%%% proplist to uri struct
%%%

list2uri([]) ->
	"";
list2uri(List) when is_list(List) ->
	List2 = lists:reverse(List),
	list2uri(List2, []);
list2uri(Map) when is_map(Map) ->
	list2uri(maps:to_list(Map)).

list2uri([{Key, Val} | []], Url) ->
	list2uri([], [Key, <<"=">> , Val | Url]);
list2uri([{Key, Val} | Rest], Url) ->
	list2uri(Rest, [<<"&">>, Key, <<"=">> , Val | Url]);
list2uri([], Url) ->
	binary:list_to_bin(Url).