import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/segmentio/kafka-go"
)

type SystemStats struct {
	CPUUsage    float64 `json:"cpu_usage"`
	MemoryUsage string  `json:"memory_usage"`
	Latency     int     `json:"latency_ms"`
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	stats := SystemStats{CPUUsage: 12.5, MemoryUsage: "256MB", Latency: 5}
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(stats)
}

func consumeEvents() {
	broker := os.Getenv("KAFKA_BOOTSTRAP_SERVERS")
	if broker == "" {
		broker = "kafka:9092"
	}
	r := kafka.NewReader(kafka.ReaderConfig{
		Brokers:  []string{broker},
		Topic:    "task_events",
		GroupID:  "performance_group",
		MaxBytes: 10e6, // 10MB
	})
	fmt.Println("[Performance] Kafka Consumer started for 'task_events'")
	for {
		m, err := r.ReadMessage(context.Background())
		if err != nil {
			break
		}
		fmt.Printf("[Performance] Event Received: %s\n", string(m.Value))
	}
}

func main() {
	go consumeEvents()
	http.HandleFunc("/performance/health", healthHandler)
	fmt.Println("Performance Service (Go) running on port 8002")
	log.Fatal(http.ListenAndServe(":8002", nil))
}
