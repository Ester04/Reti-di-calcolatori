# *__Socket programming and transport level tools__*

## **Generiche**
### What is a socket?
Sockets are the abstraction through which the application can communicate through a network.
Le **API** definite dal BSD (Berkeley Software Distribution) servono per creare e gestire le connessioni di rete. 

**Useful commands:**
- `ss` for socket inspection
- `netstat` for network statistics
- `lsof` for open ports and files
- `tcpdump` for packet capture
- `ping` for connectivity checks

**Main functions in C**
- `socket()`
- `bind()`
- `listen()`
- `accept()`
- `connect()`
- `send()` / `recv()`

**Main functions in Python**
- `socket.socket()`
- `socket.bind()`
- `socket.listen()`
- `socket.accept()`
- `socket.connect()`
- `socket.send()` / `socket.recv()`

**Server workflow**
1. create the socket
2. bind it to an address and port
3. listen for incoming requests
4. accept a connection
5. exchange data
6. close the connection (only for UDP?)

**Client workflow**
1. create the socket
2. connect to the server
3. exchange data
4. close the connection (only for UDP?)

### Cose da ricordare UDP vs TCP: in C e Python
- **Things to remember for C programs:**
    - Use `SOCK_DGRAM` <u>instead of</u>  `SOCK_STREAM`
    - No need to call `listen()`, `accept()`, `connect()`
    - Only `recvfrom()` and `sendto()` <u>instead of</u>  `read()` and `write()`
- **Things to remember for Python programs:**
    - Use `socket.SOCK_DGRAM` <u>instead of</u> `socket.SOCK_STREAM`
    - No need to call `s.listen()`, `s.accept()`, `s.connect()`
    - Use `s.sendto()` <u>instead of</u>  `s.sendall()`
    - Use `s.recvfrom()` <u>instead of</u>  `s.recv()`
    - Check how communication occurs using also `wireshark`

> Important note: le porte utilizzate dai socket sono numeri interi a 16 bit, quindi vanno da 0 a 65535. Le porte da 0 a 1023 sono riservate ai servizi di sistema (well-known ports), mentre **le porte da 1024 a 49151** sono registrate per applicazioni specifiche (registered ports). Le porte da 49152 a 65535 sono dinamiche o private e possono essere utilizzate liberamente dalle applicazioni.


## **Transport layer tools**
### Socket statistics (ss)
Socket statistics (ss) is one of the applications that allows you to view and
analyze the sockets used by the system


```bash
ss [-tuelanp] [query]
```

- `-t`: show TCP connections
- `-u`: show UDP connections
- `-e`: show additional information
- `-l`: show sockets in “listen” state
- `-a`: show sockets in whatever state they are
- `-n`: does not perform DNS resolution of “known” addresses and ports
- `-p`: show the program associated with the connection

**Example:**
```bash
ss -tuln #show all listening TCP and UDP sockets
ss -tua #show all TCP and UDP sockets in whatever state they are
ss -ltp | grep <port> #show listening TCP sockets on a specific port (UTILE)
ss -ltp | grep <program> #show listening TCP sockets for a specific program
ss -ltp | grep <ip> #show listening TCP sockets for a specific IP address (UTILE)
```

### Netcat (nc)
Netcat (nc) is a command that allows you to exchange arbitrary messages using
the TCP and UDP protocols. In practice, it is used to test the connectivity of a port on a remote host.

```bash
#Client side
nc [-options] <hostname> <port> #Apre la connessione verso il server

#Server side
nc [-options] -l -p <port> #Apre la porta in ascolto (-l) per le connessioni in ingresso
```
Opzioni per client e server:
- `-u`: use UDP instead of TCP
- `-v`: verbose output
- `-n`: numeric-only IP addresses, no DNS
- `-U`: use Unix sockets
- `-p <port>`: forces use of the specified port

Opzioni solo client:
- `-s <ip_address>`: Forces the client to use the specified source IP address
- `-q <n>`: after EOF on stdin, wait n seconds and then quit. If n is negative, wait forever

#### Usi utili di netcat
```bash
# Use I/O redirection to send files over the network
@B: nc -l -p <port> > <new_filename>
@A: nc <ip-B> <port> < <filename>
# Use pipes to redirect the outputs of other commands
@B: nc -l -p <port> > <new_filename>
@A: cat <filename> | nc <ip-B> <port>
#Use pipes and archive tool tar to send also meta-data
@B: nc -l -p <port> | tar xz    #xz = extract and uncompress the archive
@A: tar cz <filename> | nc <ip-B> <port>    #cz = compress and create a new archive
#To reverse the situation (convenient if the recipient is under nat): si sincronizzano
@A: nc -q <n> -l -p <port> < <filename> #Il client apre la porta in ascolto e invia il file al server
@B: nc -q <n> <ip-A> <port> > <new_filename> #Il server si connette al client e riceve il file
```

### Mini example: file creation and transfer
```bash
#Create a file
dd if=/dev/urandom of=file.bin bs=1024 count=1024   #Create a 1MB file full of random bytes
ls -lh      #List the file with human-readable sizes
#-rw-r--r-- 1 root root 1.0M [...] file.bin

---------------------------------------------------------
#Copia file (fileA.bin) da A a B
@B:
nc -l -p 8080 | tar xzv &   #v=verbose, mostra i dettagli; &=background, comando in background
ss -ltn     #check that the server is listening

@A:
tar cz fileA.bin | nc 2.2.2.2 8080 -q1  #start the transfer from A

@B:
md5sum fileA.bin    #check the checksum of the received file

---------------------------------------------------------
#Copy file (fileB.bin) from B to A
@B: nc -l -p 8080 -c "tar cz fileB.bin" &   #put server to listen
@A: nc 2.2.2.2 8080 | tar xz    #start the transfer
@A: md5sum fileB.bin    #check the checksum of the received file
```



## **Esercizi**
### 1. Convert the previous examples of TCP-based communication using <u>UDP</u>

#### **Client/Server Application: C version + Python version**


Server
- Waits for connections
- Send welcome message: “Welcome from \<hostname>”

Client
- Connects to the server
- Receives string
- Stampa “Server name is: \<hostname>”


#### Utili in C
```C
#include <sys/socket.h>
#include <unistd.h>
int gethostname(char *name, size_t len); //Ottiene nome host
//Name = str pre-allocated, len = size of the str
```
```shell
man gethostname #su Linux for more details
```
```c
#include <string.h>
char* strcpy(char *dest, const char *src); //per manipolare le str
```

#### Utili in Python

```python
import socket
import os
hostname = socket.gethostname()  #Ottiene nome host

#Manipolare le str
str1 = 'blah string %s, int %d' %(mystr, myint) #Interpolation
str1 = str2+str3 #Concatenation
str1 = str2*3 #Repetition
str1 = f'{str2} blah' #formatting
```

#### SOLUTION C
L’esempio corretto usa UDP: il server riceve il messaggio del client oppure, se necessario, invia il proprio messaggio senza stabilire connessione, mentre il client invia il nome host e lo riceve in risposta. In particolare, il server inizializza il socket in modalità datagram, aspetta un datagramma, poi risponde con “Welcome from <hostname>”. Il client invia il proprio messaggio e stampa “Server name is: <hostname>”.

```c
// SERVER (UDP)
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>

int main(void) {
    int server_fd;
    struct sockaddr_in server_addr, client_addr;
    socklen_t client_len = sizeof(client_addr);
    char hostname[256];
    char buffer[256];
    char message[256];

    if (gethostname(hostname, sizeof(hostname)) != 0) {
        perror("gethostname");
        return 1;
    }

    server_fd = socket(AF_INET, SOCK_DGRAM, 0);
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(8080);

    bind(server_fd, (struct sockaddr *)&server_addr, sizeof(server_addr));

    recvfrom(server_fd, buffer, sizeof(buffer), 0,
             (struct sockaddr *)&client_addr, &client_len); // Receive hostname from client

    sprintf(message, "Welcome from %s", hostname); // Prepare welcome message
    sendto(server_fd, message, strlen(message), 0, // Send welcome message back to client
           (struct sockaddr *)&client_addr, client_len);

    close(server_fd);
    return 0;
}
```

```c
// CLIENT (UDP)
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>

int main(void) {
    int sock_fd;
    struct sockaddr_in server_address;
    socklen_t server_len = sizeof(server_address);
    char buffer[256] = {0};
    char hostname[256];
    char message[256];

    if (gethostname(hostname, sizeof(hostname)) != 0) {
        perror("gethostname");
        return 1;
    }

    sock_fd = socket(AF_INET, SOCK_DGRAM, 0);
    server_address.sin_family = AF_INET;
    server_address.sin_addr.s_addr = inet_addr("127.0.0.1");
    server_address.sin_port = htons(8080);

    strcpy(message, hostname);
    sendto(sock_fd, message, strlen(message), 0,
           (struct sockaddr *)&server_address, server_len); // Send hostname to server

    recvfrom(sock_fd, buffer, sizeof(buffer), 0,
             (struct sockaddr *)&server_address, &server_len); // Receive response from server

    printf("Server name is: %s\n", buffer + strlen("Welcome from ")); // Print the server name without the prefix
    close(sock_fd);
    return 0;
}
```

Il server UDP non usa `listen()` né `accept()`: si mette in ascolto con `bind()` e poi riceve datagrammi. Il client invia il nome host e riceve la risposta, stampando il nome del server nel formato richiesto.

#### SOLUTION PYTHON
```python
# SERVER (UDP)
import socket

hostname = socket.gethostname()
server = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
server.bind(("127.0.0.1", 8080))

msg, addr = server.recvfrom(1024)
response = f"Welcome from {hostname}".encode()
server.sendto(response, addr)
server.close()
```

```python
# CLIENT (UDP)
import socket

hostname = socket.gethostname()
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
server_addr = ("127.0.0.1", 8080)

sock.sendto(hostname.encode(), server_addr)
message, _ = sock.recvfrom(1024)
print(f"Server name is: {message.decode().removeprefix('Welcome from ')}")
sock.close()
```

In questo caso la comunicazione è UDP: non si stabilisce una connessione persistente, ma si scambiano datagrammi con `sendto()` e `recvfrom()`.


### Practical example: TCP client-server

#### Server side
```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <unistd.h>

int main(void) {
    int server_fd, client_fd;
    char buffer[256] = {0};
    struct sockaddr_in address;

    server_fd = socket(AF_INET, SOCK_STREAM, 0);
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(8080);

    bind(server_fd, (struct sockaddr *)&address, sizeof(address));
    listen(server_fd, 3);

    client_fd = accept(server_fd, NULL, NULL);
    recv(client_fd, buffer, 255, 0);
    printf("Received: %s\n", buffer);
    close(client_fd);
    close(server_fd);
    return 0;
}
```

#### Client side
```bash
# Example of a client command
nc localhost 8080
# then send a message from the terminal
```

### Online archiving
**Archive structure (it is an ar archive)**
- An archive header consisting of 8 bytes forming the string !<arch>\n. There is
always a single archive header, regardless of the number of files in the archive.


<u>For every file in the archive:</u>
- A header for each file, 60 bytes long, containing information about the following file
    - 16 bytes containing the file name followed by the / character (if the file name is
    shorter, the remaining characters are spaces. If the file has a longer name, the
    name is truncated)
    - 12 bytes representing the file’s last modification time, expressed in seconds and
    padded with spaces. You can use the 12-character “0          ”
    - 6 bytes representing the file’s UID (user ID). You can the sequence “0     ”
    - 6 bytes containing the file’s GID (group ID). You can the sequence “0     ”
    - 8 bytes with the file type and permissions (octal notation).
    You can use “644 ”, which represents the permissions u:rw, g:r, o:r
    - 10 bytes with the file size expressed in bytes. For example “321       ”. The
    actual file size must be used
    - File header terminator, consisting of the two ASCII characters “'” (0x60 in
    hexadecimal) and “\n” (0x0A in hexadecimal)
- The file contents
- A padding, only if the file size is odd, consisting of the \n character.

#### SOLUZIONE Python e C: Guarda file del prof
#### SOLUZIONE Bash:
```Bash
#!/bin/bash

ARCH=$$.ar #crea un nome di archivio temporaneo basato sul PID (Process ID) dello script
if [[ $# -lt 3 ]] #controlla se il numero di argomenti (escluso il nome dello script) passati allo script è inferiore a 3
then
    echo "usage $0 server port file1 [file2 ...]"
    exit 1
fi
SERVER=$1
PORT=$2
shift; shift #rimuove i primi due argomenti (server e porta) dalla lista degli argomenti, in modo che $* contenga solo i file da archiviare
ARGS=$*
ar rc $ARCH $ARGS #il comando crea un archivio con i file passati come argomenti
nc -q1 $SERVER $PORT < $ARCH #q1 opzione per chiudere la connessione dopo 1 secondo
rm -f $ARCH #rimuove il file temporaneo creato; -f opzione per forzare la rimozione senza chiedere conferma
```


> **Importante**: in questi casi *meglio usare sh*, che implementa già il concetto di archive, e non reinventare la ruota.


<br><br>

## **HTTP Protocol**
HTTP used communication **over TCP**, and it is a request-response protocol. The client sends a request to the server, which processes it and sends back a response. HTTP is **stateless**, meaning each request is independent of previous requests.
<br>

### **Request message HTTP**
```sh
GET /somedir/page.html HTTP/1.1 #Request line (GET, POST, PUT, DELETE, etc.)
#Header fields (key:value pairs)
Connection: close 
User-agent: Mozilla/4.0
Accept: text/html, image/gif, image/jpeg
Accept-language:fr
                        #Separator (carriage return and line feed)
#<body if exists>
```

**Request line:**
- Method: type of operation required by the client
    - GET: request for an object
    - POST: the client requires a web page whose content is specified by the user (e.g.
    request to a search engine) in the entity body field
    - HEAD: the client requires the server to send only the header of the answer without
    the object (used for debugging of web servers)
    - PUT: Send an object to the server
    - DELETE: Delete an object from the server
    - LINK, UNLINK (HTTP 1.0): Create or delete connections between server objects
    - TRACE, CONNECT, OPTIONS (HTTP 1.1): Identify the proxy server chain, Create connection, Request for supported methods.
- URL (location of the resource) (e.g. */somedir/page.html*)
- Version of the HTTP (e.g. *HTTP/1.1*)

**Header fields:**
+ `Connection`: type of connection requested by the client (persistent,
non-personal)
+ `User-Agent`: browser used by the user
+ `Accept`: type of objects that the client accepts
+ `Accept-Language`: language preference
+ `Accept-encoding`, `Accept-charset`: type of encoding and character set accepted by the client
+ `Host`: Host specification that has the resource (http 1.1)
+ Other headers to ensure the consistency of information (e.g., `If-Match` or `If-Modified-Since`)

>Nota: browser must send an explicit request message for each of the elements connected to the page

<br>

### **HTTP Response message**
A response HTTP includes:
- The content of the requested resource
- The identification of the version of the HTTP protocol
- The state code and the state information in textual form,
- A set of possible other response information

```sh
HTTP/1.1 200 OK #Status line (version, status code, reason phrase
#Header fields (key:value pairs)
Connection: close
Date: Thu, 06 Aug 1998 12:00:15 GMT
Server: Apache/1.3.0 (Unix)
Last-Modified: Mon, 22 Jun 1998
Content-Length: 6821
Content-Type: text/html

<Data...>
```
<br>

**Status line:**
- Version of the HTTP
- Status code: 3-digit integer indicating the result of the request
    + 1xx: information
    + 2xx: success
    + 3xx: redirection
    + 4xx: client error
    + 5xx: server error

**Header lines:**
+ `Connection:` type of connection used by the server
+ `Date:` date and time of the request
+ `Server:` type of web server and operating system
+ `Last-Modified:` Date and now creation or modification of the object (caching)
+ `Content-Lenghth:` in byte size of the object
+ `Content-Type:` Subject type (e.g. html, gif, ...)

<br>

### **HTTP protocol versions**
- Version 0.9
    + GET Method only
- Version 1.0
    + GET, HEAD, POST methods
    + Additional methods: PUT, DELETE, LINK, UNLINK
    + Non-persistent connections (1 request http → 1 TCP connection)
- Version 1.1
    + Removed methods LINK, UNLINK
    + Persistent connections for default (many HTTP requests in 1 TCP connection)
- Version 2.0
    + Request pipelining
    + Management of request priority
<br>
<br>

## ESEMPI HTTP Client - Server
### **HTTP Client in C**
```C
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

// Error handling function: prints error message and exits program
void error(char *msg) {
    perror(msg);
    exit(0);
}

int main(int argc, char *argv[]) {
    int sockfd, portno, n;
    struct sockaddr_in serv_addr;
    struct hostent *server;
    char buffer[256];

    // Validate command-line arguments
    // argv[1] should contain the URL path (e.g., "/index.html")
    if (argc < 2) {
        fprintf(stderr, "usage: %s URL\n", argv[0]);
        exit(0);
    }

    // ============ SOCKET CREATION ============
    // HTTP uses port 80 by default
    portno = 80;
    
    // Create a TCP socket (SOCK_STREAM for TCP, AF_INET for IPv4)
    sockfd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockfd < 0)
        error("ERROR opening socket");

    // ============ SERVER RESOLUTION ============
    // Resolve the hostname to IP address using DNS
    // gethostbyname() returns a struct with IP information
    server = gethostbyname("localhost");
    if (server == NULL) {
        fprintf(stderr, "ERROR, no such host\n");
        exit(0);
    }

    // ============ SERVER ADDRESS SETUP ============
    // Initialize server address structure to zero
    bzero((char *) &serv_addr, sizeof(serv_addr));
    
    // Configure address family (IPv4)
    serv_addr.sin_family = AF_INET;
    
    // Copy resolved IP address from gethostbyname() result
    bcopy((char *)server->h_addr,
          (char *)&serv_addr.sin_addr.s_addr,
          server->h_length);
    
    // Set port number in network byte order (big-endian)
    serv_addr.sin_port = htons(portno);

    // ============ CONNECTION ESTABLISHMENT ============
    // Establish TCP connection to remote server
    // This is a blocking call - it waits until connection is established or fails
    if (connect(sockfd,
                (const struct sockaddr *) &serv_addr,
                sizeof(serv_addr)) < 0)
        error("ERROR connecting");

    // ============ HTTP REQUEST SENDING ============
    // Clear buffer before building request
    bzero(buffer, 256);
    
    // Build HTTP GET request with proper format
    // \r\n = carriage return + line feed (HTTP line terminator)
    // Empty line at end signals end of headers
    sprintf(buffer, "GET %s HTTP/1.1\r\nHost: localhost\r\n\r\n", argv[1]);
    
    // Send request to server
    n = write(sockfd, buffer, strlen(buffer));
    if (n < 0)
        error("ERROR writing to socket");

    // ============ HTTP RESPONSE READING ============
    // Clear buffer to receive response
    bzero(buffer, 256);
    
    // Read response from server (max 255 bytes)
    // Note: In real scenarios, use a loop to read all data
    n = read(sockfd, buffer, 255);
    if (n < 0)
        error("ERROR reading from socket");
    
    // Display server response to user
    printf("%s\n", buffer);
    
    // ============ CLEANUP ============
    // Close socket and free resources
    close(sockfd);
    
    return 0;
}
```

### **HTTP Server in Python v1.0**
```Python
#!/usr/bin/env python3
import socket
import os
import sys
HOST = '127.0.0.1' # Standard loopback interface address
PORT = 8080 # Port to listen on

def send_dummy_response(conn, url):
    """
    Constructs and sends an HTTP response to the client.
    
    Args:
        conn: socket connection object
        url: requested URL path (from client request)
    """
    # Create simple HTML body with the requested URL
    body = '<html><body><h1>Requested: %s</h1></body></html>' % url
    
    # Build HTTP response with proper headers
    # Status line: HTTP/1.0 200 OK
    # Headers: Connection type, Content-Type, Content-Length
    # Empty line separates headers from body
    resp = ('HTTP/1.0 200 OK\r\n' +
            'Connection: close\r\n' +
            'Content-Type: text/html\r\n' +
            'Content-Length: %d\r\n\r\n' % len(body) + body)
    
    # Send response to client (encode string to bytes)
    conn.sendall(resp.encode('utf-8'))
    
    # Simulate some server processing time
    time.sleep(1)

# ============ HELPER FUNCTION: PARSE HTTP REQUEST ============
def parse_request(conn):
    """
    Reads and parses HTTP request from client.
    Extracts the requested URL path.
    
    Args:
        conn: socket connection object
        
    Returns:
        url: the requested URL path
    """
    request = ''
    
    # Read request data until we find the end marker (empty line)
    # HTTP requests end with \r\n\r\n (carriage return + line feed)
    while True:
        request += conn.recv(1024).decode('utf-8')
        # Check if we've received the complete HTTP header
        if request.find('\r\n\r\n') > 0:
            break
    
    # Split request line from headers
    reqline, headers = request.split('\r\n', 1)
    
    # Parse request line: "GET /path HTTP/1.1"
    # method = HTTP verb (GET, POST, etc.)
    # url = requested path
    # version = HTTP version
    method, url, version = reqline.split(' ', 2)
    
    return url

# ============ HELPER FUNCTION: HANDLE CLIENT CONNECTION ============
def serve_request(conn):
    """
    Processes a single client request:
    1. Parse the incoming HTTP request
    2. Send an HTTP response
    3. Close the connection
    
    Args:
        conn: socket connection object
    """
    # Parse incoming request and extract URL
    url = parse_request(conn)
    
    # Display requested URL for debugging
    print(url)
    
    # Send HTTP response to client
    send_dummy_response(conn, url)
    
    # Close the connection
    conn.close()

# ============ MAIN: SERVER INITIALIZATION ============
# Use 'with' statement for automatic resource cleanup
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    # Bind socket to the specified address and port
    s.bind((HOST, PORT))
    
    # Listen for incoming connections
    # This puts the socket in passive listening mode
    s.listen()
    
    # Accept a single connection (non-parallel version)
    # In production, use threading or async for multiple clients
    conn, addr = s.accept()
    
    # Process the client request
    serve_request(conn)
```
**Verification of operation:**
Point your browser to the url: http://localhost:8080/pag1.html


### **HTTP Server in Python v2.0**
```Python
# main
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen()
    # sequential version:
    while True:
        conn, addr = s.accept()
        serve_request(conn)
```

### **HTTP Server in Python v2.1**
Version with fork()
```Python
# main
with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen()
    # fork version:
    while True:
        conn, addr = s.accept()
        child_pid=os.fork()
        if child_pid==0:
            serve_request(conn)
            sys.exit()
        else: conn.close()
```

### **HTTP Server in Python v3.0**
Version with fork()
```Python
#!/usr/bin/env python3
import socket
import os
import sys
HOST = '127.0.0.1' # Standard loopback interface address
PORT = 8080 # Port to listen on

HTDOCS = './htdocs' # Root of Web documents
MIMETYPES=[
    ('.gif', 'image/gif'),
    ('.png', 'image/png'),
    ('.jpg', 'image/jpeg'),
    ('.html', 'text/html'),
]

#New version of send_response() function
    #• Called instead of send_dummy_response()
    #• File presence check
    #• Response code 200/404
def send_response(conn, url):
    doc_root = HTDOCS
    fname = doc_root + url
    if not os.path.exists(fname):
        print('file %s not found' % fname)
        send_404(conn, url)
    else:
        print('sending file %s' % fname)
        send_200(conn, fname)

#Based on send_dummy_response()
# 404 answer
def send_404(conn, url):
    body='<html><body><h1>%s Not Found!</h1></body></html>' % url
    resp='HTTP/1.0 404 Not Found\r\n' + \
        'Connection: close\r\n' + \
        'Content-Type: text/html\r\n' + \
        'Content-Length: %d\r\n\r\n' % len(body) + body
    conn.sendall(resp.encode('utf-8'))
    time.sleep(1)

# 200 Answer
def send_200(conn, fname):
    header = 'HTTP/1.0 200 OK\r\n' + \
        'Connection: close\r\n' + \
        'Content-Length: %d\r\n' % os.path.getsize(fname) + \
        'Content-Type: %s\r\n\r\n' % get_mime(fname)
    conn.sendall(header.encode('utf-8'))
    with open(fname, 'rb') as f:
        l = f.read(1024)
        while (l):
            conn.send(l)
            l = f.read(1024)
    time.sleep(1)

# MIME types
def get_mime(fname):
    mime = 'text/plain' # default
    for ext, mimetype in MIMETYPES:
        if fname.endswith(ext):
            mime = mimetype
            break
    return mime
```
### Pag1.html
```HTML
<!-- Example HTML file to be served -->

<html>
    <head><title>Sample page</title></head>
    <body>
        <h1>Sample page</h1>
        <ul>
            <li><a href="pag2.html">A link to a page.</a></li>
            <li><a href="dangling_link.html">
                A missing link.</a></li>
        </ul>
    </body>
</html>
```

<br><br>

## **SMTP Protocol**
Usato per l’invio di email, è un protocollo di tipo **push** (il client invia i messaggi al server) e **stateful** (la connessione tra client e server rimane aperta fino a quando il client non termina la sessione). Il protocollo SMTP utilizza la **porta 25** per le comunicazioni.

**La comunicazione avviene così:** Il client SMTP invia i messaggi al server SMTP, che a sua volta li inoltra al server SMTP del destinatario. Il server SMTP del destinatario consegna il messaggio alla casella di posta del destinatario.

<u>Three phases of the transfer:</u>
1. Handshaking (SMTP greetings /= TCP handshaking)
2. Message transfer
3. Closing phase

<br>
    
**SMTP session commands**

```html
|Name|      |Format|                      |Description|
HELO  ->  HELO <domain>\r\n            Identification of sender
MAIL  ->  MAIL FROM: <sender>\r\n      Identify the sender
RCPT  ->  RCPT TO: <recipient>\r\n     Identifies the recipient
DATA  ->  DATA\r\n                     The transmission begins
RSET  ->  RSET\r\n                     Abort the transaction
NOOP  ->  NOOP\r\n                     No Operation
QUIT  ->  QIOT\r\n                     Closes the TCP connection
SEND  ->  SEND FROM: <sender>\r\n      Send email to terminal
SOML  ->  SOML FROM: <sender>\r\n      Send email to terminal if possible, else to Mailbox
SAML  ->  SAML FROM: <sender>\r\n      Send email to terminal and to the Mailbox
VRFY  ->  VRFY <string>\r\n            Verify user name
EXPN  ->  EXPN <string>\r\n            Reports belonging to one mailing list
HELP  ->  HELP\r\n                     Send system documentation
TURN  ->  TURN\r\n                     Exchange the Sennder and Receiver roles
```
<br>

**SMTP status codes**
```html
  |Code|      |Meaning|
    211 System status/system help reply
    214 Help message (manual page, for a person)
    220 <domain> service ready
    221 <domain> service closing transmission channel
    250 Requested mail action ok, completed
    251 User not local; will forward to <recipient>
    354 Start mail input; end with\r\n
    421 <domain>Service not avilable, losing transmission channel
    450 Requested mail action not taken; mailbox unavailable (eg.: busy)
    451 Requested action not taken: insufficient system storage
    500 Syntax error, command unrecognized
    501 Syntax error in parameter or arguments
    502 Comand not implemented
    503 Bad sequence of commands
    504 Command parameter not implemented
    550 Requested mail action not taken: mailbox unavailable (not found)
    551 User not local; please try <recipient>
    552 Requested action aborted: eceeded storage allocation
    553 Requested action aborted: mailbox name not allowed (eg.: syntax error)
    554 Transaction failed

```

> Nota: Il **client SMTP invia i comandi al server SMTP, che risponde con un codice di stato** e un messaggio di testo. Il client interpreta il codice di stato ricevuto e decide se continuare o terminare la sessione. I codici di stato sono numeri a tre cifre, dove la prima cifra indica il tipo di risposta (2xx = successo, 4xx = errore temporaneo, 5xx = errore permanente).

<br>

### **Mail message format** = header (*coded fields*) + body (*7-bit ASCII text*)
```html
|Header|                                 |Description|
Subject: <subject>\r\n                  Subject of the email
From: <sender>\r\n                      Sender's email address
To: <recipient>\r\n                     Recipient's email address
Date: 12/12/2021, 18:25\r\n             Date and time of the email (optional)
Reply-to: direttore.deif@unimore.it     Reply-to address (if /= sender) (optional)
other headers (optional)\r\n            Additional headers (e.g. CC, BCC...)
\r\n                                    Blank line separating header from body
|Body|  
The body of the email message, which can contain text, HTML, or attachments. The body can be multiple lines and is terminated by a line containing only a single dot (\r\n.\r\n).
```

>Nota: Il body può contenere diversi dati, ma deve essere codificato in 7-bit ASCII. Some strings of characters are not allowed in the message (e.g., \r\n.\r\n)


#### **Try SMTP:**
```bash
$ nc -C servername 25 #servername = remote email server address 
#Es. $ nc -C localhost 25 ?

#Esempio:
S: 220 mail.ucla.edu
C: HELO mail.unimo.it 
S: 250 Hello mail.unimo.it, pleased to meet you
C: MAIL FROM: <alice@mail.unimo.it>
S: 250 alice@mail.unimo.it ... Sender ok
C: RCPT TO: <bob@mail.ucla.edu>
S: 250 bob@mail.ucla.edu ... Recipient ok
C: DATA
S: 354 Enter mail, end with "." on a line by itself
C: Do you like computer science books?
C: How about journals?
C: .
S: 250 Message accepted for delivery
C: QUIT
S: 221 mail.ucla.edu closing connection
```
<br>

### **SMTP Client**
Esempio con netcat (nc)
```sh
ss -ntlp | grep 25 #check if the SMTP server is running on port 25
nc -C localhost 25 
HELO localhost
MAIL FROM: <riccardo@localhost>
RCPT TO: <riccardo@localhost>
DATA
From: ricardo <riccardo@localhost>
To: ricardo <riccardo@localhost>
Subject: prova
Test message
.
QUIT
```

Response code
+ GET → 250
+ MAIL → 250
+ RCPT → 250
+ DATA → 354
+ End message (`\r\n.\r\n`) → 250
+ QUIT → 221

#### **Client SMTP in Python**
```python
#!/usr/bin/env python3
import socket
import os
import sys
import time
HOST = '127.0.0.1' # (localhost)
PORT = 25 # Port to connect to

def expect_response(s: str, exp_code: str):
    """
    Checks if the response from the server matches the expected code.
    Args:
        s: The response string received from the server.
        exp_code: The expected 3-digit response code as a string.
    """
    data = s.splitlines() #La risposta può essere multilinea, quindi splitto le linee
    for l in data:
        print(l)
    # data[last_line] -> response
    rv = data[-1][0:3] #Prendo solo il codice
    if rv != exp_code:
        print('recv: "%s" instead of "%s"'%(rv, exp_code))
        sys.exit()

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((HOST, PORT))
    # Receive welcome message
    expect_response(s.recv(1024).decode('ascii'), '220') #chek welcome response
    # send HELO message
    s.sendall('HELO localhost\r\n'.encode('ascii'))
    expect_response(s.recv(1024).decode('ascii'), '250') #check HELO response
    # send MAIL envelope
    s.sendall('MAIL FROM: <riccardo@localhost>\r\n'.encode('ascii'))
    expect_response(s.recv(1024).decode('ascii'), '250') #check MAIL response
    s.sendall('RCPT TO: <riccardo@localhost>\r\n'.encode('ascii')) 
    expect_response(s.recv(1024).decode('ascii'), '250') #check RCPT response

    # send MAIL message (RFC822)
    s.sendall('DATA\r\n'.encode('ascii'))
    expect_response(s.recv(1024).decode('ascii'), '354') #check DATA response
    s.sendall('From: riccardo <riccardo@localhost>\r\n'\
            'To: riccardo <riccardo@localhost>\r\n'\
            'Subject: prova\r\n\r\n'\
            'Messaggio di prova\r\n.\r\n'.encode('ascii'))
    expect_response(s.recv(1024).decode('ascii'), '250') #check end message response
    # Submit message
    s.sendall('QUIT\r\n'.encode('ascii'))
    expect_response(s.recv(1024).decode('ascii'), '221') #check QUIT response

```
Test: 
+ `./python3 SMTPclient.py`
+ Check mail
+ Traffic analysis with `wireshark`

<br>

### **SMTP Server**

**Setup:** <br>
Working on port 2525
- No special privileges requried
- More comvenient and safe

Very simple version of the server
- Focus on SMTP
- Possible to expand the SW with support for concurrent requests
- Disclaimer: Very simple and non-robust code

#### **SMTP Server in Python**
```python
#!/usr/bin/env python3
import socket
import socket
import sys
import time
import re

HOST = '127.0.0.1' # Standard loopback interface (localhost)
PORT = 2525 # Port to listen on (non-privileged ports are > 1023)

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen()
    conn, addr = s.accept()
    process_mail_request(conn)
    time.sleep(1)

def process_mail_request(conn):
    """
    Processes the SMTP mail request from the client.
        • State stored in message structure
        • Requires other command functions (process_mail_command, add_msg_body, send_response)
    Args:
        conn: The socket connection object for the client.
    """
    # send welcome message
    send_response(conn, '220', msg='Welcome from tinySMTP')
    msg = {}
    rv = process_mail_command(conn, conn.recv(1024), msg)
    # process commands, end when receiving QUIT
    while rv != 'QUIT':
        rv = process_mail_command(conn, conn.recv(1024), msg)
        if rv == 'DATA':
            while not add_msg_body(conn.recv(1024), msg): pass
            send_response(conn, '250', msg='Data received')

def process_mail_command(conn, data, msg):
    """
    Processes a single SMTP command from the client.
    Args:
        conn: The socket connection object for the client.
        data: The raw data received from the client.
        msg: A dictionary to store message state and information.
    Returns:
        The command string (e.g., 'HELO', 'MAIL', 'RCPT', 'DATA', 'QUIT') received from the client.
    """ 
    if data is not None:
        cmd=data[0:4].decode('ascii')
        param=data[5:-1].decode('ascii').strip()
        print('Mail command: cmd="%s", param="%s"'%(cmd, param))
        if cmd == 'QUIT': process_quit(conn, msg, msg='Goodbye')
        if cmd == 'HELO': send_response(conn, '250')
        if cmd == 'MAIL': process_envelope(conn, msg, cmd, param)
        if cmd == 'RCPT': process_envelope(conn, msg, cmd, param)
        if cmd == 'DATA': send_response(conn, '354')
        return cmd

def send_response(conn, code, msg=''):
    """
    Sends an SMTP response to the client.
    Args:
        conn: The socket connection object for the client.
        code: The 3-digit response code as a string.
        msg: The optional message text to include in the response.
    """
    resp=f'{code} {msg}\r\n'
    print('response is "%s"' % resp.splitlines()[0])
    conn.sendall(resp.encode('ascii'))

def process_envelope(conn, msg, cmd, param):
    """
    Processes the MAIL and RCPT commands to set the envelope sender and recipient.
    Args:
        conn: The socket connection object for the client.
        msg: A dictionary to store message state and information.
        cmd: The command string ('MAIL' or 'RCPT').
        param: The parameter string containing the email address.
    """
    if cmd == 'MAIL':
        m=re.search('FROM: <(.+)>', param) #regular expression to extract the sender email address)
        msg['from'] = m.group(1) #group(1) contains the email address matched by the regex
        print('add envelope sender %s' % msg['from'])
        send_response(conn, '250', msg='Sender OK')
    if cmd == 'RCPT':
        m=re.search('TO: <(.+)>', param) #regular expression to extract the recipient email address
        msg['to'] = m.group(1) 
        print('add envelope recipient %s' % msg['to'])
        send_response(conn, '250', msg='Recipient OK')

def add_msg_body(data, msg):
    """
    Adds the body of the email message to the message dictionary.
    Args:
        data: The raw data received from the client.
        msg: A dictionary to store message state and information.
    Returns:
        True if the end of the message body has been reached (indicated by a line containing only a single period),
        False otherwise.
    Invocation within a loop
    """
    data=data.decode('ascii')
    if 'rfc822' not in msg.keys(): msg['rfc822']=''
    msg['rfc822'] += data
    m=re.search('\r\n.\r\n', data)
    print('adding data: "%s", rv: %r' % (data, bool(m)))
    return bool(m)

def process_quit(conn, msg):
    """
    Processes the QUIT command from the client, indicating the end of the SMTP session.
    Args:
        conn: The socket connection object for the client.
        msg: A dictionary to store message state and information.
    """
    print('submitting message %s', msg)
    send_response(conn, '221')

```

Test:
+ `./python3 SMTPserver`
+ `./python3 SMTPclient`
+ Output analysis
+ Traffic analysis with `wireshark`