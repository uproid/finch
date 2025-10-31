# Finch

A lightweight, robust, and feature-rich web framework for Dart that makes server-side development simple and enjoyable.

[![Pub Version](https://img.shields.io/pub/v/finch)](https://pub.dev/packages/finch)
[![License](https://img.shields.io/github/license/uproid/finch)](LICENSE)
[![Demo](https://img.shields.io/badge/demo-live-brightgreen)](https://finch.uproid.com)

## Overview

Finch is a powerful and modern web application framework built with Dart, designed with a focus on performance, simplicity, security, and stability. It provides everything you need to build robust, multi-platform, and scalable server-side applications and websites with minimal setup and maximum efficiency.

Using the static and powerful Dart language, Finch helps developers create portable and maintainable applications that perform consistently across environments. Its modular architecture enables easy extension and customization while keeping boilerplate code to a minimum.

Whether you're building websites, APIs, microservices, or embedded systems (such as Raspberry Pi) that demand high performance and low latency, Finch offers a clean and intuitive way to manage routing, databases, WebSockets, and more — all while leveraging Dart’s native performance and

## Features

Finch comes packed with essential tools to streamline your development process. Here's a detailed breakdown of its key capabilities:

### 🚀 WebSocket Support
- Real-time bidirectional communication for interactive applications.
- Easy integration with server-side events and client connections.
- Built-in event handling for connect, message, and disconnect scenarios.

### 🗄️ Database Integration
- **MongoDB Support**: Seamless integration with MongoDB for flexible NoSQL storage.
- **MySQL Integration**: Full support for relational databases with query builders and connection pooling.
- **SQLite for Lightweight Storage**: Ideal for embedded or small-scale applications with file-based databases.
- Unified API for database operations across all supported types.

### ⚡ Fast Routing
- Intuitive and flexible routing system with support for nested routes, parameters, and middleware.
- Method-based routing (GET, POST, PUT, DELETE, etc.) with easy path matching.
- Extra path support for API versioning and multiple endpoints.

### 🌐 Internationalization (i18n)
- Built-in support for multiple languages with easy translation management.
- Dynamic language switching and locale-based content rendering.
- Template-based translation with parameter substitution.

### 🔒 Form Validation
- Comprehensive form validation tools with customizable rules.
- Field-level validation for emails, passwords, numbers, dates, and more.
- Error handling and feedback integration with templates.

### 📝 HTML Tools
- Rapid HTML page development with Jinja2-inspired templating.
- Widget system for reusable components and layouts.
- Built-in macros for common UI elements like sorting and pagination.

### 📊 Database Models
- Easy creation and management of database models with ORM-like features.
- Support for collections, queries, and relationships.
- Automatic parameter conversion for API responses.

### 📚 OpenAPI Documentation
- Automatic generation of API documentation with Swagger UI integration.
- Real-time API specs for better developer experience.
- Customizable documentation with route metadata.

### ⏱️ Cron Jobs
- Scheduled task management with cron-like syntax.
- Support for recurring jobs, delays, and one-time executions.
- Integration with the main application lifecycle.

### 🔧 Configuration Management
- Flexible configuration system with environment variable support.
- Separate configs for databases, mail, and app settings.
- Easy setup for local debugging and production environments.

### 📁 Static File Serving
- Efficient handling of static assets like CSS, JS, and images.
- Automatic asset compilation and serving.
- Support for public directories and custom paths.

### 🎯 Dart Native Performance
- Leverages Dart's speed and efficiency for high-performance applications.
- Native compilation for better runtime performance.
- Optimized for both server-side and multi-platform deployments.

## Quick Start

Getting started with Finch is straightforward. Follow these steps to set up your first application:

1. **Add Finch to your project**:

   ```yaml
   dependencies:
     finch: ^latest_version
   ```

2. **Create a basic server**:

   ```dart
   import 'package:finch/app.dart';
   import 'package:finch/console.dart';
   import 'package:finch/tools.dart';

   void main() async {
     final configs = FinchConfigs(
       widgetsPath: "./widgets",
       publicDir: "./public",
       port: 8085,
     );

     final server = FinchServer(configs: configs);

     server.start().then((value) {
       Console.p("Server started: http://localhost:${value.port}");
     });
   }
   ```

3. **Run your application**:

   ```bash
   dart run
   ```

   Visit `http://localhost:8085` to see your server in action.

## Examples

### Basic Routing
```dart
app.get(
  path: '/hello',
  index: (rq) async {
    return rq.renderString(text: 'Hello, World!');
  },
);
```

### WebSocket Integration
```dart
final socketManager = SocketManager(
  server,
  event: SocketEvent(
    onConnect: (socket) {
      socket.send({'message': 'Connected!'}, path: 'status');
    },
    onMessage: (socket, data) {
      // Handle messages
    },
  ),
);
```

### Database Query
```dart
// MongoDB example
var collection = ExampleCollections();
var results = await collection.getAllExample();

// MySQL example
var books = MysqlBooks(driver);
var allBooks = await books.getAllBooks();
```

For more comprehensive examples, explore the `example/` directory in this repository. It includes full implementations of forms, databases, WebSockets, and more.

## Documentation

For in-depth guides and API references:

- [Official Documentation](https://github.com/uproid/finch/tree/master/doc)
- [API Reference](https://pub.dev/documentation/finch/latest/)
- [Examples Repository](https://github.com/uproid/finch/tree/master/example)
- [Live Demo](https://finch.uproid.com)

## Docker Support

Finch includes built-in Docker support for easy deployment. To run the example application:

```bash
docker compose up --build
```

This sets up the full environment with databases and dependencies.

## Contributing

We believe in the power of community-driven development. Your contributions make Finch better for everyone. Whether you're fixing bugs, adding features, improving documentation, or sharing feedback, every effort is valued and appreciated.

### How to Contribute

1. **Fork the repository** and create your branch from `master`.
2. **Make your changes**: Ensure your code follows the existing style and includes tests where applicable.
3. **Test thoroughly**: Run the test suite and verify your changes don't break existing functionality.
4. **Update documentation**: Keep docs in sync with your changes.
5. **Submit a pull request**: Describe your changes clearly and reference any related issues.

### Development Guidelines

- Write clear, concise code with meaningful comments.
- Follow Dart's style guidelines and use the provided linter.
- Add unit tests for new features.
- Ensure cross-platform compatibility.

### Feedback and Support

Your feedback is invaluable. If you encounter issues, have suggestions, or want to discuss ideas:

- **Report bugs** via [GitHub Issues](https://github.com/uproid/finch/issues)
- **Join discussions** on [GitHub Discussions](https://github.com/uproid/finch/discussions)
- **Reach out** on our community channels

Together, let's build something amazing!

## License

Finch is [MIT licensed](LICENSE), allowing you to use, modify, and distribute it freely while giving credit to the original work.

## Connect & Support

- 🌟 **Star us on GitHub** to show your support
- 📢 **Follow for updates** and stay connected
- 💬 **Join the conversation** – your input shapes the future of Finch

Made with ❤️ by [Uproid](https://github.com/uproid)
