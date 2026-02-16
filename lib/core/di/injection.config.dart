// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:go_router/go_router.dart' as _i583;
import 'package:hive/hive.dart' as _i979;
import 'package:injectable/injectable.dart' as _i526;

import '../../data/services/content_matching_service.dart' as _i963;
import '../../data/services/notification_service.dart' as _i670;
import '../../data/services/user_preferences_service.dart' as _i402;
import '../../features/music/data/services/cache_service.dart' as _i736;
import '../../features/music/data/services/music_service.dart' as _i829;
import '../../features/music/presentation/bloc/quote_music_bloc.dart' as _i33;
import '../../features/onboarding/presentation/cubit/onboarding_cubit.dart'
    as _i807;
import '../../features/quotes/data/datasources/quote_local_data_source.dart'
    as _i409;
import '../../features/quotes/data/datasources/quote_remote_data_source.dart'
    as _i1017;
import '../../features/quotes/data/repositories/quote_repository_impl.dart'
    as _i57;
import '../../features/quotes/domain/repositories/quote_repository.dart'
    as _i11;
import '../../features/quotes/presentation/bloc/feed_bloc.dart' as _i378;
import '../ads/ad_frequency_manager.dart' as _i247;
import '../ads/ad_service.dart' as _i196;
import '../ads/app_open_ad_manager.dart' as _i343;
import '../ads/consent_manager.dart' as _i837;
import '../ads/interstitial_ad_manager.dart' as _i452;
import '../ads/rewarded_ad_manager.dart' as _i834;
import '../router/app_router.dart' as _i81;
import '../theme/theme_cubit.dart' as _i611;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i837.ConsentManager>(() => _i837.ConsentManager());
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i963.ContentMatchingService>(
        () => _i963.ContentMatchingService());
    await gh.factoryAsync<_i979.Box<dynamic>>(
      () => registerModule.userBox,
      instanceName: 'userBox',
      preResolve: true,
    );
    await gh.factoryAsync<_i979.Box<dynamic>>(
      () => registerModule.adFrequencyBox,
      instanceName: 'adFrequencyBox',
      preResolve: true,
    );
    gh.lazySingleton<_i247.AdFrequencyManager>(() => _i247.AdFrequencyManager(
        gh<_i979.Box<dynamic>>(instanceName: 'adFrequencyBox')));
    gh.lazySingleton<_i409.QuoteLocalDataSource>(
        () => _i409.QuoteLocalDataSourceImpl());
    gh.lazySingleton<_i829.MusicService>(
        () => _i829.MusicService(gh<_i361.Dio>()));
    gh.lazySingleton<_i1017.QuoteRemoteDataSource>(
        () => _i1017.QuoteRemoteDataSource(gh<_i361.Dio>()));
    gh.lazySingleton<_i11.QuoteRepository>(() => _i57.QuoteRepositoryImpl(
          gh<_i409.QuoteLocalDataSource>(),
          gh<_i1017.QuoteRemoteDataSource>(),
        ));
    gh.lazySingleton<_i736.CacheService>(() =>
        _i736.CacheService(gh<_i979.Box<dynamic>>(instanceName: 'userBox')));
    gh.lazySingleton<_i402.UserPreferencesService>(() =>
        _i402.UserPreferencesService(
            gh<_i979.Box<dynamic>>(instanceName: 'userBox')));
    gh.lazySingleton<_i670.NotificationService>(
        () => _i670.NotificationService(gh<_i402.UserPreferencesService>()));
    gh.lazySingleton<_i343.AppOpenAdManager>(() => _i343.AppOpenAdManager(
          gh<_i247.AdFrequencyManager>(),
          gh<_i402.UserPreferencesService>(),
        ));
    gh.lazySingleton<_i452.InterstitialAdManager>(
        () => _i452.InterstitialAdManager(gh<_i247.AdFrequencyManager>()));
    gh.lazySingleton<_i834.RewardedAdManager>(
        () => _i834.RewardedAdManager(gh<_i247.AdFrequencyManager>()));
    gh.factory<_i807.OnboardingCubit>(
        () => _i807.OnboardingCubit(gh<_i402.UserPreferencesService>()));
    gh.singleton<_i583.GoRouter>(
        () => registerModule.router(gh<_i402.UserPreferencesService>()));
    gh.factory<_i33.QuoteMusicBloc>(() => _i33.QuoteMusicBloc(
          gh<_i1017.QuoteRemoteDataSource>(),
          gh<_i829.MusicService>(),
          gh<_i736.CacheService>(),
        ));
    gh.lazySingleton<_i196.AdService>(() => _i196.AdService(
          gh<_i452.InterstitialAdManager>(),
          gh<_i343.AppOpenAdManager>(),
          gh<_i834.RewardedAdManager>(),
          gh<_i247.AdFrequencyManager>(),
        ));
    gh.factory<_i611.ThemeCubit>(
        () => _i611.ThemeCubit(gh<_i402.UserPreferencesService>()));
    gh.factory<_i378.FeedBloc>(() => _i378.FeedBloc(
          gh<_i11.QuoteRepository>(),
          gh<_i402.UserPreferencesService>(),
          gh<_i963.ContentMatchingService>(),
          gh<_i829.MusicService>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i81.RegisterModule {}
