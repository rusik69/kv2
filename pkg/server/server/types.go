package server

import (
	"net"
	"sync"

	"github.com/rusik69/kv2/pkg/client/client"
)

// Server is the main server struct.
type Server struct {
	id               string
	listenPortClient string
	listenPortServer string
	listenHost       string
	listenerServer   net.Listener
	listenerClient   net.Listener
	wg               sync.WaitGroup
	kv               map[string]int64
	nodes            map[string]client.Client
	nodeNames        [][]string
	replicas         int
	memLimit         uint64
	memUsage         uint64
	debug            bool
	mutex            sync.RWMutex
	stateDir         string
}

// ServerInstance is the main server instance.
var ServerInstance Server

// Command struct
type Command struct {
	Cmd   string
	Key   string
	Value []byte
}
