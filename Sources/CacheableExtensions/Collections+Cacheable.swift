extension Array: Cacheable where Element: Cacheable {}
extension Set: Cacheable where Element: Cacheable {}
extension Dictionary: Cacheable where Key: Cacheable, Value: Cacheable {}
