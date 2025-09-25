package main

import "fmt"

func secretFunction() string {
    secret := "This is a secret message"
    return secret
}

func main() {
    result := secretFunction()
    fmt.Println(result)
}
