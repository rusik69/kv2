package main

import (
	"github.com/rusik69/kv2/pkg/client/argparse"
	"github.com/rusik69/kv2/pkg/client/client"
	"github.com/rusik69/kv2/pkg/client/interactive"
)

func main() {
	argparse.ArgsInstance.Parse()
	client.ClientInstance.Init(argparse.ArgsInstance)
	client.ClientInstance.Connect()
	interactive.Loop()
	return
}
