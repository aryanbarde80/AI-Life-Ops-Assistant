import time
import asyncio
from functools import wraps

class CircuitBreaker:
    """
    Enterprise Circuit Breaker pattern to prevent cascading failures.
    Total 'Engineering Flex' for high-availability systems.
    """
    def __init__(self, failure_threshold=3, recovery_timeout=30):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        self.failures = 0
        self.last_failure_time = 0
        self.state = "CLOSED"  # CLOSED, OPEN, HALF-OPEN

    def __call__(self, func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            if self.state == "OPEN":
                if time.time() - self.last_failure_time > self.recovery_timeout:
                    self.state = "HALF-OPEN"
                    print(f"[CircuitBreaker] {func.__name__} entering HALF-OPEN state.")
                else:
                    raise Exception(f"Circuit for {func.__name__} is OPEN.")

            try:
                result = await func(*args, **kwargs)
                if self.state == "HALF-OPEN":
                    self.state = "CLOSED"
                    self.failures = 0
                    print(f"[CircuitBreaker] {func.__name__} recovered to CLOSED state.")
                return result
            except Exception as e:
                self.failures += 1
                self.last_failure_time = time.time()
                if self.failures >= self.failure_threshold:
                    self.state = "OPEN"
                    print(f"[CircuitBreaker] {func.__name__} is now OPEN (failures: {self.failures}).")
                raise e
        return wrapper
