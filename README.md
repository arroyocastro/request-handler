# Request Handler - API Gateway

## Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Technical Stack](#technical-stack)
- [Setup and Installation](#setup-and-installation)
- [Configuration](#configuration)
- [API Endpoints](#api-endpoints)
- [Security](#security)
- [Fallback Behavior](#fallback-behavior)
- [Monitoring](#monitoring)
- [File Structure](#file-structure)
- [Kubernetes Resources](#kubernetes-resources)
- [Troubleshooting](#troubleshooting)

## Overview

Request Handler is a Spring Cloud Gateway application that serves as the central entry point for all client requests in a microservice architecture. It handles routing, authentication, load balancing, and cross-origin resource sharing (CORS) configuration.

## Architecture

The application follows a microservice architecture pattern with the API Gateway pattern.

```
                   ┌───────────────┐
                   │ Keycloak Auth │
                   └───────▲───────┘
                           │
                           │ JWT Validation
                           │
┌─────────┐      ┌─────────▼─────────┐
│ Clients │──────► Request Handler   │
└─────────┘      │ (API Gateway)     │
                 └─────────┬─────────┘
                           │
                           ▼
     ┌──────────┬──────────┬──────────┬──────────┐
     │          │          │          │          │
┌────▼───┐ ┌────▼───┐ ┌────▼───┐ ┌────▼───┐ ┌────▼───┐
│ Schema │ │ Party  │ │ Product│ │ Common │ │ Orders │
│  API   │ │  API   │ │  API   │ │  API   │ │  API   │
└────────┘ └────────┘ └────────┘ └────────┘ └────────┘
```

### Request Flow

1. Client sends a request to the Request Handler gateway
2. The gateway validates the JWT token with Keycloak
3. If authentication succeeds, the request is routed to the appropriate microservice
4. The microservice processes the request and returns a response
5. The gateway forwards the response back to the client
6. If a microservice is unavailable, the fallback controller provides a degraded response

## Features

- **API Routing**: Routes client requests to appropriate microservices based on path patterns
- **Authentication**: OAuth2 JWT token validation via Keycloak integration
- **CORS Support**: Configurable cross-origin resource sharing
- **Fallback Responses**: Graceful degradation when downstream services are unavailable
- **Kubernetes Integration**: ConfigMap-based configuration management
- **Load Balancing**: Client-side load balancing for service instances
- **Security**: Proper authorization controls for all endpoints
- **Configuration Reload**: Dynamic configuration updates without restarting the service

## Technical Stack

- Java 21
- Spring Boot 3.4.2
- Spring Cloud Gateway
- Spring Security with OAuth2 Resource Server
- Spring Cloud Kubernetes for ConfigMap integration
- Docker containerization
- Kubernetes deployment

## Setup and Installation

### Prerequisites

- JDK 21
- Maven
- Docker
- Kubernetes cluster (for production deployment)
- Keycloak server for authentication

### Local Development

1. Clone the repository
2. Configure your Keycloak server in `application.yml`
3. Run the application:
   ```
   mvn spring-boot:run
   ```

### Docker Build

```bash
mvn clean package
docker build -t request-handler:latest .
```

### Kubernetes Deployment

```bash
kubectl apply -f request-handler-kubernetes.yaml
```

## Configuration

The application utilizes a layered configuration approach:

1. `bootstrap.yml` - Core bootstrap configuration
2. `application.yml` - Default application settings
3. Kubernetes ConfigMap - Environment-specific configuration

### Key Configuration Properties

- Server port: 8989
- Routes configuration for microservices
- CORS settings
- JWT authentication configuration
- Logging levels

## API Endpoints

The gateway routes requests to the following services:

- `/schema/**` - Schema API service
- `/party/**` - Party management service
- `/product/**` - Product management service
- `/common/**` - Common utilities service
- `/orders/**` - Order management service
- `/validate/**` - Schema validation service

## Security

- OAuth2 Resource Server with JWT token validation
- JWT tokens are validated against Keycloak server
- Actuator endpoints and OPTIONS requests are permitted without authentication
- All other requests require authentication

## Fallback Behavior

The service provides fallback responses when downstream services are unavailable:

- Party Service: Fallback message when the service is down
- Product Service: Fallback message when the service is down

## Monitoring

- Prometheus integration for metrics collection
- Trace logging available for security and gateway operations

## File Structure

- `src/main/java/com/felips/requestHandler/`
  - `RequestHandlerApplication.java` - Main application entry point
  - `WebSecurityConfiguration.java` - Security configuration
  - `FallbackController.java` - Fallback response handlers
- `src/main/resources/`
  - `application.yml` - Base application configuration
  - `bootstrap.yml` - Bootstrap configuration for Kubernetes
- `Dockerfile` - Container definition
- `request-handler-kubernetes.yaml` - Kubernetes deployment resources

## Kubernetes Resources

- ServiceAccount: `request-handler-sa`
- Role: `config-reader` (for ConfigMap access)
- RoleBinding: `read-configmaps`
- ConfigMap: `request-handler` (contains application configuration)
- Deployment: 2 replicas with NodePort service

## Troubleshooting

### Common Issues

#### Gateway Not Connecting to Microservices
- Verify the service URIs in the ConfigMap are correct
- Check network connectivity between the gateway and microservices
- Ensure Kubernetes services are properly exposed

#### Authentication Failures
- Verify Keycloak configuration in application.yml
- Check that the jwk-set-uri is accessible from the gateway
- Ensure client tokens have the correct scopes and claims

#### ConfigMap Not Loading
- Verify the ServiceAccount has proper RBAC permissions
- Check ConfigMap syntax for any YAML formatting errors
- Restart the gateway pods after ConfigMap changes

### Logs

Key logs to check when troubleshooting:
- Gateway routing logs: `org.springframework.cloud.gateway`
- Security logs: `org.springframework.security`
- Kubernetes config logs: `org.springframework.cloud.kubernetes`

Increase log verbosity by setting levels in the ConfigMap:
```yaml
logging:
  level:
    org.springframework.security: TRACE
    org.springframework.cloud.gateway: TRACE
    com.felips: TRACE
```

## Performance Considerations

- **Connection Pooling**: The gateway manages connection pools to backend services
- **Rate Limiting**: Consider adding rate limiting for protection against traffic spikes
- **Caching**: For frequently accessed and relatively static data, enable response caching
- **Memory Settings**: Tune JVM memory settings based on expected load



