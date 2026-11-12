#include <sys/socket.h>
#include <netinet/in.h>
#include <cstdlib>
#include <iostream>
#include <unistd.h>
#include <vector>

int main()
{

  int sockfd = socket(AF_INET, SOCK_STREAM, 0);
  if (sockfd == -1)
  {
    std::cout << "Failed to create socket. errno: " << errno << std::endl;
    exit(EXIT_FAILURE);
  }

  int reuse = 1;
  if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse)) < 0)
  {
    perror("setsockopt");
    exit(EXIT_FAILURE);
  }

  sockaddr_in sockaddr;
  sockaddr.sin_family = AF_INET;
  sockaddr.sin_addr.s_addr = INADDR_ANY;
  sockaddr.sin_port = htons(9999);
  if (bind(sockfd, (struct sockaddr *)&sockaddr, sizeof(sockaddr)) < 0)
  {
    std::cout << "Failed to bind to port 9999. errno: " << errno << std::endl;
    exit(EXIT_FAILURE);
  }

  if (listen(sockfd, 10) < 0)
  {
    std::cout << "Failed to listen on socket. errno: " << errno << std::endl;
    exit(EXIT_FAILURE);
  }

  auto addrlen = sizeof(sockaddr);

  while (true)
  {
    int connection = accept(sockfd, nullptr, nullptr);
    if (connection < 0)
      continue;

    std::cout << "Client connected!" << std::endl;

    char buffer[1024];

    while (true)
    {
      ssize_t bytesRead = read(connection, buffer, sizeof(buffer));

      if (bytesRead <= 0)
      {
        break;
      }

      std::cout << "Incoming: ";
      std::cout.write(buffer, bytesRead);
      std::cout << std::endl;

      std::string response = "Good talking to you\n";
      send(connection, response.c_str(), response.size(), 0);
    }

    std::cout << "Client disconnected!" << std::endl;

    close(connection);
  }
}
