/*
 * USocketModule.cpp
 *
 *  Created on: 2015-03-13
 *      Author: andrew
 */

#include "SocketModule.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <fstream>
#include <iomanip>
#include <iostream>

using namespace std;


int printstatus(string statusmsg){
	cout << "Status Message " << statusmsg << endl;
	return 0;
}

SocketModule::SocketModule() :   m_listensd(-1), m_acceptsd(-1){
	memset (&m_addr, 0, sizeof(m_addr));
}

SocketModule::~SocketModule(){
	::close (m_listensd);
	::close (m_acceptsd);
}

bool SocketModule::createsocket(){

	//create socket descriptor
	if ((m_listensd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)) < 0){
		printstatus("createserver::Failed to create TCP stream socket.\n");
		return false;
	}else{
		printstatus("createserver::created TCP stream socket");
		return true;
	}
}

bool SocketModule::bind (const int port){

  m_addr.sin_family = AF_INET;
  m_addr.sin_addr.s_addr = htonl(INADDR_ANY);
  m_addr.sin_port = htons (port);

  //example from exampleserver
  //rc = bind(listen_sd, (struct sockaddr *)&addr, sizeof(addr));


  if(::bind(m_listensd,(struct sockaddr*)&m_addr,sizeof(m_addr)) < 0){
	  printstatus("bind failed");
      return false;
    }
  printstatus("bind success");
  return true;
}

bool SocketModule::listen() const{

	if(::listen ( m_listensd, 5 ) < 0){
		printstatus("listen failed");
		return false;
    }else{
    	printstatus("listen success");
    	return true;
    }
}

bool SocketModule::accept(){
	int addr_length = sizeof(m_addr);
	if((m_acceptsd = ::accept(m_listensd, (sockaddr*)&m_addr, (socklen_t*) &addr_length )) < 0 ){
		printstatus("accept() failure");
		return false;
	}else{
		printstatus("accept() success");
		return true;
	}
}

bool SocketModule::sendmsg (string msg){
  int status;
  if ((status = ::send (m_acceptsd, msg.c_str(), msg.size(), MSG_NOSIGNAL))==-1){
	  return false;
  }else{
	  std::cout << "send " << status << "characters\n";
	  std::cout << msg << "sent\n";
	  return true;
  }
}

int SocketModule::receivemsg (){
	char buf [ MAXRECEIVE + 1 ];
	m_msg = "";

	memset ( buf, 0, MAXRECEIVE + 1 );

	long int status;

	//checking on status of the read
	if ((status = recv( m_acceptsd, &buf, MAXRECEIVE,0))== -1 ){
		printstatus("SocketModule::receivemsg recv() failed\n");
		return 0;
    }
	else if ( status == 0 ){
		printstatus("SocketModule::receivemsg recv() failed\n");
		return 0;
    }
	else{
		printstatus("SocketModule::receivemsg recv() success\n");
      m_msg = buf;
      printstatus("received message: ");
      printstatus(m_msg);
      return status;
    }
}

bool SocketModule::connectclient ( const string host, const int port ){

	m_addr.sin_family = AF_INET;
	m_addr.sin_addr.s_addr = htonl(INADDR_ANY);
	m_addr.sin_port = htons(port);

	if(::inet_pton ( AF_INET, host.c_str(), &m_addr.sin_addr) != 1){
		return false;
	}

	// returns false if connect() fails
	if ( (::connect(m_sockfd,(sockaddr*) &m_addr,sizeof(m_addr))) < 0 ){
		printstatus("client connect() failed");
		return false;
	}else{
		printstatus("client connect() succeeded");
		return true;

	}
}

bool sendfile(){
	return false;
}
