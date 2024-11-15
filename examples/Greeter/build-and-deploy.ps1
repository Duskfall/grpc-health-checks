# Ensure we're using Docker Desktop's Kubernetes context
kubectl config use-context docker-desktop

# Clean up ALL existing deployments and services
Write-Host "Cleaning up existing deployments and services..." -ForegroundColor Yellow
kubectl delete deployment grpc-server grpc-client --ignore-not-found
kubectl delete service grpc-server --ignore-not-found

# Wait for cleanup to complete
Start-Sleep -Seconds 5

# Build the Docker image
Write-Host "Building Docker image..." -ForegroundColor Green
docker build -t grpc-server:latest -f Server/Dockerfile .

# Verify the image was built
Write-Host "Verifying docker image..." -ForegroundColor Green
docker images grpc-server:latest
if (-not $?) {
    Write-Host "Failed to build docker image!" -ForegroundColor Red
    exit 1
}

# Apply the Kubernetes configurations
Write-Host "Applying Kubernetes configurations..." -ForegroundColor Green
kubectl apply -f grpc-service.yaml

# Wait for the deployment to be ready
Write-Host "Waiting for deployment to be ready..." -ForegroundColor Green
kubectl rollout status deployment/grpc-server

# Show the deployment status
Write-Host "Deployment status:" -ForegroundColor Cyan
kubectl get pods,svc

# Get the LoadBalancer IP
Write-Host "Service URL:" -ForegroundColor Cyan
kubectl get service grpc-server

# Helper function to test the service
function Test-GrpcService {
    Write-Host "Testing gRPC service..." -ForegroundColor Green
    
    try {
        Write-Host "Testing service listing..." -ForegroundColor Cyan
        grpcurl -plaintext localhost:80 list
        
        Write-Host "Testing Greeter service..." -ForegroundColor Cyan
        grpcurl -plaintext -d '{\"name\": \"Docker Desktop\"}' localhost:80 greet.Greeter/SayHello
    }
    catch {
        Write-Host "Error testing service: $_" -ForegroundColor Red
    }
}

# Show docker images
Write-Host "Docker images:" -ForegroundColor Cyan
docker images | Select-String "grpc-"

# Show detailed pod information if there are any issues
$pods = kubectl get pods -l app=grpc-server -o jsonpath='{.items[*].metadata.name}'
if ($pods) {
    Write-Host "Pod details:" -ForegroundColor Cyan
    foreach ($pod in $pods.Split()) {
        Write-Host "Details for pod ${pod}:" -ForegroundColor Yellow
        kubectl describe pod $pod
    }
}

# Optional test
$response = Read-Host "Would you like to test the service? (y/n)"
if ($response -eq 'y') {
    Test-GrpcService
}