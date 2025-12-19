import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/health_response.dart';

/// Health Check Screen
/// 
/// Shows buttons to check health of each backend service
class HealthCheckScreen extends StatefulWidget {
  const HealthCheckScreen({super.key});

  @override
  State<HealthCheckScreen> createState() => _HealthCheckScreenState();
}

class _HealthCheckScreenState extends State<HealthCheckScreen> {
  final ApiService _apiService = ApiService();
  
  // State variables to store results
  HealthResponse? _adminHealth;
  HealthResponse? _blogHealth;
  HealthResponse? _emailHealth;
  HealthResponse? _imageHealth;
  HealthResponse? _shopHealth;
  
  bool _isLoading = false;
  String _errorMessage = '';

  /// Check Admin Service health
  Future<void> _checkAdminHealth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _adminHealth = null;
    });

    try {
      final result = await _apiService.checkAdminHealth();
      setState(() {
        _adminHealth = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  /// Check Blog Service health
  Future<void> _checkBlogHealth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _blogHealth = null;
    });

    try {
      final result = await _apiService.checkBlogHealth();
      setState(() {
        _blogHealth = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  /// Check Email Service health
  Future<void> _checkEmailHealth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _emailHealth = null;
    });

    try {
      final result = await _apiService.checkEmailHealth();
      setState(() {
        _emailHealth = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  /// Check Image Service health
  Future<void> _checkImageHealth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _imageHealth = null;
    });

    try {
      final result = await _apiService.checkImageHealth();
      setState(() {
        _imageHealth = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  /// Check Shop Service health
  Future<void> _checkShopHealth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _shopHealth = null;
    });

    try {
      final result = await _apiService.checkShopHealth();
      setState(() {
        _shopHealth = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  /// Check ALL services at once
  Future<void> _checkAllServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _adminHealth = null;
      _blogHealth = null;
      _emailHealth = null;
      _imageHealth = null;
      _shopHealth = null;
    });

    try {
      final results = await _apiService.checkAllServices();
      setState(() {
        _adminHealth = results['Admin'];
        _blogHealth = results['Blog'];
        _emailHealth = results['Email'];
        _imageHealth = results['Image'];
        _shopHealth = results['Shop'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfect8 Health Check'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            const Text(
              'Backend Services Health Check',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            
            // Check All Services Button
            ElevatedButton(
              onPressed: _isLoading ? null : _checkAllServices,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text(
                'CHECK ALL SERVICES',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            
            // Individual Service Buttons
            _buildServiceButton(
              'Admin Service (8081)',
              _checkAdminHealth,
              _adminHealth,
              Colors.purple,
            ),
            const SizedBox(height: 10),
            
            _buildServiceButton(
              'Blog Service (8082)',
              _checkBlogHealth,
              _blogHealth,
              Colors.orange,
            ),
            const SizedBox(height: 10),
            
            _buildServiceButton(
              'Email Service (8083)',
              _checkEmailHealth,
              _emailHealth,
              Colors.red,
            ),
            const SizedBox(height: 10),
            
            _buildServiceButton(
              'Image Service (8084)',
              _checkImageHealth,
              _imageHealth,
              Colors.teal,
            ),
            const SizedBox(height: 10),
            
            _buildServiceButton(
              'Shop Service (8085)',
              _checkShopHealth,
              _shopHealth,
              Colors.indigo,
            ),
            
            const SizedBox(height: 20),
            
            // Loading indicator
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            
            // Error message
            if (_errorMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build a service button with status indicator
  Widget _buildServiceButton(
    String title,
    VoidCallback onPressed,
    HealthResponse? healthResponse,
    Color color,
  ) {
    return Row(
      children: [
        // Button
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
            child: Text(title),
          ),
        ),
        
        const SizedBox(width: 10),
        
        // Status indicator
        Container(
          width: 60,
          height: 48,
          decoration: BoxDecoration(
            color: healthResponse == null
                ? Colors.grey.shade300
                : (healthResponse.isHealthy ? Colors.green : Colors.red),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: healthResponse == null
                ? const Text('-', style: TextStyle(fontSize: 20))
                : Icon(
                    healthResponse.isHealthy ? Icons.check : Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
          ),
        ),
      ],
    );
  }
}
