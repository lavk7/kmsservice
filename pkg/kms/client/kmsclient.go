package client

type KMSClient interface {
	Store(data map[string][]string)
	Get(ref string)
}