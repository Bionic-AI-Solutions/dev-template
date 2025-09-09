"""
Integration tests for API endpoints
"""

import pytest
from fastapi.testclient import TestClient
from backend.main import app

client = TestClient(app)


class TestAPIIntegration:
    """Integration tests for API endpoints"""
    
    def test_api_workflow(self):
        """Test complete API workflow"""
        # Test root endpoint
        response = client.get("/")
        assert response.status_code == 200
        
        # Test health check
        response = client.get("/health")
        assert response.status_code == 200
        
        # Test readiness check
        response = client.get("/ready")
        assert response.status_code == 200
    
    def test_cors_headers(self):
        """Test CORS headers are present"""
        response = client.options("/", headers={"Origin": "http://localhost:3001"})
        assert response.status_code == 200
        assert "access-control-allow-origin" in response.headers
    
    def test_error_handling(self):
        """Test error handling"""
        # Test 404 error
        response = client.get("/nonexistent")
        assert response.status_code == 404
