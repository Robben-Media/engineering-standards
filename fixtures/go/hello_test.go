package hello

import "testing"

func TestGreet(t *testing.T) {
	if got := Greet(); got != "ok" {
		t.Fatalf("Greet() = %q, want ok", got)
	}
}
