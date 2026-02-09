import 'package:flutter/foundation.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/repositories/quotation_repository.dart';
import '../../data/repositories/mock_project_repository.dart';
import '../../data/repositories/firestore_project_repository.dart';
import '../../data/repositories/mock_quotation_repository.dart';
import '../../data/repositories/quotation_repository_impl.dart';
import '../../domain/repositories/job_repository.dart';
import '../../data/repositories/mock_job_repository.dart';
import '../../data/repositories/cloud_job_repository.dart';

enum Environment {
  mock,
  prod,
}

class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;

  AppConfig._internal();

  // Default to Mock for safety, can be changed before app run
  Environment environment = kReleaseMode ? Environment.prod : Environment.mock;

  void setEnvironment(Environment env) {
    environment = env;
    debugPrint('🔧 Environment set to: ${env.name.toUpperCase()}');
  }

  // Factory methods for repositories based on current environment

  ProjectRepository get projectRepository {
    if (environment == Environment.prod) {
      return FirestoreProjectRepository();
    }
    return MockProjectRepository();
  }

  QuotationRepository get quotationRepository {
    if (environment == Environment.prod) {
      return QuotationRepositoryImpl();
    }
    return MockQuotationRepository();
  }

  JobRepository get jobRepository {
    if (environment == Environment.prod) {
      return CloudJobRepository();
    }
    return MockJobRepository();
  }
}
