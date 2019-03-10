package kms

import (
	"github.com/hashicorp/vault/api"
	"log"
)

type vaultClient struct {
	C *api.Client
}

var Instance *vaultClient

func GetClient() *vaultClient{
	if Instance == nil {
		cl,_ := api.NewClient(&api.Config{
			Address: "http://192.168.150.2:8200",
		})
		cl.SetToken("s.3SO99yIwRK7jOOc1BWfwVOuk")
		return &vaultClient{
			C: cl,
		}
	}
	return Instance
}

func (clt vaultClient) Get(ref string) (*api.Secret, error){
	secret, err := clt.C.Logical().Read(ref)
	if err != nil {
		log.Println(err.Error())
	}
	return secret, err
}

func (clt vaultClient) store(key ,content, name string ) (string, error){
	_, err := clt.C.Logical().Write(key, map[string]interface{}{
		"content": content,
		"name": name,
	})
	return key, err
}