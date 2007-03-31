#include <stdio.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/termios.h>

int main( int argc, char** argv )
{
  if( argc != 2 )
    {
      printf( "usage: serial [file]\n" );
      return -1;
    }

  char* file = argv[1];
  printf( "opening file %s\n", file );
  int fd = open(file, O_RDWR | O_NOCTTY | O_NDELAY );

  if( fd == -1 )
    {
      perror("could not open file");
      return -1;
    }

  struct termios term_p;
  cfsetispeed( &term_p, B38400 );
  cfsetispeed( &term_p, B38400 );
  
  term_p.c_cflag |= (CLOCAL | CREAD);
  term_p.c_cflag &= ~PARENB;
  term_p.c_cflag &= ~CSTOPB;
  term_p.c_cflag &= ~CSIZE;
  term_p.c_cflag |= CS8;
  term_p.c_cflag |= CRTSCTS;

  term_p.c_lflag &= ~(ICANON | ECHO | ECHOE | ISIG);

  term_p.c_iflag |= (INPCK | ISTRIP);

  term_p.c_oflag &= ~OPOST;

  if( tcsetattr(fd, TCSANOW, &term_p) == -1 )
    {
      perror("tcsetattr failed");
      return -1;
    }

  char buf[2];
  int size = 0;

  fcntl( fd, F_SETFL, 0 );

  while( size = read( fd, buf, 1 ) >= 0 )
    {
      buf[1] = 0;
      printf( "%c", buf[0] );
      fflush( 0 );
    }

  printf("read error %d %s\n", errno, strerror(errno));

  return 0;
}
