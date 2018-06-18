my_otter
=====

An OTP application


PreReqs
-------
    $ docker run -d jaegertracing/all-in-one


Build
-----

    $ rebar3 compile && rebar3 shell


Test
----

```
curl 'http://localhost:2938/' -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/66.0.3359.181 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.9,pt-BR;q=0.8,pt;q=0.7,pt-PT;q=0.6' --compressed
```
and then

open http://localhost:16686/
