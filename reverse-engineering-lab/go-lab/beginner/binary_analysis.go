package main

import (
	"fmt"
	"strings"
)

// Sample Go program for reverse engineering practice
func main() {
	fmt.Println("Go Reverse Engineering Lab - Beginner Level")
	fmt.Println("=" + strings.Repeat("=", 50))
	
	// Exercise 1: Basic function analysis
	exercise1()
	
	// Exercise 2: String analysis
	exercise2()
	
	// Exercise 3: Control flow analysis
	exercise3()
	
	// Exercise 4: Data structures
	exercise4()
}

func exercise1() {
	fmt.Println("\nEXERCISE 1: Basic Function Analysis")
	fmt.Println(strings.Repeat("-", 40))
	
	// Simple function to analyze
	result := simpleFunction(10, 20)
	fmt.Printf("Result: %d\n", result)
	
	fmt.Println("\nAnalysis tasks:")
	fmt.Println("1. Compile this program: go build -o sample binary_analysis.go")
	fmt.Println("2. Analyze with objdump: objdump -d sample")
	fmt.Println("3. Extract strings: strings sample")
	fmt.Println("4. Identify the simpleFunction in assembly")
}

func simpleFunction(a, b int) int {
	return a + b
}

func exercise2() {
	fmt.Println("\nEXERCISE 2: String Analysis")
	fmt.Println(strings.Repeat("-", 40))
	
	// Strings to analyze
	secret := "This is a secret message"
	password := "admin123"
	apiKey := "sk-1234567890abcdef"
	
	fmt.Printf("Secret: %s\n", secret)
	fmt.Printf("Password: %s\n", password)
	fmt.Printf("API Key: %s\n", apiKey)
	
	fmt.Println("\nAnalysis tasks:")
	fmt.Println("1. Compile and run: strings sample")
	fmt.Println("2. Look for the strings above")
	fmt.Println("3. Note their locations in the binary")
	fmt.Println("4. Try different compilation flags")
}

func exercise3() {
	fmt.Println("\nEXERCISE 3: Control Flow Analysis")
	fmt.Println(strings.Repeat("-", 40))
	
	// Complex control flow
	value := 42
	result := complexLogic(value)
	fmt.Printf("Input: %d, Output: %s\n", value, result)
	
	fmt.Println("\nAnalysis tasks:")
	fmt.Println("1. Trace the control flow in assembly")
	fmt.Println("2. Identify conditional jumps")
	fmt.Println("3. Map the logic flow")
	fmt.Println("4. Understand the decision tree")
}

func complexLogic(x int) string {
	if x > 100 {
		return "very large"
	} else if x > 50 {
		return "large"
	} else if x > 25 {
		return "medium"
	} else if x > 10 {
		return "small"
	} else {
		return "tiny"
	}
}

func exercise4() {
	fmt.Println("\nEXERCISE 4: Data Structures")
	fmt.Println(strings.Repeat("-", 40))
	
	// Data structures to analyze
	numbers := []int{1, 2, 3, 4, 5}
	user := struct {
		Name  string
		Age   int
		Email string
	}{
		Name:  "John Doe",
		Age:   30,
		Email: "john@example.com",
	}
	
	fmt.Printf("Numbers: %v\n", numbers)
	fmt.Printf("User: %+v\n", user)
	
	fmt.Println("\nAnalysis tasks:")
	fmt.Println("1. Analyze memory layout")
	fmt.Println("2. Understand Go's data structure representation")
	fmt.Println("3. Identify struct fields in assembly")
	fmt.Println("4. Trace slice operations")
}

// Additional functions for analysis
func fibonacci(n int) int {
	if n <= 1 {
		return n
	}
	return fibonacci(n-1) + fibonacci(n-2)
}

func processData(data []byte) []byte {
	result := make([]byte, len(data))
	for i, b := range data {
		result[i] = b ^ 0xFF
	}
	return result
}

func authenticate(username, password string) bool {
	// Simulated authentication
	return username == "admin" && password == "secret"
}