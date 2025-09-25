package main

import (
	"bufio"
	"fmt"
	"os"
)

func transform(b byte, idx int) byte {
	return ((b ^ 0x5A) + byte(idx*3)) ^ 0xA5
}

func check(flag string) bool {
	target := []byte{0x7b, 0x76, 0x7b, 0x7e, 0x75, 0x6e, 0x60, 0x69}
	if len(flag) != len(target) {
		return false
	}
	for i := 0; i < len(target); i++ {
		if transform(flag[i], i) != target[i] {
			return false
		}
	}
	return true
}

func main() {
	reader := bufio.NewReader(os.Stdin)
	fmt.Print("Input: ")
	line, _ := reader.ReadString('\n')
	if len(line) > 0 && line[len(line)-1] == '\n' {
		line = line[:len(line)-1]
	}
	if check(line) {
		fmt.Println("OK")
	} else {
		fmt.Println("NO")
	}
}
