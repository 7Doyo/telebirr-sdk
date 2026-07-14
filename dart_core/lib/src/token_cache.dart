/// An in-memory token cache with configurable time-to-live (TTL).
///
/// Stores the fabric token obtained from the Telebirr token endpoint and
/// automatically invalidates it after the configured TTL expires. This
/// prevents unnecessary token refresh requests.
///
/// The default TTL is 50 minutes, which is slightly less than the typical
/// token lifetime to ensure tokens are refreshed before they expire.
///
/// Example:
/// ```dart
/// final cache = TokenCache(ttl: Duration(minutes: 45));
/// cache.set('my-fabric-token');
/// final token = cache.get(); // Returns the token if not expired
/// ```
class TokenCache {
  /// The cached fabric token, or `null` if no token is cached.
  String? _token;

  /// The expiration timestamp for the cached token, or `null` if empty.
  DateTime? _expiresAt;

  /// The time-to-live duration for cached tokens.
  ///
  /// After this duration from [set], the token is considered expired
  /// and [get] returns `null`.
  final Duration ttl;

  /// Creates a [TokenCache] with an optional custom [ttl].
  ///
  /// Defaults to 50 minutes if not specified.
  TokenCache({Duration? ttl}) : ttl = ttl ?? const Duration(minutes: 50);

  /// Returns the cached token if it exists and has not expired.
  ///
  /// Returns `null` if:
  /// - No token has been set.
  /// - The token has expired (TTL elapsed since [set] was called).
  ///
  /// When the token is expired, it is automatically cleared.
  String? get() {
    if (_token == null || _expiresAt == null) return null;
    if (DateTime.now().isAfter(_expiresAt!)) {
      _token = null;
      _expiresAt = null;
      return null;
    }
    return _token;
  }

  /// Stores a new [token] in the cache with a fresh TTL.
  ///
  /// Replaces any previously cached token. The expiration is set to
  /// [ttl] from the current time.
  void set(String token) {
    _token = token;
    _expiresAt = DateTime.now().add(ttl);
  }

  /// Clears the cached token and expiration.
  ///
  /// After calling this, [get] returns `null` until [set] is called again.
  void clear() {
    _token = null;
    _expiresAt = null;
  }
}
