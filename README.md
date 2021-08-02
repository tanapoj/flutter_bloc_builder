# bloc_builder

Util to easily create BLoC

## Getting Started

```dart
//Stream
Stream<int> stream = _createStream();
var widget = $watch(
  stream,
  builder: (_, value){
    return Text('value is $value');
  }
);

//LiveData
LiveData<int> lv = LiveData(1);
var widget = $watch(
  lv,
  builder: (_, value){
    return Text('value is $value');
  }
);
```

## Builder Util

### $watch

```dart
LiveData<int> liveData = LiveData(1);
var widget = $watch(
  liveData,
  builder: (_, value) => Text('value is $value'),
);
```

### $bool

```dart
LiveData<bool> liveData = LiveData(true);
var widget = $bool(
  liveData,
  predicate: (b) => b,
  $true: (_, value) => Text('predicate is TRUE: $value'),
  $false: (_, value) => Text('predicate is FALSE: $value'),
);
```

### $switch

```dart
LiveData<int> liveData = LiveData(1);
var widget = $switch(
  liveData,
  predicate: (b) => b,
  builders: {
    0: (_, value) => Text('value is ZERO'),
    1: (_, value) => Text('value is ONE'),
  },
  $default: (_, value) => Text('value is $value'),
);
```

### $if, $else

```dart
LiveData<int> liveData = LiveData(1);
var widget = $if(
  liveData,
  condition: (c) => c > 10,
  builder: (_, value) => Text('value more than 10: $value'),
  $else: (_, value) => Text('value not more than 10: $value'),
);

var widget = $else(
  liveData,
  condition: (c) => c > 10,
  builder: (_, value) => Text('value not more than 10: $value'),
);
```

### $for

```dart
LiveData<List<String>> liveData = LiveData(<String>[]);
var widget = Expanded(
  child: $for(
      liveData,
      builder: (_, value) => Text('item: $value'),
      $empty: (_, List<String> list) => Text('List Empty'),
   ),
);
```

### $guard

```dart
LiveData<int> data = LiveData(1);
LiveData<bool> loading = LiveData(true);
LiveData<Error> error = LiveData(Error(message: '-'));

var widget = $guard(
    loading,
    resolve: (loading) => !loading,
    $elseReturn: (_, value) => Text('now loading...'),
).$guard(
    error,
    reject: (error) => error.hasError,
    $elseReturn: (_, value) => Text('error: $value'),
).$watch(
    data,
    build: (_, value) => Text('value is $value'),
);
```
