package argparse

import "flag"

// Parse the command line arguments.
func (a *Args) Parse() {
	var hostFlag = flag.String("h", "localhost", "server hostname")
	var portFlag = flag.String("p", "6969", "server port")
	var filesPortFlag = flag.String("f", "6971", "fileserver port")
	flag.Parse()
	a.ServerHost = *hostFlag
	a.ServerPort = *portFlag
	a.ServerFilesPort = *filesPortFlag
	return
}
