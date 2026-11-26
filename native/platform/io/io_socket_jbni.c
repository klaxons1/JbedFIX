#include "io_socket.h"
#include "jbni_objects.h"

#include <stddef.h>
#include <stdint.h>

extern int android_LOGD(const char *, ...);

typedef struct {
    uint32_t header[3];
    uint8_t isHandleValid;
    int32_t handle;
    uint8_t connectionOpen;
    int32_t pushEntry;
} Connection;

_Static_assert(offsetof(Connection, handle) == 16, "NetworkConnectionBase handle offset");

enum {
    INVALID_OPTION = -256, NULL_BUFFER = -257, INVALID_RANGE = -258,
    IO_ERROR = -259, SHORT_DATAGRAM = -260, CONNECTION_REFUSED = -261,
    DATAGRAM_MAX_LENGTH = 1500, STARTUP_RETRY_MS = 50
};

#define DATAGRAM(name) JbniV_javax_microedition_io_datagram_1Protocol_##name
#define SERVER(name) JbniV_javax_microedition_io_serversocket_1Protocol_##name
#define SOCKET(name) JbniV_javax_microedition_io_socket_1Protocol_##name
#define BASE(name) JbniV_javax_microedition_io_NetworkConnectionBase_##name
#define BASE_STATIC(name) JbniS_javax_microedition_io_NetworkConnectionBase_##name

int DATAGRAM(getMaximumLength0)(Connection *self) { (void)self; return DATAGRAM_MAX_LENGTH; }
int DATAGRAM(getNominalLength0)(Connection *self) { (void)self; return DATAGRAM_MAX_LENGTH; }

static int close_connection(Connection *self, int clear_fd)
{
    if (!self->isHandleValid) return IO_ERROR;
    int rc = CPL_net_socketClose(self->handle);
    if (rc == CPL_NET_PENDING) return 0;
    self->isHandleValid = 0;
    if (clear_fd) self->handle = -1;
    return rc ? IO_ERROR : 0;
}

int DATAGRAM(close0)(Connection *self) { return close_connection(self, 0); }
int SERVER(close0)(Connection *self) { return close_connection(self, 0); }
int SOCKET(close0)(Connection *self) { return close_connection(self, 1); }

int64_t DATAGRAM(receive0)(Connection *self, JbArray *data, int offset, int length)
{
    if (!self->isHandleValid) return IO_ERROR;
    uint32_t ip = 0;
    uint16_t port = 0;
    int n = CPL_net_recvFrom(self->handle, (uint8_t *)data->data + offset, length, &ip, &port);
    if (n == CPL_NET_PENDING) return 0;
    if (n == -1) return IO_ERROR;
    return (int64_t)(((uint64_t)ip << 32) | ((uint32_t)port << 16) | (uint16_t)n);
}

int DATAGRAM(send0)(Connection *self, uint32_t ip, int port,
                    const JbArray *data, int offset, int length)
{
    if (!self->isHandleValid) return IO_ERROR;
    int n = CPL_net_sendTo(self->handle, (const uint8_t *)data->data + offset, length, ip, (uint16_t)port);
    if (n == CPL_NET_PENDING) return 0;
    if (n == -1) return IO_ERROR;
    return n < length ? SHORT_DATAGRAM : 0;
}

int DATAGRAM(open0)(Connection *self, int mode, int timeouts, int port)
{
    (void)mode;
    (void)timeouts;
    int rc = CPL_net_datagramSocket((uint16_t)port, &self->handle);
    if (rc && rc != CPL_NET_PENDING) return IO_ERROR;
    self->isHandleValid = 1;
    return 0;
}

int SERVER(accept)(Connection *self)
{
    uint32_t ip = 0;
    uint16_t port = 0;
    int client = 0;
    if (!self->isHandleValid || CPL_net_accept(self->handle, &ip, &port, &client)) return IO_ERROR;
    return client;
}

int SERVER(open0)(Connection *self, int port)
{
    int rc = CPL_net_serverSocket((uint16_t)port, &self->handle);
    self->isHandleValid = rc == 0 || rc == CPL_NET_PENDING;
    return self->isHandleValid ? 0 : IO_ERROR;
}

static uint8_t mutex_initialized, network_up;
static VmNotifier *startup_owner;

void initMutex(void)
{
    if (!mutex_initialized) mutex_initialized = 1;
}

void JPL_net_notifyNetworkDown(void)
{
    initMutex();
    network_up = 0;
    startup_owner = NULL;
}

void JPL_net_shutdown(void)
{
    initMutex();
    if (network_up || startup_owner) {
        CPL_net_shutdown();
        startup_owner = NULL;
        network_up = 0;
    }
    mutex_initialized = 0;
}

int JPL_net_startup(void)
{
    initMutex();
    if (network_up) return 0;
    if (startup_owner && startup_owner != vm_current_notifier()) {
        VmNotifier *other = vm_current_notifier();
        other->timeout = STARTUP_RETRY_MS;
        other->state = VM_BUSY;
        return CPL_NET_PENDING;
    }
    int rc = CPL_net_startup();
    if (rc == 0) network_up = 1;
    startup_owner = rc == CPL_NET_PENDING ? vm_current_notifier() : NULL;
    return rc;
}

int BASE_STATIC(initializeInternal)(void) { return JPL_net_startup() == 0; }
int BASE_STATIC(getHostByAddr0)(void) { return -1; }
int BASE_STATIC(getIpNumber0)(const JbString *host)
{
    uint32_t ip = 0;
    return CPL_net_getHostByName(jb_string_chars(host), host->length, &ip) ? -1 : (int32_t)ip;
}

void BASE(finalize)(Connection *self)
{
    if (self->isHandleValid) {
        int fd = self->handle;
        self->isHandleValid = 0;
        android_LOGD("Finalizing socket handle %d\n", fd);
        android_LOGD("WARNING: socket handle=%d not closed properly\n", fd);
        CPL_net_socketCloseNow(fd);
    }
}

int BASE(getLocalAddress0)(Connection *self)
{
    uint32_t ip = 0;
    uint16_t port = 0;
    return CPL_net_getSockName(self->handle, &ip, &port) ? IO_ERROR : (int32_t)ip;
}

int BASE(getLocalPort0)(Connection *self)
{
    uint32_t ip = 0;
    uint16_t port = 0;
    return CPL_net_getSockName(self->handle, &ip, &port) ? IO_ERROR : port;
}

int SOCKET(flush0)(Connection *self) { (void)self; return 0; }

int SOCKET(setSocketOpt)(Connection *self, unsigned option, int value)
{
    if (option > MIDP_SOCKET_SNDBUF) return INVALID_OPTION;
    if (!self->isHandleValid || CPL_net_setSockOpt(self->handle, option, value) == -1) return IO_ERROR;
    return 0;
}

int SOCKET(getSocketOpt)(Connection *self, unsigned option)
{
    if (option > MIDP_SOCKET_SNDBUF) return INVALID_OPTION;
    int value;
    if (!self->isHandleValid || CPL_net_getSockOpt(self->handle, option, &value) == -1) return -1;
    return value;
}

int SOCKET(getAddress0)(Connection *self)
{
    uint32_t ip = 0;
    uint16_t port = 0;
    if (!self->isHandleValid || CPL_net_getPeerName(self->handle, &ip, &port)) return -1;
    return (int32_t)ip;
}

int SOCKET(getPort0)(Connection *self)
{
    uint32_t ip = 0;
    uint16_t port = 0;
    if (!self->isHandleValid || CPL_net_getPeerName(self->handle, &ip, &port)) return IO_ERROR;
    return port;
}

int SOCKET(shutdownSocket0)(Connection *self, int how)
{
    return self->isHandleValid && !CPL_net_shutdownSocket(self->handle, how) ? 0 : IO_ERROR;
}

int SOCKET(available0)(Connection *self)
{
    int available;
    return self->isHandleValid && !CPL_net_getAvailable(self->handle, &available) ? available : IO_ERROR;
}

static int buffer_status(const Connection *self, const JbArray *data, int offset, int length)
{
    if (!data) return NULL_BUFFER;
    if (offset < 0 || length < 0 || offset > data->length || length > data->length-offset)
        return INVALID_RANGE;
    return self->isHandleValid ? 0 : IO_ERROR;
}

int SOCKET(write0)(Connection *self, const JbArray *data, int offset, int length)
{
    int status = buffer_status(self, data, offset, length);
    if (status) return status;
    int n = CPL_net_send(self->handle, (const uint8_t *)data->data + offset, length);
    return n == CPL_NET_PENDING || n == -1 ? IO_ERROR : n;
}

int SOCKET(read0)(Connection *self, JbArray *data, int offset, int length)
{
    int status = buffer_status(self, data, offset, length);
    if (status) return status;
    int n = CPL_net_recv(self->handle, (uint8_t *)data->data + offset, length);
    if (n == -1) return IO_ERROR;
    return n == 0 || n == CPL_NET_PENDING ? -1 : n;
}

int SOCKET(open0)(Connection *self, uint32_t ip, int port)
{
    int rc = CPL_net_clientSocket(ip, (uint16_t)port, 0, &self->handle);
    self->isHandleValid = rc == 0 || rc == CPL_NET_PENDING;
    if (self->isHandleValid) return 0;
    return rc == CPL_NET_REFUSED ? CONNECTION_REFUSED : IO_ERROR;
}
