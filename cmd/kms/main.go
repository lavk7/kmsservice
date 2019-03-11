package main

import (
	"chainstack/pkg/kms"
	"github.com/gorilla/mux"
	"log"
	"net/http"

)

func main()  {

	router := mux.NewRouter()
	routes := kms.GetRoutes()
	for _, route := range routes {
		router.HandleFunc(route.Pattern, route.Handler).Methods(route.Methods)
	}
	log.Fatal(http.ListenAndServe(":8001", router))
}
