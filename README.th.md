# bloc_builder

เป็น wrapper class ที่ครบ StreamBuilder อยู่อีกทีและเพิ่มฟีเจอร์ Flow Control สำหรับทำให้คุมการแสดงผลใน UI ง่ายขึ้น

## Helper Endpoint
### $watch
คำสั่งมาตราฐาน จะทำการเรนเดอร์ UI ใหม่ทุกครั้งที่ LiveData มีการเซ็ตค่าใหม่เข้ามา

ยกเว้นกรณีเซ็ต LiveData ให้ verifyDataChange=true ในกรณีนี้ ค่าใน LiveData จะต้องเปลี่ยนไปจากเดิมเท่านั้นถึงจะมีการเรนเดอร์ใหม่

(verifyDataChange มีค่าเริ่มต้นเป็น false)
```dart
LiveData<int> counter = LiveData(0, verifyDataChange: false);

Widget build(BuildContext context) {
    return $watch(counter, build: (_, int count){
        return Text('counter is $count');
    });
}
```

### $watchMany

ในกรณีที่ต้องใช้ค่าจาก LiveData หลายตัว เช่น
```dart
LiveData<int> $a = LiveData(1);
LiveData<String?> $b = LiveData<String?>(null);
LiveData<bool> $c = LiveData(false);
```
จะใช้ $watch ทีละตัวก็ได้แต่ก็จะทำให้โค้ดเป็น nested $watch ได้
```dart
$watch($a, (_, int a){
    return $watch($b, (_, String? b){
        return $watch($a, (_, bool c){
            return Text('x=$x, y=$y, z=$z');
        })
    })
})
```
ในกรณีนี้เราสามารถใช้คำสั่ง `makeMemorize` เพื่อสร้างกลุ่มของ LiveData ขึ้นมาได้

โดย key จะต้องสร้างเป็น Symbol (สามารถตั้งชื่ออะไรก็ได้)
```dart 
$watch(
    makeMemorize({
        #a: logic.$a,
        #b: logic.$b,
        #c: logic.$c,
    }).owner(...), build: (_, Memorize m) {
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
}, owner: ..., build: (_, Memorize m) {
    int x = m[#a] as int;
    String? y = m[#b] as String?;
    bool z = m[#c] as bool;
    return Text('x=$x, y=$y, z=$z');
})
```

### $when
ใช้กับกรณีที่ LiveData มีเงื่อนไขในการเรนเดอร์

สามารถสร้าง case ที่ตรงกับเงื่อนไขได้
```dart
LiveData<int> counter = LiveData(0);

Widget build(BuildContext context) {
    return $when(counter) |
        $case(
            (int value) => value % 2 == 0,
            build: (, int count){
                return Text('$count is Even');
            },
        ) |
        $case(
            (int value) => value % 2 != 0,
            build: (, int count){
                return Text('$count is Odd');
            },
        ) |
        $else(
            build: (_, int count){
                return Text('Impossible!');
            },
        ),;
}
```
แต่เนื่องจากข้อจำกัดการเขียน Generic ใน Dart ทำให้การเขียนรูปแบบข้างบนไม่เช็ก Type ตัวแปร ดังนั้นแนะนำว่าถ้าเขียน when ให้ใช้โค้ดแบบด้านล่างจะดีกว่า

```dart
LiveData<int> counter = LiveData(0);

Widget build(BuildContext context) {
    return $when(counter)
        ..$case(
            (int value) => value % 2 == 0,
            build: (_, int count){
                return Text('$count is Even');
            },
        )
        ..$case(
            (int value) => value % 2 != 0,
            build: (_, int count){
                return Text('$count is Odd');
            },
        )
        ..$else(
            build: (_, int count){
                return Text('Impossible!');
            },
        ),
}
```

มี shorthand สำหรับ when ให้ใช้คือ `if`, `else`, `true`, `false`
```dart
$if(
    counter,
    (int value) => value % 2 == 0,
    build: (_, int count){
        return Text('$count is Even');
    },
) |
$else(
    build: (_, int count){
        return Text('$count is Odd');
    },
)


$when(isEven) |
    $true(build: (_, int count){
        return Text('$count is Even');
    }) |
    $flase(build: (_, int count){
        return Text('$count is Odd');
    }),
```

### $guard
คล้ายๆ กับ when แต่เป็นการเช็กเงื่อนไข (ตามลำดับจากบนลงล่าง) ถ้าตรงกับเงื่อนไขจะหยุดแค่ block นั้นและเรนเดอร์ UI ออกมาเลย

เช่น เรามี counter อยู่เป็นข้อมูลที่ต้องการแสดงผล แต่อาจจะต้องรอโหลดหรือโหลดข้อมูลมาแล้วมี error ที่ทำให้ไม่สามารถแสดงผลได้

เราก็เขียน guard สำหรับเช็กว่าตอนนี้มีการ loading หรือ error อยู่มั้ยขึ้นมาก่อนจะ $watch ตอนสุดท้ายอีกที
```dart
LiveData<int> counter = LiveData(0);
LiveData<bool> loading = LiveData(false);
LiveData<String?> errorMessage = LiveData(null);

Widget build(BuildContext context) {
    return $guard(
        loading,
        when: (loading) => loading == true,
        build: (, isLoading){
            return Text('now loading...');
        },
    ) |
    $guard.isNotNull(
        errorMessage,
        build: (, msg){
            return Text('error: $msg');
        },
    ) |
    $watch(counter, build: (_, int count){
        return Text('counter is $count');
    }),
}
```
guard จะต้องเขียน when เป็น condition เสมอ แต่สำหรับ general case สามารถใช้ helper ด้านล่างนี่แทนได้
#### Guard Helper
```dart
$guard.isNull
$guard.isNotNull
$guard.isEmpty // ใช้ได้กับทั้ง String และ List
$guard.isNotEmpty // ใช้ได้กับทั้ง String และ List
$guard.isTrue
$guard.isFalse
```

### $for
ใช้สำหรับสร้าง ListView

LiveData ที่รับเข้าไปจะต้องเป็น List เท่านั้น
```dart
LiveData<List<String>> items = LiveData(<String>["A", "B", "C"]);

Widget build(BuildContext context) {
    return $for(items);
}
```

for มี option สำหรับการสร้าง ListView คือ

- buildItem: ใช้สำหรับสร้าง Widget ของ Item แต่ละชิ้น (default เป็นการนำ Item ไป toString และแสดงเป็น Text)
- buildList: ใช้สำหรับสร้าง ListView โดยได้รับ widget จากที่สร้างใน buildItem มาเป็น parameter อีกที (default เป็นการสร้างด้วย ListView.builder ตรงๆ)
- buildEmpty: ใช้สำหรับสร้าง UI ในกรณีที่ List ไม่มีข้อมูลอะไรอยู่เลย (default เป็น None Widget)

```dart
LiveData<List<String>> items = LiveData(<String>["A", "B", "C"]);

Widget build(BuildContext context) {
    return $for(
        items,
        buildItem: (_, String item, int index){
            return Text('$item');
        },
        buildList: (_, List<ItemViewHolder<T>> holder){
            // ItemViewHolder has 2 properties
            // - T data
            // - Widget widget
            return ListView.builder(
                itemCount: holder.length,
                item.Builder: (_, int i) => holder[i].widget,
            );
        },
        buildEmpty: (_, List<String> data){
            return Text('empty!');
        },
    );
}
```

### $for with Nested LiveData
มีบางครั้งที่เราต้องการแก้ไขข้อมูลตรงๆ ที่ elemment ใน List เช่น
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
ต้องการจะแก้ไขข้อมูล element index ที่ 0

ซึ่งสามารถแก้ไขได้ แต่ LiveData จะรู้ว่ามีการเปลี่ยนแปลงค่า เลยต้องสั่ง `tick` อีกที

แต่ปัญหาคือเราสั่ง `tick` ที่ List ทำให้ลิสต์ทั้งตัวต้องเรนเดอร์ใหม่ทั้งหมด

ในกรณีนี้ถ้าเราต้องการทำให้มันแก้ไขเฉพาะบาง element แล้วเรนเดอร์ใหม่เป็นบางตัวได้ เราต้องเอา LiveData ครอบแต่ละ element ในลิสต์ลงไปอีกที

แต่ถ้าเราไม่อยากทำเอง (หมายถึงใส่ LiveData ลงไปใน model ด้วย ซึ่งไม่ควรทำแบบนั้น) ก็จะมีคำสั่ง `eachItemsInListAsLiveData` ให้ใช้

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
เมื่อสั่ง `eachItemsInListAsLiveData` ไปแล้วก็สามารถขอ LiveData ที่ครอบแต่ละ element ได้จากการสั่ง `detach` เลย

#### Behind the Scenes
เบื่องหลังของคำสั่ง `eachItemsInListAsLiveData` คือคำสั่ง `attach` ซึ่งเป็นคำสั่งที่เอาไว้สำหรับสร้าง LiveData ครอบลงไปใน Object ตัวที่ใส่เข้าไป
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
เช่นการสั่ง
```dart
attach($items, $items.value[0])
```
หมายความว่า เราต้องการจะให้ `$items.value[0]` กลายเป็น LiveData ด้วย และฝาก LiveData ตัวนี้ไว้กับ $items ให้ช่วยถือไว้ให้

> เราจะต้อง attach LiveData ที่สร้างใหม่ไว้กับ LiveData สักตัวหนึ่ง ซึ่งแนะนำให้ฝากไว้กับ parent ของมันเอง เพราะ LiveData ตัวที่สร้างใหม่จะได้ใช้ LifeCycle ตาม parent ที่ถือมันอยู่อีกทีหนึ่ง

ดังนั้นถ้าเราต้องการจะดึง LiveData ออกมา ก็จะใช้คำสั่งที่กลับกับ `attach` นั่นคือ `detach`

```dart
detach($items, $items.value[2])
```
ซึ่งจะให้ค่าออกมาเป็น Nullable เสมอ เพราะมีโอกาสที่ข้อมูลใน List อาจจะเปลี่ยนไปแล้ว LiveData ที่เคย attach ไว้อาจจะโดนลบไปแล้ว