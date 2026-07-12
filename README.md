# moodtcpcli — Zero-dependency TCP primitives for MoonBit

Pure C FFI TCP network primitives for MoonBit, ported from [rstcpcli](https://git.t2be.cn/aspnmy/rstcpcli).

## Source

This package is ported from the TCP connectivity features of [rstcpcli](https://github.com/aspnmy/rstcpcli) (Rust CLI network tool).

- **Gitea (upstream):** https://git.t2be.cn/aspnmy/rstcpcli
- **GitHub mirror:** https://github.com/aspnmy/rstcpcli

## API

| Function | Description |
|----------|-------------|
| `tcp_ping(host, port)` | TCP connectivity check |
| `http_get(url)` | HTTP GET request |
| `http_post(url, body)` | HTTP POST request |
| `listen_port(port)` | Listen on TCP port |

## License

Apache-2.0
