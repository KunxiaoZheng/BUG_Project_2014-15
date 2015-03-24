/*
 * SocketModule.h
 *
 *  Created on: 2015-03-13
 *      Author: Andrew Fleck
 */

#ifndef SOCKETMODULE_H_
#define SOCKETMODULE_H_

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <unistd.h>
#include <string>
#include <arpa/inet.h>
#include <iostream>
#include <fcntl.h>

#define MAXRECEIVE 256
#define MAXCONNECTIONS 256
#define DEFAULT_IP "127.0.0.1"
#define DEFAULT_PORT 1111

using namespace std;
class SocketModule{

 public:

  SocketModule();

  virtual ~SocketModule();

  //create server USocket
  bool createsocket();

  //bind server socket to a port
  bool bind ( const int port );

  //server listen to socket
  bool listen() const;

  //accept connection from client
  bool accept ();

  //client initialize and connect to server
  bool connectclient(string host, int port);

  //send string to socket
  bool sendmsg ( string msg );

  //receive string from socket
  int receivemsg ();

  //send file to socket
  bool sendfile();

 private:

  int m_listensd,m_acceptsd;
  struct sockaddr_in m_addr;
  string m_msg;

};


#endif /* SOCKETMODULE_H_ */


