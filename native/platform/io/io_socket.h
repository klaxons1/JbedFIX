#ifndef JBED_IO_SOCKET_H
#define JBED_IO_SOCKET_H

#include <stdint.h>

enum { CPL_NET_PENDING = -100, CPL_NET_REFUSED = -2 };
enum {
    MIDP_SOCKET_DELAY = 0, MIDP_SOCKET_LINGER = 1, MIDP_SOCKET_KEEPALIVE = 2,
    MIDP_SOCKET_RCVBUF = 3, MIDP_SOCKET_SNDBUF = 4
};
enum { CPL_SHUT_READ = 1, CPL_SHUT_WRITE = 2, CPL_SHUT_BOTH = 3 };
int CPL_net_startup(void);
void CPL_net_shutdown(void);
int CPL_net_datagramSocket(uint16_t port, int *fd);
int CPL_net_serverSocket(uint16_t port, int *fd);
int CPL_net_clientSocket(uint32_t ip, uint16_t port, int flags, int *fd);
int CPL_net_accept(int fd, uint32_t *ip, uint16_t *port, int *client);
int CPL_net_sendTo(int fd, const void *, unsigned length, uint32_t ip, uint16_t port);
int CPL_net_recvFrom(int fd, void *, unsigned length, uint32_t *ip, uint16_t *port);
int CPL_net_send(int fd, const void *, unsigned length);
int CPL_net_recv(int fd, void *, unsigned length);
int CPL_net_getSockName(int fd, uint32_t *ip, uint16_t *port);
int CPL_net_getPeerName(int fd, uint32_t *ip, uint16_t *port);
int CPL_net_getAvailable(int fd, int *bytes);
int CPL_net_shutdownSocket(int fd, int how);
int CPL_net_socketClose(int fd);
int CPL_net_socketCloseNow(int fd);
int CPL_net_getSockOpt(int fd, int option, int *value);
int CPL_net_setSockOpt(int fd, int option, int value);
int CPL_net_getHostByName(const uint16_t *name, int length, uint32_t *ip);
int CPL_net_getHostName(uint16_t *name, int *length);

int JPL_net_startup(void);
void JPL_net_shutdown(void);
void JPL_net_notifyNetworkDown(void);
void initMutex(void);

#endif
