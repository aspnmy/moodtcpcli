#borrow(host)
extern "C" fn tcp_connect(host: Bytes, port: Int) -> Int = "moonbit_tcp_connect"
extern "C" fn tcp_close(fd: Int) -> Unit = "moonbit_tcp_close"
extern "C" fn tcp_listen(port: Int) -> Int = "moonbit_tcp_listen"
#borrow(host)
#borrow(req)
#borrow(resp)
extern "C" fn http_request(host: Bytes, port: Int, req: Bytes, resp: FixedArray[Byte], size: Int) -> Int = "moonbit_http_request"

pub fn tcp_ping(host: String, port: Int) -> Result[Unit, String] {
  let h = host.to_bytes()
  let fd = tcp_connect(h, port)
  if fd < 0 { return Err("connect failed") }
  tcp_close(fd)
  Ok(())
}

pub fn http_get(url: String) -> Result[String, String] {
  let (h, p, path) = parse_url(url)
  let req = "GET " + path + " HTTP/1.1\r\nHost: " + h + "\r\nConnection: close\r\n\r\n"
  http_req(h, p, req)
}

pub fn http_post(url: String, body: String) -> Result[String, String] {
  let (h, p, path) = parse_url(url)
  let req = "POST " + path + " HTTP/1.1\r\nHost: " + h + "\r\nContent-Type: application/json\r\nContent-Length: " + body.length().to_string() + "\r\nConnection: close\r\n\r\n" + body
  http_req(h, p, req)
}

fn http_req(host: String, port: Int, req: String) -> Result[String, String] {
  let h = host.to_bytes()
  let r = req.to_bytes()
  let resp: FixedArray[Byte] = FixedArray::make(65536, 0)
  let n = http_request(h, port, r, resp, 65536)
  if n < 0 { return Err("HTTP request failed") }
  let mut s = ""
  for i in 0..<n {
    let b: Byte = resp[i]
    s = s + b.to_int().to_char().to_string()
  }
  if s.contains("HTTP/1.1 2") || s.contains("HTTP/1.1 3") {
    Ok(extract_body(s))
  } else {
    Err("HTTP error: " + s)
  }
}

fn extract_body(resp: String) -> String {
  match resp.find("\r\n\r\n") {
    Some(pos) => resp[:pos].to_owned()
    None => resp
  }
}

pub fn listen_port(port: Int) -> Result[Int, String] {
  let fd = tcp_listen(port)
  if fd < 0 { return Err("listen failed") }
  Ok(fd)
}

fn parse_url(url: String) -> (String, Int, String) {
  let s = if url.has_prefix("http://") { url[7:].to_owned() } else { url }
  match s.find("/") {
    Some(slash_i) => {
      let host_part = s[:slash_i].to_owned()
      let path = s[slash_i:].to_owned()
      match host_part.find(":") {
        Some(ci) => {
          let h = host_part[:ci].to_owned()
          let p_str = host_part[ci+1:].to_owned()
          let p = try @string.parse_int(p_str) catch { _ => 80 }
          (h, p, path)
        }
        None => (host_part, 80, path)
      }
    }
    None => (s, 80, "/")
  }
}
