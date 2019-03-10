package kms

import (
	"io/ioutil"
	"log"
	"net/http"
	"os/exec"
	"strings"
)

func StoreHandler(writer http.ResponseWriter, request *http.Request){

	request.ParseMultipartForm(0)
	file ,header, err := request.FormFile("upload")

	if err != nil {
		log.Println("File not found")
		log.Println(err.Error())
		writer.WriteHeader(400)
		writer.Write([]byte("File not provided by client"))
		return
	}

	user := request.FormValue("userid")

	if user == "" {
		log.Println("User not provded in request")
		writer.WriteHeader(400)
		writer.Write([]byte("User not provided in request"))
		return
	}

	name := header.Filename
	content, err := ioutil.ReadAll(file)

	if err != nil {
		log.Println("Cannot read file")
		log.Println(err.Error())
		writer.WriteHeader(400)
		writer.Write([]byte("Incompatible file"))
		return
	}
	uuid, err := exec.Command("uuidgen").Output()
	if err != nil {
		log.Println("Cannot generate uuid")
		log.Println(err.Error())
	}

	client := GetClient()
	refid, err := client.store(getKey(user, string(uuid)), string(content), name )
	if err != nil {
		writer.WriteHeader(500)
		writer.Write([]byte(err.Error()))
		return
	}
	writer.Write([]byte(refid))
}

func getKey(user, uuid string ) string {
	builder := strings.Builder{}
	builder.WriteString("secret/")
	builder.WriteString(user)
	builder.WriteString("/")
	builder.WriteString(string(uuid))
	return strings.TrimSuffix(builder.String(), "\n")

}

func StatusHandler(writer http.ResponseWriter, request *http.Request){
	key := request.URL.Query().Get("key")
	if key == "" {
		log.Panic("Empty key supplied")
		writer.WriteHeader(400)
		writer.Write([]byte("No key supplied by client"))
		return
	}
	client := GetClient()
	secret, err := client.Get(key)
	if err != nil {
		log.Printf("Unknown error while getting key %s", key)
		writer.WriteHeader(500)
		writer.Write([]byte("Unknown error occured, please try again later"))
		return
	}
	if secret == nil {
		log.Printf("Asset with key %s not found", key)
		writer.WriteHeader(202)
		writer.Write([]byte(" async"))
		return
	}
	writer.WriteHeader(200)
	writer.Write([]byte("OK"))

}
func GetHandler(writer http.ResponseWriter, request *http.Request){
	key := request.URL.Query().Get("key")
	if key == "" {
		log.Panic("Empty key supplied")
		writer.WriteHeader(400)
		writer.Write([]byte("No key supplied by client"))
		return
	}
	client := GetClient()
	secret, err := client.Get(key)
	if err != nil {
		log.Printf("Unknown error for key %s", key)
		writer.WriteHeader(500)
		writer.Write([]byte("Unknown error occured, please try again later"))
		return
	}
	if secret == nil {
		log.Printf("Asset with key %s not found", key)
		writer.WriteHeader(200)
		writer.Write([]byte("Asset not found"))
		return
	}
	name, nexist := secret.Data["name"]
	content, cexist := secret.Data["content"]
 	if !nexist || !cexist {
		writer.WriteHeader(500)
		writer.Write([]byte("The assest is stored incorrectly"))
		log.Println("Malformed data")
		return
	}
	fo, err := ioutil.TempFile("/tmp", name.(string))
	if err != nil{
		log.Panic(err)
	}
	_ , err = fo.Write([]byte(content.(string)))
	if err != nil {
		writer.WriteHeader(500)
		writer.Write([]byte("Internal server error"))
		log.Println([]byte(err.Error()))

	}
	http.ServeFile(writer, request, fo.Name())

}