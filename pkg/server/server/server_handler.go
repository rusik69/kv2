package server

import (
	"io"
	"net"

	"github.com/sirupsen/logrus"
)

// ServerHandler is the main server handler.
func (s *Server) ServerHandler(conn net.Conn) {
	logrus.Println("server handler")
	for {
		respBody := make([]byte, 1024)
		_, err := conn.Read(respBody)
		if err == io.EOF {
			continue
		}
		if err != nil {
			logrus.Errorln(err)
			break
		}
		var c Command
		err = c.parseCmd(respBody)
		if err != nil {
			logrus.Errorln(err)
			conn.Write([]byte(err.Error()))
			break
		}
		switch c.Cmd {
		case "set":
			err = s.Set(c)
			if err != nil {
				logrus.Errorln(err)
				conn.Write([]byte(err.Error()))
				continue
			} else {
				conn.Write([]byte("OK"))
				continue
			}
		case "get":
			value, err := s.Get(c)
			if err != nil {
				logrus.Println(err)
				conn.Write([]byte(err.Error()))
				continue
			} else {
				conn.Write(value)
				continue
			}
		case "del":
			err = s.Del(c)
			if err != nil {
				logrus.Errorln(err)
				conn.Write([]byte(err.Error()))
				continue
			} else {
				conn.Write([]byte("OK"))
				continue
			}
		case "addnode":
			err = s.AddNode(c, false)
			if err != nil {
				logrus.Errorln(err)
				conn.Write([]byte(err.Error()))
				continue
			} else {
				conn.Write([]byte("OK"))
				continue
			}
		case "id":
			conn.Write([]byte(s.id))
		default:
			conn.Write([]byte("unknown command " + c.Cmd))
			logrus.Errorln("unknown command", c.Cmd, len(c.Cmd))
		}
	}
	return
}
