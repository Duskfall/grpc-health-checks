#region Copyright notice and license

// Copyright 2019 The gRPC Authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#endregion

using System.Threading.Tasks;
using Greet;
using Grpc.Core;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Logging;

namespace Server.HealthChecks;

public class GrpcHealthCheck : IHealthCheck
{
    private readonly ILogger<GrpcHealthCheck> _logger;
    private volatile bool _isReady;

    public GrpcHealthCheck(ILogger<GrpcHealthCheck> logger)
    {
        _logger = logger;
        _isReady = false;
    }

    public Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        try
        {
            if (!_isReady)
            {
                _isReady = true;
                _logger.LogInformation("gRPC service is now ready to accept requests");
            }

            // Here you could add additional checks like:
            // - Database connectivity
            // - External service dependencies
            // - Resource availability

            return Task.FromResult(
                HealthCheckResult.Healthy("gRPC Server is healthy and accepting requests"));
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Health check failed");
            return Task.FromResult(
                HealthCheckResult.Unhealthy("gRPC Server is unhealthy", ex));
        }
    }
}
