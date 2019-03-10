package kms

import (
	"net/http"
)

type Route struct {
	Name string
	Pattern string
	Handler http.HandlerFunc
	Methods string
}

func GetRoutes() []*Route {
	route := []*Route{
		&Route{
			Name:    "Store",
			Pattern: "/store",
			Handler: StoreHandler,
			Methods: "POST",
		},
		&Route{
			Name:    "Get",
			Pattern: "/get",
			Handler: GetHandler,
			Methods: "GET",
		},
		&Route{
			Name: 	 "Status",
			Pattern: "/status",
			Handler: StatusHandler,
			Methods: "GET",
		},
	}
	return route;
}
