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
	params/3, params/4,
	params2/4, params2/5
]).

-export ([list2url/1]).

-include ("pub_params.hrl").

-type options() :: proplist | map.
-type params() :: proplists:proplist() | maps:map().


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
-spec params(AccessKeyId, AccessKeySecret, ParamsExtra) -> PublicParams when
		AccessKeyId :: string(),
		AccessKeySecret :: string(),
		ParamsExtra :: params(),
		PublicParams :: params().
params(AccessKeyId, AccessKeySecret, ParamsExtra) ->
	params(AccessKeyId, AccessKeySecret, ParamsExtra, ?DEFAULT_OPTION).

%%@doc 公共参数使用默认值，同时http请求带有其它参数
-spec params(AccessKeyId, AccessKeySecret, ParamsExtra, Opt) -> PublicParams when
		AccessKeyId :: string(),
		AccessKeySecret :: string(),
		ParamsExtra :: params(),
		Opt :: options(),
		PublicParams :: params() .
params(AccessKeyId, AccessKeySecret, ParamsExtra, Opt) ->
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
	ParamsPub1 = maps:map(fun encode2/2, ParamsPub),
	Signature = sign(AccessKeySecret, ParamsExtra, ParamsPub1),
	ParamsPub2 = ParamsPub1#{ ?Signature => Signature },
	params_return(ParamsPub2, Opt).


%%@doc 所有参数自定义，返回值格式默认
params2(AccessKeyId, AccessKeySecret, ParamsExtra, ParamsPub) ->
	params2(AccessKeyId, AccessKeySecret, ParamsExtra, ParamsPub, ?DEFAULT_OPTION).

%%@doc 所有参数自定义
-spec params2(AccessKeyId, AccessKeySecret, ParamsExtra, ParamsPub, Opt) -> PublicParams when
		AccessKeyId :: list(), 
		AccessKeySecret :: list(), 
		ParamsExtra :: params(), 
		ParamsPub :: params(),
		Opt :: options(),
		PublicParams :: params().
params2(AccessKeyId, AccessKeySecret, ParamsExtra, ParamsPub, Opt) ->
	true = public_params_check(ParamsPub),
	ParamsPub1 = if
		is_map(ParamsPub) ->
			ParamsPub#{?AccessKeyId => AccessKeyId};
		is_list(ParamsPub) ->
			(maps:from_list(ParamsPub))#{?AccessKeyId => AccessKeyId}
	end,
	Signature = sign(AccessKeySecret, ParamsExtra, ParamsPub1),
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

%%% 
%%% Calc. SignatureNonce
%%%

sign(AccessKeySecret, ParamsExtra, Params) when is_map(ParamsExtra) ->
	StringToSign1 = maps:merge(ParamsExtra, Params),
	StringToSign2 = maps_to_utf8(StringToSign1),
	StringToSign3 = list2url(StringToSign2),
	StringToSign4 = http_uri:encode(StringToSign3),
	Key = binary:list_to_bin([AccessKeySecret, <<"&">>]),
	Signature1 = crypto:hmac(sha, Key, StringToSign4),
	base64:encode(Signature1);

sign(AccessKeySecret, ParamsExtra, Params) when is_list(ParamsExtra) ->
	ParamsExtra1 = maps:from_list(ParamsExtra),
	sign(AccessKeySecret, ParamsExtra1, Params).

%%% 
%%% ParamsExtra : encode to utf8
%%%
maps_to_utf8(Map) when is_map(Map) ->
    maps:from_list([encode1(K,V) ||{K,V}<-maps:to_list(Map)]).
encode1(K, V) ->
	{unicode:characters_to_binary(K), 
	 unicode:characters_to_binary(V)}.
encode2(_, V) ->
	unicode:characters_to_binary(V).

%%%
%%% proplist to url struct
%%%

list2url([]) ->
	"";
list2url(Map) when is_map(Map) ->
	list2url(maps:to_list(Map));
list2url(List) when is_list(List) ->
	List2 = lists:reverse(List),
	list2url(List2, []).

list2url([{Key, Val} | []], Url) ->
	list2url([], [Key, <<"=">> , Val | Url]);
list2url([{Key, Val} | Rest], Url) ->
	list2url(Rest, [<<"&">>, Key, <<"=">> , Val | Url]);
list2url([], Url) ->
	Url1 = binary:list_to_bin(Url),
	Url2 = unicode:characters_to_binary(Url1, unicode, utf8),
	binary_to_list(Url2).