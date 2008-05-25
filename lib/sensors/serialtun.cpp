/* serialtun tunnels a serial port connection over a tcp connection.  it accepts
 * connections on the specified port, shuttles data back and forth, and closes
 * both connections when the tcp connection drops.
 *
 * usage: serialtun TCPPORT SERIALPORT
 *   where TCPPORT is the number of the tcp port to bind to, and SERIALPORT is the
 *   filename of the serial port to tunnel (e.g. COM5)
 *
 * NOTE: binds to INADDR_ANY (0.0.0.0) by default; change BIND_ADDRESS if this
 * isn't okay
 *
 * written by brandon creighton (bjc@pobox.com) sometime around
 * Sat Jan 26 22:17:15 EST 2008
 * 
 * this file is in the public domain.  
 */

#define BIND_ADDRESS "0.0.0.0"

#include <list>
#include <stdio.h>
#include <tchar.h>
#include <winsock2.h>
#include <windows.h>
#include <strsafe.h>
#pragma comment(lib, "ws2_32.lib")

void fullexit(unsigned int val);
void cwrite(char *msg);
void printerr(char *start);
class IOOVERLAPPED;
class handleholder;
void add_port_write(handleholder *hh, char *buf, DWORD count);
void add_sock_write(handleholder *hh, char *buf, DWORD count);
void add_sock_read(handleholder *hh);
void add_port_read(handleholder *hh);
void config_serial(HANDLE port);

typedef enum { SOCKREAD = 1, PORTREAD = 2, SOCKWRITE = 3, 
    PORTWRITE = 4 } io_op_t;
    
static SOCKET clisock, srvsock;
static HANDLE port;
static bool socketopen;
using namespace std;

class handleholder {
    private:
        list<IOOVERLAPPED *> iolist;
        list<HANDLE> extraevents;
    public:
        ~handleholder() {
            clear();
        }
        void clear();
        void remove(IOOVERLAPPED *ioo);
        void add(IOOVERLAPPED *ioo);
        void addevent(HANDLE h);
        HANDLE *gethandles();
        int handlecount();
};
class IOOVERLAPPED : public OVERLAPPED {
    public:
        handleholder *hh;
        WSABUF wsabuf;
        DWORD statval;
        DWORD bufsiz;
        DWORD flags;
        bool delbuf;
        char *buf;
        io_op_t iop;
        IOOVERLAPPED(char *nbuf, DWORD nbufsiz, handleholder *nhh, io_op_t niop) 
            : OVERLAPPED(), statval(0), flags(0), buf(nbuf), bufsiz(nbufsiz), 
             hh(nhh), iop(niop) {
            delbuf = true;
            SecureZeroMemory(this, sizeof(OVERLAPPED));
            if((hEvent = CreateEvent(NULL, TRUE, FALSE, NULL)) == NULL) {
                printerr("CreateEvent");
                fullexit(1);
            }
        }
        IOOVERLAPPED(DWORD nbufsiz, handleholder *nhh, io_op_t niop) 
            : OVERLAPPED(), statval(0), flags(0), bufsiz(nbufsiz), 
             hh(nhh), iop(niop) {
            SecureZeroMemory(this, sizeof(OVERLAPPED));
            buf = new char[bufsiz];
            delbuf = true;
               SecureZeroMemory(buf, bufsiz);    
            if((hEvent = CreateEvent(NULL, TRUE, FALSE, NULL)) == NULL) {
                printerr("CreateEvent");
                fullexit(1);
            }
        }
        ~IOOVERLAPPED() {
            if(hh != NULL) {
                hh->remove(this);
            }
            SetEvent(hEvent);
            CloseHandle(hEvent);
            if(delbuf && buf != NULL) {
                delete []buf;
            }
        }
        WSABUF *getwsabuf() {
            wsabuf.len = bufsiz;
            wsabuf.buf = buf;
            return &wsabuf;
        }
        char *getbuffer() { return buf; }
        DWORD getbufsize() { return bufsiz; }
        LPDWORD getstatword() { return &statval; }
        LPDWORD getflagsptr() { return &flags; }
        static void CALLBACK wsacompletion(IN DWORD dwError, 
                IN DWORD cbTransferred, IN OVERLAPPED *overlapped, IN DWORD flags) {
            IOOVERLAPPED *ioo = static_cast<IOOVERLAPPED *>(overlapped);
            switch(ioo->iop) {
                case SOCKREAD:
                    if(cbTransferred > 0) {
                        // ioo->buf[cbTransferred] = 0; printf("XXX sock read: %s\r\n", ioo->buf);
                        add_port_write(ioo->hh, ioo->buf, cbTransferred);
                        add_sock_read(ioo->hh);
                    } else {
                        closesocket(clisock);
                        break;
                    }
                    break;
                case PORTREAD:
                    if(cbTransferred > 0) {
                        // ioo->buf[cbTransferred] = 0; printf("XXX sock read: %s\r\n", ioo->buf); 
                        add_sock_write(ioo->hh, ioo->buf, cbTransferred);
                        add_port_read(ioo->hh);
                    }
                    break;
                case SOCKWRITE:
                    //printf("XXX sock wrote: %d/%d bytes\r\n", cbTransferred, ioo->bufsiz);
                    if(cbTransferred < ioo->bufsiz) {
                        add_sock_write(ioo->hh, &(ioo->buf[cbTransferred]), 
                                ioo->bufsiz-cbTransferred);
                    }
                    break;
                case PORTWRITE:
                    //printf("XXX port wrote: %d/%d bytes\r\n", cbTransferred, ioo->bufsiz);
                    if(cbTransferred < ioo->bufsiz) {
                        add_port_write(ioo->hh, &(ioo->buf[cbTransferred]), 
                                ioo->bufsiz-cbTransferred);
                    }
                    break;
                default:
                    printf("invalid io op %d! exiting\r\n", ioo->iop);
                    fullexit(1);
                    break;
            }
            delete ioo;
        }
        static void CALLBACK filecompletion(IN DWORD dwError,
                IN DWORD cbTransferred, IN OVERLAPPED *overlapped) {
            wsacompletion(dwError, cbTransferred, overlapped, 0);
        }
};


void cwrite(char *msg) {
    HANDLE console = GetStdHandle(STD_OUTPUT_HANDLE);
    WriteConsole(console, msg, strlen(msg), NULL, NULL);
}
void printerr(char *start) 
{ 
    LPVOID errmsg;
    DWORD dw = GetLastError(); 

    FormatMessage(
        FORMAT_MESSAGE_ALLOCATE_BUFFER | 
        FORMAT_MESSAGE_FROM_SYSTEM |
        FORMAT_MESSAGE_IGNORE_INSERTS,
        NULL,
        dw,
        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
        (LPTSTR) &errmsg,
        0, NULL );

    cwrite(start);
    cwrite(": ");
    cwrite((char *)errmsg);
    cwrite("\r\n");

    LocalFree(errmsg);
}

SOCKET bindport(int port) {
    SOCKET sock;
    sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (sock == INVALID_SOCKET) {
        printerr("socket");
        fullexit(1);
    }
    sockaddr_in service;
    service.sin_family = AF_INET;
    service.sin_addr.s_addr = inet_addr(BIND_ADDRESS);
    service.sin_port = htons(port);
    if (bind(sock, (SOCKADDR*) &service, sizeof(service)) == SOCKET_ERROR) {
        printerr("bind()");
        closesocket(sock);
        fullexit(1);
    }
    BOOL b = TRUE;
    if(setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, (const char *)&b, sizeof(b)) 
            == SOCKET_ERROR) {
        printerr("setsockopt()");
        closesocket(sock);
        fullexit(1);
    }

    if(listen(sock, 1) == SOCKET_ERROR) {
        printerr("listen()");
        closesocket(sock);
        fullexit(1);
    }
    return sock;
}

void fullexit(unsigned int val) {
    WSACleanup();
    ExitProcess(1);
}

void add_sock_read(handleholder *hh) {
    IOOVERLAPPED *ioo = new IOOVERLAPPED(65536, hh, SOCKREAD);
    int retval = WSARecv(clisock, ioo->getwsabuf(), 1,
            ioo->getstatword(), ioo->getflagsptr(), ioo, IOOVERLAPPED::wsacompletion);
    if(retval == SOCKET_ERROR && WSAGetLastError() != WSA_IO_PENDING) {
        printerr("client socket read error");
        CloseHandle(port);
        closesocket(clisock);
        closesocket(srvsock);
        fullexit(1);
    }
    hh->add(ioo);
}
void add_sock_write(handleholder *hh, char *buf, DWORD count) {
    char *newbuf = new char[count];
    memcpy(newbuf, buf, count);
    IOOVERLAPPED *ioo = new IOOVERLAPPED(newbuf, count, hh, SOCKWRITE);
    int retval = WSASend(clisock, ioo->getwsabuf(), 1, 
            ioo->getstatword(), 0, ioo,
            IOOVERLAPPED::wsacompletion);
    if(retval == SOCKET_ERROR && WSAGetLastError() != WSA_IO_PENDING) {
        printerr("client socket write error");
        CloseHandle(port);
        closesocket(clisock);
        closesocket(srvsock);
        fullexit(1);
    }
    hh->add(ioo);
}
void add_port_read(handleholder *hh) {
    IOOVERLAPPED *ioo = new IOOVERLAPPED(65536, hh, PORTREAD);
    if(ReadFileEx(port, ioo->getbuffer(), ioo->getbufsize(), ioo, 
                IOOVERLAPPED::filecompletion) == 0 
            && GetLastError() != ERROR_IO_PENDING) {
        printerr("port read error");
        CloseHandle(port);
        closesocket(clisock);
        closesocket(srvsock);
        fullexit(1);
    }
    hh->add(ioo);
}
void add_port_write(handleholder *hh, char *buf, DWORD count) {
    char *newbuf = new char[count];
    memcpy(newbuf, buf, count);
    IOOVERLAPPED *ioo = new IOOVERLAPPED(newbuf, count, hh, PORTWRITE);
    if(WriteFileEx(port, ioo->getbuffer(), ioo->getbufsize(), ioo, 
                IOOVERLAPPED::filecompletion) == 0
            && GetLastError() != ERROR_IO_PENDING) {
        printerr("port write error");
        CloseHandle(port);
        closesocket(clisock);
        closesocket(srvsock);
        fullexit(1);
    }
    hh->add(ioo);
}
int _tmain(int argc, _TCHAR* argv[])
{
    HANDLE console = GetStdHandle(STD_OUTPUT_HANDLE);
    if(argc < 3) {
        fprintf(stderr, "usage: %s tcpport file\r\n", argv[0]);
        fullexit(1);
    }
    
    WSADATA wsaData;
    int iResult = WSAStartup(MAKEWORD(2,2), &wsaData);
    if (iResult != NO_ERROR) {
        printerr("WSAStartup");
        fullexit(1);
    }

    int portnum = atoi(argv[1]);
    handleholder *hh = new handleholder();
    while(true) {
        srvsock = bindport(portnum);
        printf("listening on port %d\r\n", portnum);
        clisock = accept(srvsock, NULL, NULL);
        if(clisock == INVALID_SOCKET) {
            printerr("accept()");
            closesocket(srvsock);
            fullexit(1);
        }
        printf("accepted\r\n");
        HANDLE clisockcloseevent = CreateEvent(NULL, TRUE, FALSE, NULL);
        if(WSAEventSelect(clisock, clisockcloseevent, FD_CLOSE) == SOCKET_ERROR) {
            printerr("WSAEventSelect");
            closesocket(srvsock);
            closesocket(clisock);
            fullexit(1);
        }
        hh->addevent(clisockcloseevent);
        socketopen = true;
        printf("accepted client; opening port %s\r\n", argv[2]);
        port = CreateFile(argv[2],  GENERIC_READ|GENERIC_WRITE, 0, NULL,
                OPEN_EXISTING, FILE_FLAG_OVERLAPPED, NULL);
        if(port == INVALID_HANDLE_VALUE) {
            printerr("open");
            closesocket(clisock);
            closesocket(srvsock);
            fullexit(1);
        }
        config_serial(port);

        add_sock_read(hh);
        add_port_read(hh);
        
        while(socketopen) {
            HANDLE *handles = hh->gethandles();
            DWORD handlecount = hh->handlecount();
            DWORD ret = WaitForMultipleObjectsEx(handlecount, handles,
                    FALSE, INFINITE, TRUE);
            if(ret == WAIT_FAILED) {
                printerr("WaitForMultipleObjectsEx");
                closesocket(clisock);
                closesocket(srvsock);
                CloseHandle(port);
                fullexit(1);
            }
            delete[] handles;
            if(WaitForSingleObject(clisockcloseevent, 0) == WAIT_OBJECT_0) {
                break;
            }
        }
        hh->clear();
        CloseHandle(port);
        CloseHandle(clisockcloseevent);
        closesocket(clisock);
        closesocket(srvsock);
        WaitForMultipleObjectsEx(0, NULL, false, 1, TRUE);
        printf("connection closed.  waiting for new connection...\r\n");
    }
    closesocket(srvsock);
    return 0;
}
void config_serial(HANDLE port) {
    DCB dcb;
    SecureZeroMemory(&dcb, sizeof(dcb));
    if(!GetCommState(port, &dcb)) {
        printerr("GetCommState");
        fullexit(1);
    }
    dcb.BaudRate = 115200;
    dcb.ByteSize = 8;
    dcb.StopBits = 1;
    dcb.Parity = NOPARITY;
    dcb.fBinary = TRUE;
    dcb.fDtrControl = DTR_CONTROL_ENABLE;
    dcb.fDsrSensitivity = FALSE;
    dcb.fTXContinueOnXoff = FALSE;
    dcb.fOutX = FALSE;
    dcb.fInX = FALSE;
    dcb.fErrorChar = FALSE;
    dcb.fNull = FALSE;
    dcb.fRtsControl = RTS_CONTROL_ENABLE;
    dcb.fAbortOnError = FALSE;
    dcb.fOutxCtsFlow = FALSE;
    dcb.fOutxDsrFlow = FALSE;
    if (!SetCommState(port, &dcb)) {
        printerr("SetCommState");
        fullexit(1);
    }

    COMMTIMEOUTS timeouts;
    SecureZeroMemory(&timeouts, sizeof(timeouts));
    timeouts.ReadIntervalTimeout = 1;
    timeouts.ReadTotalTimeoutMultiplier = 0;
    timeouts.ReadTotalTimeoutConstant = 0;
    timeouts.WriteTotalTimeoutMultiplier = 0;
    timeouts.WriteTotalTimeoutConstant = 0;
    if (!SetCommTimeouts(port, &timeouts)) {
        printerr("SetCommTimeouts");
        fullexit(1);
    }
}

void handleholder::addevent(HANDLE h) {
    extraevents.push_back(h);
}
void handleholder::add(IOOVERLAPPED *ioo) {
    iolist.push_back(ioo);
}
HANDLE *handleholder::gethandles() {
    HANDLE *handles = new HANDLE[iolist.size() + extraevents.size()];
    int i = 0;
    for(list<IOOVERLAPPED *>::iterator it = iolist.begin(); 
            it != iolist.end(); it++, i++) {
        handles[i] = (*it)->hEvent;
    }
    for(list<HANDLE>::iterator it = extraevents.begin();
            it != extraevents.end(); it++, i++) {
        handles[i] = (*it);
    }
    return handles;
}
int handleholder::handlecount() {
    return iolist.size() + extraevents.size();
}
void handleholder::clear() {
    iolist.clear();
    extraevents.clear();
}
void handleholder::remove(IOOVERLAPPED *ioo) {
    for(list<IOOVERLAPPED *>::iterator it = iolist.begin();
            it != iolist.end(); it++) {
        if(*it == ioo) {
            iolist.remove(ioo);
            return;
        }
    }
}


