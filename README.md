# bloc_builder

easily way to create BLoC

view full-document at: [https://pub.dev/packages/bloc_builder](https://pub.dev/packages/bloc_builder)

> bloc_builder 2 will not support stream any more, please create with flutter_live_data

## Example

### $watch

```dart
LiveData<int> liveData = LiveData(1);

var widget = $watch(
  liveData,
  build: (BuildContext _, int value) {
    return Text('value is $value');
  },
);
```

### $when

```dart
LiveData<bool> liveData = LiveData(1);

var widget = $when(liveData) |
  $case(
    (int value) => value % 2 == 0,
    build: (BuildContext _, int value) {
      return Text('$value is Even.');
    },
  ) |
  $case(
    (int value) => value % 2 == 1,
    build: (BuildContext _, int value) {
      return Text('$value is Odd.');
    },
  ) |
  $else(
    build: (BuildContext _, int value) {
      return Text('impossible!');
    },
  );
```

```dart
LiveData<bool> liveData = LiveData(1);

var widget = $when(liveData)
  ..$case(
    (int value) => value % 2 == 0,
    build: (BuildContext _, int value) {
      return Text('$value is Even.');
    },
  )
  ..$case(
    (int value) => value % 2 == 1,
    build: (BuildContext _, int value) {
      return Text('$value is Odd.');
    },
  )
  ..$else(
    build: (BuildContext _, int value) {
      return Text('impossible!');
    },
  );
```

```dart
LiveData<bool> liveData = LiveData(1);

var widget = $if(
    condition: (int value) => value % 2 == 0,
    build: (BuildContext _, int value) {
      return Text('$value is Even.');
    },
  ) |
  $else(
    build: (BuildContext _, int value) {
      return Text('$value is Odd.');
    },
  );
```

```dart
LiveData<bool> liveData = LiveData(true);

var widget = $when(liveData) |
  $true(
    build: (BuildContext _, bool value) {
      return Text('head');
    },
  ) |
  $false(
    build: (BuildContext _, bool value) {
      return Text('tail');
    },
  );
```
### $guard

```dart
LiveData<List<int>> counters = LiveData([1]);
LiveData<bool> isLoading = LiveData(false);
LiveData<String?> errorMessage = LiveData(null);

var widget = $guard(
    isLoading,
    when: (bool loading) => loading,
    build: (BuildContext _, bool loading) {
      return Text('now loading...');
    },
  ) |
  $guard.isNotNull(
    errorMessage,
    build: (BuildContext _, String? msg) {
      return Text('error: $msg');
    },
  ) |
  $guard.isEmpty(
    counters,
    build: (BuildContext _, List<int> items) {
      return Text('empty data!');
    },
  ) |
  $watch(
    counters,
    build: (BuildContext _, List<int> items) {
      return Text('data is $items');
    },
  );
```