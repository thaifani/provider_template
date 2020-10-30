import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:provider_start/core/data_sources/posts/posts_local_data_source.dart';
import 'package:provider_start/core/data_sources/posts/posts_remote_data_source.dart';
import 'package:provider_start/core/exceptions/cache_exception.dart';
import 'package:provider_start/core/exceptions/network_exception.dart';
import 'package:provider_start/core/exceptions/repository_exception.dart';
import 'package:provider_start/core/models/post/post.dart';
import 'package:provider_start/core/repositories/posts_repository/posts_repository.dart';
import 'package:provider_start/core/services/connectivity/connectivity_service.dart';
import 'package:provider_start/core/utils/logger.dart';

class PostsRepositoryImpl implements PostsRepository {
  final PostsRemoteDataSource remoteDataSource;
  final PostsLocalDataSource localDataSource;
  final ConnectivityService connectivityService;

  PostsRepositoryImpl({
    @required this.remoteDataSource,
    @required this.localDataSource,
    @required this.connectivityService,
  });

  @override
  Future<List<Post>> fetchPosts() async {
    try {
      if (await connectivityService.isConnected) {
        final posts = await remoteDataSource.fetchPosts();
        await localDataSource.cachePosts(posts);
        return posts;
      } else {
        final posts = localDataSource.fetchPosts();
        return posts;
      }
    } on NetworkException catch (e) {
      Logger.e('Failed to fetch posts remotely');
      throw RepositoryException(e.message);
    } on CacheException catch (e) {
      Logger.e('Failed to fetch posts locally');
      throw RepositoryException(e.message);
    }
  }
}
