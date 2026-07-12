#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

int moonbit_tcp_connect(const char* host, int port) {
    int fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0) return -1;
    struct hostent* he = gethostbyname(host);
    if (!he) { close(fd); return -1; }
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    memcpy(&addr.sin_addr, he->h_addr_list[0], he->h_length);
    int r = connect(fd, (struct sockaddr*)&addr, sizeof(addr));
    if (r < 0) { close(fd); return -1; }
    return fd;
}

void moonbit_tcp_close(int fd) {
    if (fd >= 0) close(fd);
}

int moonbit_tcp_listen(int port) {
    int fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0) return -1;
    int opt = 1;
    setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
    struct sockaddr_in addr;
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    addr.sin_addr.s_addr = INADDR_ANY;
    if (bind(fd, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        close(fd); return -1;
    }
    if (listen(fd, 1) < 0) { close(fd); return -1; }
    return fd;
}

int moonbit_http_request(const char* host, int port, const char* req, char* resp, int bufsize) {
    int fd = moonbit_tcp_connect(host, port);
    if (fd < 0) return -1;
    if (write(fd, req, strlen(req)) < 0) { close(fd); return -1; }
    int total = 0;
    while (total < bufsize - 1) {
        int n = read(fd, resp + total, bufsize - total - 1);
        if (n <= 0) break;
        total += n;
    }
    resp[total] = 0;
    close(fd);
    return total;
}
