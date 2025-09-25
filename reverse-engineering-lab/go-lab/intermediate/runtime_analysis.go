package main

import (
	"fmt"
	"runtime"
	"time"
	"sync"
	"unsafe"
)

// Runtime analysis exercises for Go reverse engineering
func main() {
	fmt.Println("Go Runtime Analysis - Intermediate Level")
	fmt.Println("=" + string(make([]byte, 50)))
	
	// Exercise 1: Goroutine analysis
	exercise1_goroutines()
	
	// Exercise 2: Memory analysis
	exercise2_memory()
	
	// Exercise 3: Runtime internals
	exercise3_runtime()
	
	// Exercise 4: Concurrency patterns
	exercise4_concurrency()
}

func exercise1_goroutines() {
	fmt.Println("\nEXERCISE 1: Goroutine Analysis")
	fmt.Println(strings.Repeat("-", 40))
	
	// Create multiple goroutines
	var wg sync.WaitGroup
	
	for i := 0; i < 5; i++ {
		wg.Add(1)
		go func(id int) {
			defer wg.Done()
			fmt.Printf("Goroutine %d: PID=%d\n", id, os.Getpid())
			time.Sleep(100 * time.Millisecond)
		}(i)
	}
	
	wg.Wait()
	
	fmt.Println("\nAnalysis tasks:")
	fmt.Println("1. Use 'go tool trace' to analyze goroutines")
	fmt.Println("2. Monitor with 'go tool pprof'")
	fmt.Println("3. Understand goroutine scheduling")
	fmt.Println("4. Analyze memory usage per goroutine")
}

func exercise2_memory() {
	fmt.Println("\nEXERCISE 2: Memory Analysis")
	fmt.Println(strings.Repeat("-", 40))
	
	// Memory allocation patterns
	data := make([]byte, 1024*1024) // 1MB
	fmt.Printf("Allocated 1MB: %p\n", &data[0])
	
	// String allocation
	secret := "This is a secret string"
	fmt.Printf("Secret string: %p\n", unsafe.Pointer(&secret))
	
	// Struct allocation
	type User struct {
		Name  string
		Age   int
		Email string
	}
	
	user := User{
		Name:  "John Doe",
		Age:   30,
		Email: "john@example.com",
	}
	
	fmt.Printf("User struct: %p\n", unsafe.Pointer(&user))
	
	fmt.Println("\nAnalysis tasks:")
	fmt.Println("1. Analyze memory layout with 'go tool pprof'")
	fmt.Println("2. Understand Go's memory management")
	fmt.Println("3. Identify heap vs stack allocation")
	fmt.Println("4. Monitor garbage collection")
}

func exercise3_runtime() {
	fmt.Println("\nEXERCISE 3: Runtime Internals")
	fmt.Println(strings.Repeat("-", 40))
	
	// Runtime information
	fmt.Printf("Go version: %s\n", runtime.Version())
	fmt.Printf("OS: %s\n", runtime.GOOS)
	fmt.Printf("Architecture: %s\n", runtime.GOARCH)
	fmt.Printf("Number of CPUs: %d\n", runtime.NumCPU())
	fmt.Printf("Number of goroutines: %d\n", runtime.NumGoroutine())
	
	// Memory stats
	var m runtime.MemStats
	runtime.ReadMemStats(&m)
	fmt.Printf("Heap size: %d bytes\n", m.HeapAlloc)
	fmt.Printf("Stack size: %d bytes\n", m.StackInuse)
	
	fmt.Println("\nAnalysis tasks:")
	fmt.Println("1. Understand Go runtime structure")
	fmt.Println("2. Analyze runtime symbols")
	fmt.Println("3. Study garbage collector behavior")
	fmt.Println("4. Examine runtime initialization")
}

func exercise4_concurrency() {
	fmt.Println("\nEXERCISE 4: Concurrency Patterns")
	fmt.Println(strings.Repeat("-", 40))
	
	// Channel communication
	ch := make(chan int, 5)
	
	// Producer
	go func() {
		for i := 0; i < 10; i++ {
			ch <- i
			fmt.Printf("Sent: %d\n", i)
		}
		close(ch)
	}()
	
	// Consumer
	go func() {
		for val := range ch {
			fmt.Printf("Received: %d\n", val)
			time.Sleep(50 * time.Millisecond)
		}
	}()
	
	time.Sleep(1 * time.Second)
	
	fmt.Println("\nAnalysis tasks:")
	fmt.Println("1. Analyze channel implementation")
	fmt.Println("2. Understand select statement")
	fmt.Println("3. Study mutex/lock patterns")
	fmt.Println("4. Examine deadlock detection")
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

// Complex data structure for analysis
type ComplexStruct struct {
	ID       int
	Name     string
	Data     []byte
	Children []*ComplexStruct
	Mutex    sync.RWMutex
}

func (c *ComplexStruct) Process() {
	c.Mutex.Lock()
	defer c.Mutex.Unlock()
	
	// Simulate processing
	time.Sleep(10 * time.Millisecond)
}

// Interface for polymorphism analysis
type Processor interface {
	Process()
	GetID() int
}

func (c *ComplexStruct) GetID() int {
	return c.ID
}