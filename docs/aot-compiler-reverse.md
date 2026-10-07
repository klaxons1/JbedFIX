# Реверс встроенного Jbed AOT-компилятора

## Что именно находится в `libjbedvm.so`

Это не отдельный ELF-компилятор и не JNI-библиотека, которую можно запустить
как `jbedc`. Встроенный компилятор является частью ROM-образа Jbed: Java-классы
AMS, ZIP/JAR-инсталлятора, verifier-а и backend-а заранее скомпилированы самим
Jbed в ARM-образ. Во время установки MIDlet этот код читает обычные class-файлы
из JAR и создаёт Jbed-specific code/storage representation.

Подтверждённые компоненты ROM-образа:

- `Compiler`, `ClassAccess`, `ClassRefTable`, `JarReader`, `ZipFile`,
  `ZipFileData`, `JarLoader`, `ClassLoader`;
- backend-и `JBedFCoderThumb`, `JBedFastCoder`, `FCoder`,
  `ArchCodeBlockWriter`, `DirectCodeBlockWriter`, `CodeBlockWriter`,
  `XipBlockStreamWriter`, `HeapCodeBlocks`;
- compiler pipeline names: `precompile`, `compile`, `precompileJarFile`,
  `installStepPrecompile`, `prepareJarFile`, `prepareJarCompileToRam`,
  `parseClass`, `checkClassSanity`, `resolveClassIds`, `startCompile`,
  `compileDirect`, `PrepareClass`, `TranslateMethod`, `allocateCode`,
  `GenFixup`, `fixupCode`, `flushFixups`, `writeClassObj`, `getStackMap`,
  `getCodeRanges`;
- output/runtime metadata names: `codeBlock`, `codeRanges`, `stackMap`,
  `stackmaps`, `staticCodeChains`, `dynCodeChains`, `classRefTables`,
  `methodCodeRanges`, `codeLength`, `actualCodeSize`, `writtenStackMaps`,
  `newCodeBlockAdr`, `allocFromEnd`, `runningCodeAnchor`.

Таким образом, текущий `StackOverflowError` во время
`STEP_PRECOMPILE` действительно возникает внутри встроенного Java-level
installer/compiler pipeline, а не в Android Java installer, который сейчас
обходит его через `LocalSuiteInstaller`.

## ROM metadata tables

В этой версии библиотеки обнаружены пять таблиц с заголовком и bucket-массивом:

| таблица | ELF/file offset | header | buckets | начало данных |
|---|---:|---:|---:|---:|
| package prefixes | `0x26256c` | `0x8735` | 32 | `0x2625f0` |
| class names | `0x262c8c` | `0x18748` | 256 | `0x263090` |
| signatures/typed records | `0x266850` | `0x8649` | 512 | `0x267054` |
| member names | `0x269814` | `0x874b` | 2048 | `0x26b818` |
| field/constants names | `0x2813e8` | `0x874b` | 2048 | `0x2833ec` |

Количество bucket-ов вычисляется как `1 << (header & 0xf)`. Каждая непустая
ячейка содержит указатель на цепочку. Имя начинается с compact length prefix:
`0x80 | length`, затем идут ASCII-байты. Нулевой байт завершает цепочку.
Это объясняет, почему обычный `strings` показывает имена, но не показывает их
ID и принадлежность к классу.

В `docs/libjbedvm.so.c` generic lookup этой структуры находится в
`sub_12A384`: он декодирует 7-bit length, сравнивает строку и возвращает
табличный slot. Это уже восстановлено достаточно, чтобы связывать строки
`Compiler`/`installStepPrecompile` с их bucket и offset.

Для автоматического извлечения таблиц используется:

```text
python3 tools/extract_jbed_aot.py lib/armeabi/libjbedvm.so
```

Скрипт намеренно пока не пишет новый compiled suite: он извлекает ROM metadata,
compiler class/member inventory и offsets, не выдавая догадки за формат output.

## Восстановленный pipeline

По именам классов, полям и статическим таблицам восстанавливается следующая
последовательность:

```text
requestInstall
  -> installStepGetJar1 / installStepGetJar2
  -> ZipFile / JarReader / prefetchZipTable
  -> installStepParseManifest / parseMetaDataFromNative
  -> checkClassSanity / verifyJar / verifier + class loading
  -> prepareJarFile / loadJAR / parseClass
  -> resolveClassIds / prepareJarCompileToRam
  -> startCompile / PrepareClass
  -> TranslateMethod / compileDirect / allocateCode
  -> stack-map generation + code ranges + class references
  -> GenFixup / fixupCode / flushFixups
  -> writeClassObj + compiled sidecar/object storage
  -> compileDone / notifyMIDletPrecompileComplete
```

Существуют как минимум три backend-пути, на что указывают `ArchCodeBlockWriter`,
`DirectCodeBlockWriter` и `XipBlockStreamWriter`. `JBedFCoderThumb` означает
ARM Thumb-specific code emission. `compileToRam`, `moveHeapBlock`, `allocFromEnd`
и `prepareJarCompileToRam` показывают, что компилятор сначала может собирать
code blocks в RAM, а затем переносить их в persistent/XIP representation.

## Что уже доказано и что ещё нельзя честно утверждать

Доказано статическим анализом:

1. class-файлы JAR не исполняются напрямую как стандартный JVM bytecode;
2. installer имеет отдельную фазу `STEP_PRECOMPILE`;
3. JAR проходит ZIP reader, class parser, verifier, linker/class-ID resolver,
   compiler, stack-map/fixup и запись class/code objects;
4. backend выбирается под ARM Thumb и хранит code blocks, ranges, fixups,
   stack maps и ссылки на классы;
5. таблицы имён и typed/signature tables встроены в ROM image и доступны для
   дальнейшего автоматического анализа.

Пока не доказаны точные значения полей compiled-suite storage и точный bytecode
для всех ARM Thumb instructions. Для этого нужен как минимум один настоящий
результат `STEP_PRECOMPILE` с устройства: sidecar-файлы установленного MIDlet,
их размеры и содержимое, а также `installed-layout.txt`/`jbed.log`. В репозитории
есть исходный JAR `assets/Installed/t0_.jar`, но это theme JAR и он не содержит
созданного device-side compiled object.

Следующий этап полного reverse — снять на устройстве один controlled install,
скопировать все файлы одного suite и сопоставить их с `writeClassObj`,
`codeRanges`, `stackMap` и `classRefTables`. После этого можно написать
декодер compiled storage и проверить, возможно ли заменить только installer
writer, не реализуя весь ARM backend заново.
