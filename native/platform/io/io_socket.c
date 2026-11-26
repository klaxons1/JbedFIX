#include "io_socket.h"
#include "vm_async.h"
#include "vm_helpers.h"

#include <arpa/inet.h>
#include <errno.h>
#include <fcntl.h>
#include <netdb.h>
#include <netinet/tcp.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <unistd.h>

enum {
    READY_READ = 1, READY_WRITE = 4,
    LINUX_SO_LINGER = 13, CONNECT_TIMEOUT_MS = 180000, LISTEN_BACKLOG = 3
};
static char hostname[256];

int CPL_net_startup(void) { return 0; }
void CPL_net_shutdown(void) {}

static struct sockaddr_in address(uint32_t ip, uint16_t port)
{
    struct sockaddr_in addr = {0};
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(ip);
    addr.sin_port = htons(port);
    return addr;
}

static void unpack(const struct sockaddr_in *addr, uint32_t *ip, uint16_t *port)
{
    *port = ntohs(addr->sin_port);
    *ip = ntohl(addr->sin_addr.s_addr);
}

static void make_nonblocking(int fd)
{
    fcntl(fd, F_SETFL, fcntl(fd, F_GETFL) | O_NONBLOCK);
}

static int wait_ready(int fd, short events)
{
    aioc_when_fd_ready(fd, events);
    return CPL_NET_PENDING;
}

static int io_result(int fd, short events, ssize_t n)
{
    if (n >= 0) return (int)n;
    if (errno == EAGAIN || errno == EWOULDBLOCK) return wait_ready(fd, events);
    return -1;
}

int CPL_net_shutdownSocket(int fd, int how)
{
    short events;
    int direction;
    switch (how) {
    case CPL_SHUT_READ: events = READY_READ; direction = SHUT_RD; break;
    case CPL_SHUT_WRITE: events = READY_WRITE; direction = SHUT_WR; break;
    case CPL_SHUT_BOTH: events = READY_READ | READY_WRITE; direction = SHUT_RDWR; break;
    default: return -1;
    }
    aioc_unregister_fd_filter(fd, 1, events);
    return !shutdown(fd, direction) || errno == ENOTCONN ? 0 : -1;
}

int CPL_net_socketClose(int fd)
{
    aioc_unregister_fd(fd, 1);
    return close(fd) == 0 ? 0 : -1;
}

int CPL_net_socketCloseNow(int fd) { return CPL_net_socketClose(fd); }

static uint32_t first_address(const struct hostent *host)
{
    uint32_t ip;
    memcpy(&ip, host->h_addr_list[0], sizeof(ip));
    return ntohl(ip);
}

int CPL_net_getSockName(int fd, uint32_t *ip, uint16_t *port)
{
    struct sockaddr_in addr;
    socklen_t size = sizeof(addr);
    if (getsockname(fd, (struct sockaddr *)&addr, &size)) return -1;
    unpack(&addr, ip, port);
    if (!*ip && gethostname(hostname, sizeof(hostname)) == 0) {
        struct hostent *host = gethostbyname(hostname);
        if (host) *ip = first_address(host);
    }
    return 0;
}

int CPL_net_getPeerName(int fd, uint32_t *ip, uint16_t *port)
{
    struct sockaddr_in addr;
    socklen_t size = sizeof(addr);
    if (getpeername(fd, (struct sockaddr *)&addr, &size)) return -1;
    unpack(&addr, ip, port);
    return 0;
}

int CPL_net_getAvailable(int fd, int *bytes)
{
    return ioctl(fd, FIONREAD, bytes) == -1 ? -1 : 0;
}

static int socket_option(int option)
{
    switch (option) {
    case MIDP_SOCKET_DELAY: return TCP_NODELAY;
    case MIDP_SOCKET_KEEPALIVE: return SO_KEEPALIVE;
    case MIDP_SOCKET_RCVBUF: return SO_RCVBUF;
    case MIDP_SOCKET_SNDBUF: return SO_SNDBUF;
    default: return option;
    }
}

int CPL_net_getSockOpt(int fd, int option, int *value)
{
    /* Both the MIDP and the native Linux number select SO_LINGER. */
    if (option == MIDP_SOCKET_LINGER || option == LINUX_SO_LINGER) {
        struct linger linger;
        socklen_t size = sizeof(linger);
        if (getsockopt(fd, SOL_SOCKET, SO_LINGER, &linger, &size)) return -1;
        *value = linger.l_onoff ? linger.l_linger : -1;
    } else {
        socklen_t size = sizeof(*value);
        int level = option == MIDP_SOCKET_DELAY ? IPPROTO_TCP : SOL_SOCKET;
        if (getsockopt(fd, level, socket_option(option), value, &size)) return -1;
        if (option == MIDP_SOCKET_DELAY) *value = !*value;
    }
    return 0;
}

int CPL_net_setSockOpt(int fd, int option, int value)
{
    if (option == MIDP_SOCKET_LINGER || option == LINUX_SO_LINGER) {
        struct linger linger = {.l_onoff = value > 0, .l_linger = value};
        return setsockopt(fd, SOL_SOCKET, SO_LINGER, &linger, sizeof(linger)) ? -1 : 0;
    }
    int level = option == MIDP_SOCKET_DELAY ? IPPROTO_TCP : SOL_SOCKET;
    if (option == MIDP_SOCKET_DELAY) value = !value;
    return setsockopt(fd, level, socket_option(option), &value, sizeof(value)) ? -1 : 0;
}

int CPL_net_sendTo(int fd, const void *data, unsigned n, uint32_t ip, uint16_t port)
{
    struct sockaddr_in addr = address(ip, port);
    return io_result(fd, READY_WRITE, sendto(fd, data, n, 0, (struct sockaddr *)&addr, sizeof(addr)));
}

int CPL_net_recvFrom(int fd, void *data, unsigned n, uint32_t *ip, uint16_t *port)
{
    struct sockaddr_in addr;
    socklen_t size = sizeof(addr);
    ssize_t count = recvfrom(fd, data, n, 0, (struct sockaddr *)&addr, &size);
    if (count >= 0) unpack(&addr, ip, port);
    return io_result(fd, READY_READ, count);
}

int CPL_net_send(int fd, const void *data, unsigned n)
{
    ssize_t count = send(fd, data, n, MSG_NOSIGNAL);
    if (count == 0) return wait_ready(fd, READY_WRITE);
    return io_result(fd, READY_WRITE, count);
}

int CPL_net_recv(int fd, void *data, unsigned n)
{
    return io_result(fd, READY_READ, recv(fd, data, n, 0));
}

int CPL_net_accept(int fd, uint32_t *ip, uint16_t *port, int *client)
{
    struct sockaddr_in addr;
    socklen_t size = sizeof(addr);
    int socket_fd = accept(fd, (struct sockaddr *)&addr, &size);
    if (socket_fd == -1) return io_result(fd, READY_READ, -1);
    make_nonblocking(socket_fd);
    unpack(&addr, ip, port);
    *client = socket_fd;
    return 0;
}

static int bind_socket(uint16_t port, int *out, int type)
{
    int fd = socket(AF_INET, type, 0);
    if (fd == -1) return -1;
    make_nonblocking(fd);
    if (type == SOCK_STREAM) {
        int reuse = 1;
        setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse));
    }
    struct sockaddr_in addr = address(INADDR_ANY, port);
    if (bind(fd, (struct sockaddr *)&addr, sizeof(addr)) || (type == SOCK_STREAM && listen(fd, LISTEN_BACKLOG))) {
        close(fd);
        return -1;
    }
    *out = fd;
    return 0;
}

int CPL_net_datagramSocket(uint16_t port, int *fd) { return bind_socket(port, fd, SOCK_DGRAM); }
int CPL_net_serverSocket(uint16_t port, int *fd) { return bind_socket(port, fd, SOCK_STREAM); }

int CPL_net_clientSocket(uint32_t ip, uint16_t port, int flags, int *out)
{
    (void)flags;
    if (vm_current_notifier()->state == VM_DONE0) {
        int fd = socket(AF_INET, SOCK_STREAM, 0);
        *out = fd;
        if (fd == -1) return -1;
        make_nonblocking(fd);
        struct sockaddr_in addr = address(ip, port);
        if (!connect(fd, (struct sockaddr *)&addr, sizeof(addr))) return 0;
        int error = errno;
        if (error == EINPROGRESS) {
            aioc_when_fd_ready_or_timeout(fd, READY_WRITE, CONNECT_TIMEOUT_MS);
            return CPL_NET_PENDING;
        }
        close(fd);
        return error == ECONNREFUSED ? CPL_NET_REFUSED : -1;
    }

    int fd = *out;
    int result = CPL_NET_REFUSED;
    if (vm_current_notifier()->state != VM_TIMEOUT) {
        int error = 0;
        socklen_t size = sizeof(error);
        if (getsockopt(fd, SOL_SOCKET, SO_ERROR, &error, &size)) result = -1;
        else if (!error) return 0;
        else if (error != ECONNREFUSED) result = -1;
    }
    *out = -1;
    close(fd);
    return result;
}

int CPL_net_getHostName(uint16_t *out, int *length)
{
    if (gethostname(hostname, sizeof(hostname))) return -1;
    *length = Jbni_convertAsciiToUcs2(hostname, -1, out, *length);
    return *length == -1 ? -1 : 0;
}

int CPL_net_getHostByName(const uint16_t *name, int length, uint32_t *ip)
{
    if (Jbni_convertUcs2ToAscii(name, length, hostname, sizeof(hostname)) == -1) return -1;
    struct hostent *host = gethostbyname(hostname);
    if (!host || host->h_addrtype != AF_INET || host->h_length != 4 || !host->h_addr_list[0])
        return -1;
    *ip = first_address(host);
    return 0;
}
