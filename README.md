# bloc_builder

easily way to create BLoC

view full-document at: [https://pub.dev/packages/bloc_builder](https://pub.dev/packages/bloc_builder)

> bloc_builder 2 will not support stream any more, please create with flutter_live_data or use LiveData.stream()

## Helper Endpoint
### $watch
Standard Widget that re-render everytime that LiveData has updated value

(if LiveData set flag `verifyDataChange: true`, it will re-render when value has changed only)

(default value of verifyDataChange is `false`)
```dart
LiveData<int> counter = LiveData(0, verifyDataChange: false);

Widget build(BuildContext context) {
  return $watch(counter, build: (context, int count){
    return Text('counter is $count');
  });
}
```

### $watchMany

In case we want to use many LiveData like this:
```dart
LiveData<int> $a = LiveData(1);
LiveData<String?> $b = LiveData<String?>(null);
LiveData<bool> $c = LiveData(false);
```
if we using $watch for each LiveData it will cause nested $watch
```dart
$watch($a, (context, int a){
    return $watch($b, (context, String? b){
        return $watch($a, (context, bool c){
            return Text('x=$x, y=$y, z=$z');
        })
    })
})
```
for this case, there is `makeMemorize` function for grouping LiveData, you can set key of each LiveData as Symbol you wish.
```dart 
$watch(
    makeMemorize({
        #a: logic.$a,
        #b: logic.$b,
        #c: logic.$c,
    }).owner(...), build: (context, Memorize m) {
    int x = m[#a] as int;
    String? y = m[#b] as String?;
    bool z = m[#c] as bool;
    return Text('x=$x, y=$y, z=$z');
})

// or

$watchMany({
    #a: logic.$a,
    #b: logic.$b,
    #c: logic.$c,
}, owner: ..., build: (context, Memorize m) {
    int x = m[#a] as int;
    String? y = m[#b] as String?;
    bool z = m[#c] as bool;
    return Text('x=$x, y=$y, z=$z');
})
```

### $when
use when you want to render based on condition, first match $case will be render or else.
```dart
LiveData<int> counter = LiveData(0);

Widget build(BuildContext context) {
    return $when(counter) |
        $case(
            (int value) => value % 2 == 0,
            build: (context, int count){
                return Text('$count is Even');
            },
        ) |
        $case(
            (int value) => value % 2 != 0,
            build: (context, int count){
                return Text('$count is Odd');
            },
        ) |
        $else(
            build: (context, int count){
                return Text('Impossible!');
            },
        ),;
}
```
> but in some case, Dart Generic Type not apply to $case. So, we recommend you to use pattern below for best practice.

```dart
LiveData<int> counter = LiveData(0);

Widget build(BuildContext context) {
    return $when(counter)
        ..$case(
            (int value) => value % 2 == 0,
            build: (context, int count){
                return Text('$count is Even');
            },
        )
        ..$case(
            (int value) => value % 2 != 0,
            build: (context, int count){
                return Text('$count is Odd');
            },
        )
        ..$else(
            build: (context, int count){
                return Text('Impossible!');
            },
        ),
}
```

there are shorthands for reduce $when code as: `if`, `else`, `true`, `false`
```dart
$if(
    counter,
    (int value) => value % 2 == 0,
    build: (context, int count){
        return Text('$count is Even');
    },
) |
$else(
    build: (context, int count){
        return Text('$count is Odd');
    },
)


$when(isEven) |
    $true(build: (context, int count){
        return Text('$count is Even');
    }) |
    $flase(build: (context, int count){
        return Text('$count is Odd');
    }),
```

### $guard
like $when that it is conditioning from top to bottom, but with $guard allow you to make condition with difference LiveData and terminate when condition match.

for example: we want to display counter number but there are loading state and error state (if loading fail or etc.)

we can create $watch on counter normally, and separate UI of loading state and error state into $guard

```dart
LiveData<int> counter = LiveData(0);
LiveData<bool> loading = LiveData(false);
LiveData<String?> errorMessage = LiveData(null);

Widget build(BuildContext context) {
    return $guard(
        loading,
        when: (loading) => loading == true,
        build: (context, isLoading){
            return Text('now loading...');
        },
    ) |
    $guard.isNotNull(
        errorMessage,
        build: (context, msg){
            return Text('error: $msg');
        },
    ) |
    $watch(counter, build: (context, int count){
        return Text('counter is $count');
    }),
}
```
note that: from this example you will see there is `$guard` that you have to add `when` condition, and  
`$guard.isNotNull` that no `when` condition

the `isNotNull` is Guard Condition helper

#### Guard Helper
```dart
$guard.isNull
$guard.isNotNull
$guard.isEmpty // avairable for both String and List
$guard.isNotEmpty // avairable for both String and List
$guard.isTrue
$guard.isFalse
```

### $for
use for create ListView (or AnimatedList, etc.) and it will receive only LiveData that contains List
```dart
LiveData<List<String>> items = LiveData(<String>["A", "B", "C"]);

Widget build(BuildContext context) {
    return $for(items);
}
```

`$for` has option to customize List and Item

- `buildItem`: use for build Widget for each Item (default is toString Text)
- `buildList`: use for build ListView, you will receive widget that build from `buildItem` as parameter (default is ListView.builder)
- `buildEmpty`: is case list data is empty (default is None Widget)

```dart
LiveData<List<String>> items = LiveData(<String>["A", "B", "C"]);

Widget build(BuildContext context) {
  return $for(
    items,
    buildItem: (context, String item, int index){
      return Text('$item');
    },
    buildList: (context, List<ItemViewHolder<T>> holder){
      // ItemViewHolder has 2 properties
      // - T data
      // - Widget widget
      return ListView.builder(
          itemCount: holder.length,
          item.Builder: (context, int i) => holder[i].widget,
      );
    },
    buildEmpty: (context, List<String> data){
      return Text('empty!');
    },
  );
}
```

### $for with Nested LiveData
In some case, we have to modify data in each item directly.
```dart
class Item {
  int id;
  String name;
  ...
}

LiveData<List<Item>> $items = LiveData(<Item>[...]);

$for($items);

$items.value[0] = ...;
$items.tick();
```
for this example, we want to modify element index at 0

yes, you can modify object state but by concept of LiveData you have to call `tick` to notices LiveData there is some change.

**This is the problem!!**, when we call `tick` which is trigger LiveData that contains hold List, that mean it will need to re-render hold List again evenif we just modify one object in List.

Direct solution is you have to add LiveData in to you model (in this case is `Item`)

But, of cause, you don't want to modify Model class. So, there is another solution that is let LiveData handle it for you by using `eachItemsInListAsLiveData`

```dart
class Item {
  int id;
  String name;
  ...
}

LiveData<List<Item>> $items = LiveData(<Item>[...])
    .apply(eachItemsInListAsLiveData());

$for($items);

// Update List
$items.value = ...;

// Update each element
detach($items, $items.value[0])!.value = ...
```
when using `eachItemsInListAsLiveData`, after that you can get LiveData for each Item from `detach` it from parent LiveData

#### Behind the Scenes
the `eachItemsInListAsLiveData` will call `attach` that is will create LiveData based on item you give to and bind it to parent LiveData

```dart
LiveData<List<Item>> $items = LiveData(<Item>[...]);

attach($items, $items.value[0]);
attach($items, $items.value[1]);
attach($items, $items.value[2]);
...

detach($items, $items.value[0])!.value = ...
detach($items, $items.value[1])!.value = ...
detach($items, $items.value[2])!.value = ...
```
in additon,
```dart
attach($items, $items.value[0])
```
this mean we want `$items.value[0]` become LiveData and bind it to `$items`

> we have to attach LiveData to some parent LiveData, we recommend you use parent as it's own List because the new  LiveData can use LifeCycle follow it's parent

and in final, opposite with `attach` is `detach` used when you want to get LiveData back.

```dart
detach($items, $items.value[2])
```
Note that: detach return Nullable Type because there is some state that item maybe removed from list.