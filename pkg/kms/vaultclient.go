package kms

import (
	"github.com/hashicorp/vault/api"
	"log"
	"os"
	"strings"
)

type vaultClient struct {
	C *api.Client
}

var Instance *vaultClient

func GetClient() *vaultClient{
	if Instance == nil {
		// os.Setenv("CRYPTOGEN_VAULT_URL", "http://192.168.150.2:8200")
		// os.Setenv("CRYPTOGEN_VAULT_TOKEN", "s.3SO99yIwRK7jOOc1BWfwVOuk")
		// os.Setenv("CRYPTOGEN_VAULT_SHARD", "cb438319dbdf8107773c881e3a218c43f40dc64bff1f72943aab7fb0f8b0dac6")
		cl,_ := api.NewClient(&api.Config{
			Address: os.Getenv("CRYPTOGEN_VAULT_URL"),
		})
		cl.SetToken(os.Getenv("CRYPTOGEN_VAULT_TOKEN"))

		cl.Sys().Unseal(strings.TrimSpace(os.Getenv("CRYPTOGEN_VAULT_SHARD")))
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