[TOC]

# pub-sign

[![Build Status](https://travis-ci.org/aliyun-esdk/public-parameters.svg?branch=master)](https://travis-ci.org/aliyun-esdk/public-parameters)

阿里云公共参数计算应用，用来计算阿里云公共参数。

- [x] **SignatureNonce** 使用`uuid`
- [x] 传入参数：`map` 或 `proplists`
- [x] 返回值：`map` 或 `proplists`


参考：

- [公共请求参数](https://help.aliyun.com/document_detail/29745.html)

- [签名机制](https://help.aliyun.com/document_detail/29747.html)

## 注意事项

**传入参数的各项最好是utf8格式**。 根据[签名机制](https://help.aliyun.com/document_detail/29747.html)，如果http请求中有中文等非`utf8`格式的数据，本应用使用时会全部转换为`utf8`。

## 编译（Build）

```bash
$ make
```
或者
```bash
$ make compile
```

## 用法（usage）

调用示例：

```erlang
%% AccessKeyId       阿里云颁发给用户的访问服务所用的密钥ID
%% AccessKeySecret   阿里云颁发给用户的访问服务所用的密钥
%% ParamsExtra       http请求中除了公共参数以外的其它参数
%% -------------------------
%% PublicParams  http GET/POST 请求中的公共参数，包含签名结果
PublicParams = pub_params:params(AccessKeyId, AccessKeySecret, ParamsExtra).
```

#### 运行示例：

```bash
$ make release && make console
```
```erlang
... ...
=PROGRESS REPORT==== 8-Feb-2017::13:43:00 ===
         application: sasl
          started_at: pub_params@yWHtlN
Eshell V8.2  (abort with ^G)
(pub_params@yWHtlN)1> AccessKeyId = "testid".
"testid"
(pub_params@yWHtlN)2> AccessKeySecret = "testsecret".
"testsecret"
(pub_params@yWHtlN)3> pub_params:params(AccessKeyId, AccessKeySecret, []).
#{<<"AccessKeyId">> => <<"testid">>,
  <<"Format">> => <<"XML">>,
  <<"Signature">> => <<"tklk/lF55T7XC+fAJ0qQJCp3Z/4=">>,
  <<"SignatureMethod">> => <<"HMAC-SHA1">>,
  <<"SignatureNonce">> => <<"c7af59e1-44c3-4446-97df-42527e6f7eb1">>,
  <<"SignatureVersion">> => <<"1.0">>,
  <<"Timestamp">> => <<"2017-02-08T17:00:06.212578Z">>,
  <<"Version">> => <<"2015-01-09">>}
(pub_params@yWHtlN)4> pub_params:params(AccessKeyId, AccessKeySecret, [], proplist).
[{<<"AccessKeyId">>,<<"testid">>},
 {<<"Format">>,<<"XML">>},
 {<<"Signature">>,<<"BQSE/rt5fw5YNJoobAkGxBDYc/E=">>},
 {<<"SignatureMethod">>,<<"HMAC-SHA1">>},
 {<<"SignatureNonce">>,
  <<"1f18c4d7-4236-42cf-b0b8-2631e2fc7e69">>},
 {<<"SignatureVersion">>,<<"1.0">>},
 {<<"Timestamp">>,<<"2017-02-08T17:03:11.015449Z">>},
 {<<"Version">>,<<"2015-01-09">>}]
(pub_params@yWHtlN)5>
```

####  在你的项目中使用

将**pub-params** 添加到 `rebar.config`:

```bash
... ...

{deps, [
    {pub_params , {git, "https://github.com/aliyun-esdk/public-parameters.git", {branch, "master"}}}
]}.
... ...
```


## 开源协议
遵循开源协议 **Apache License, Version 2.0** ，细节请阅读 **LICENSE** 文件