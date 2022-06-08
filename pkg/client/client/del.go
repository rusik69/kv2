package client

import (
	"errors"
	"fmt"
)

func (c *Client) Del(key string) error {
	_, err := c.Conn.Write([]byte("del " + key))
	if err != nil {
		return err
	}
	respBody := make([]byte, 2)
	_, err = c.Conn.Read(respBody)
	if err != nil {
		return err
	}
	if string(respBody) != "OK" {
		return errors.New("server error : " + err.Error())
	}
	fmt.Println("5")
	return nil
}
