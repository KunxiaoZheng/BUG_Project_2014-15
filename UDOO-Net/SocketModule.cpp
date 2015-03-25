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

SocketModule::SocketModule(){
	m_serverbool=-1;
	m_listensd=-1;
	m_connectionsd=-1;
	memset (&m_addr, 0, sizeof(m_addr));
}

SocketModule::~SocketModule(){
	//::close (m_listensd);
	//::close (m_acceptsd);
}

bool SocketModule::createserver(int port){

	if (m_serverbool == -1)	m_serverbool=1;

	//create socket descriptor
	if (m_serverbool==1){
		if ((m_listensd = socket(AF_INET, SOCK_STREAM, 0)) < 0){
			printstatus("createserver::Failed to create TCP stream socket.\n");
				return false;
		}else{
			printstatus("createserver::created TCP stream socket");
		}

		bind(port);
		listen();
		accept();
		return 1;
	}else
	return 0;

}

bool SocketModule::connectclient ( string host, int port ){
	if (m_serverbool==-1) m_serverbool = 0;

	if (m_serverbool==0){

		if ((m_connectionsd = socket(AF_INET, SOCK_STREAM, 0)) < 0){
			printstatus("connectclient::Failed to create TCP stream socket.\n");
			return false;
		}else{
			printstatus("connectclient::created TCP stream socket");
		}

	m_addr.sin_family = AF_INET;
	m_addr.sin_port = htons(port);

	if(::inet_pton ( AF_INET, host.c_str(), &m_addr.sin_addr) != 1){
		printstatus("connectclient::inet_pton failed");
		return false;
	}


	// returns false if connect() fails
	if ( (::connect(m_connectionsd,(struct sockaddr*) &m_addr,sizeof(m_addr))) < 0 ){
		printstatus("client connect() failed");
		return false;
	}else{
		printstatus("client connect() succeeded");
		return true;

	}
}

	printstatus("client connect() succeeded");
	return false;
}


bool SocketModule::bind (const int port){

  m_addr.sin_family = AF_INET;
  m_addr.sin_addr.s_addr = htons(INADDR_ANY);
  m_addr.sin_port = htons (port);

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
	socklen_t addrlen = sizeof(m_addr);
	m_connectionsd = ::accept(m_listensd, (struct sockaddr*)&m_addr, &addrlen );
	if(m_connectionsd < 0 ){
		printstatus("accept() failure");
		return false;
	}else{
		printstatus("accept() success");
		return true;
	}
}

//server and client
bool SocketModule::sendmsg (string msg){
  int status;

  	  status = ::send (m_connectionsd, msg.c_str(), msg.size(), 0);
  	  if (status == -1){
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

	int status;

	//checking on status of the read
	status = recv( m_connectionsd, &buf, MAXRECEIVE,0);
	if (status == -1){
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


bool sendfile(){
	return false;
}
