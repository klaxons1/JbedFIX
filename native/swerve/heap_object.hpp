#ifndef JBED_SWERVE_HEAP_OBJECT_HPP
#define JBED_SWERVE_HEAP_OBJECT_HPP

#include "engine.h"
#include "platform.h"
#include <cstring>
#include <new>
#include <type_traits>

enum EssLeave { ELeave };
enum EssNoLeave { ENoLeave };

void *operator new(size_t bytes, EssLeave);
void *operator new[](size_t bytes, EssLeave);
void *operator new(size_t bytes, EssNoLeave) noexcept;

class CssHeapObject {
public:
    static void *operator new(size_t bytes, EssLeave = ELeave);
    static void *operator new[](size_t bytes, EssLeave = ELeave);
    static void operator delete(void *object) noexcept;
    static void operator delete[](void *objects) noexcept;
    virtual ~CssHeapObject() = default;
};

class CssArrayBase : public CssHeapObject {
public:
    void *data = nullptr;
    int size = 0;
    union { int capacity = 0; void *pending_data; };

    int Size() const { return size; }
    ~CssArrayBase() override;
    virtual void SetStorageSize(int count, int preserve);
    virtual void CopyArray(void *src, void *dst, int count) = 0;
    virtual void *Allocate(int count) = 0;
    virtual void Destroy(void *storage) = 0;

    void SetSize(int count);
    void SetSizeDoubling(int count);
    void Reserve(int count);
    void Compact() { Reserve(size); }
    int appendSlot()
    {
        if (size == capacity) SetStorageSize(cActualElements(size + 1, capacity), size);
        return size++;
    }
    static int cActualElements(int minimum, int capacity);
};

template<class T>
class CssArray : public CssArrayBase {
public:
    ~CssArray() override
    {
        Destroy(data);
        if (size == -1) Destroy(pending_data);
    }
    void Destroy(void *storage) override
    {
        static_assert(std::is_trivially_destructible_v<T>);
        swvFree(storage);
    }
    T *Pointer() const { return static_cast<T *>(data); }
    T &operator[](int i) { return static_cast<T *>(data)[i]; }
    const T &operator[](int i) const { return static_cast<const T *>(data)[i]; }
    void CopyArray(void *src, void *dst, int count) override
    {
        auto *from = static_cast<const T *>(src);
        auto *to = static_cast<T *>(dst);
        const uintptr_t s = reinterpret_cast<uintptr_t>(from);
        const uintptr_t d = reinterpret_cast<uintptr_t>(to);
        const size_t bytes = sizeof(T) * static_cast<size_t>(count);
        if (d + bytes <= s || s + bytes <= d) {
            swvMemCpy(dst, src, bytes);
        } else if (s < d) {
            for (int i = count; i > 0; --i) to[i - 1] = from[i - 1];
        } else if (s > d) {
            for (int i = 0; i < count; ++i) to[i] = from[i];
        }
    }
    void *Allocate(int count) override
    {
        const size_t bytes = sizeof(T) * static_cast<size_t>(count);
        void *storage = ::operator new[](bytes, ELeave);
        return ::new (storage) T[count];
    }
    T &append()
    {
        return (*this)[appendSlot()];
    }
    void Remove(int index) { (*this)[index] = (*this)[--size]; }
    void RemoveRetainOrder(int index)
    {
        if (index < --size)
            CopyArray(Pointer() + index + 1, Pointer() + index, size - index);
    }
    void Append(const T &value) { (*this)[appendSlot()] = value; }
    void Insert(int index, const T &value)
    {
        if (index == size) {
            Append(value);
            return;
        }
        if (size == capacity) SetStorageSize(cActualElements(size + 1, capacity), size);
        CopyArray(Pointer() + index, Pointer() + index + 1, size - index);
        ++size;
        (*this)[index] = value;
    }
    CssArray &operator=(const CssArray &other)
    {
        SetSize(other.size);
        if (size > 0) CopyArray(other.data, data, size);
        return *this;
    }
};

template<class T>
class CssStack : public CssHeapObject {
public:
    CssArray<T> items;
};

class CssCleanupStackInstance;

class CssCleanupStackManager {
public:
    static void operator delete(void *address) noexcept { swvFree(address); }
    CssCleanupStackManager();
    virtual ~CssCleanupStackManager();
    static CssCleanupStackManager *Initialize();
    static CssCleanupStackManager *GetInstance();
    static CssCleanupStackManager *GetInstanceNoLeave();
    static void DestroyInstance();
    static void Push(CssHeapObject *object) { GetInstance()->PushInternal(object); }
    static void Pop(CssHeapObject *object) { GetInstance()->PopInternal(object); }
    void PushInternal(CssHeapObject *object);
    void PopInternal(CssHeapObject *object);
    void PushStackFrame();
    void PopStackFrame();
    void Cleanup();
private:
    CssArray<CssCleanupStackInstance *> lists;
    int depth = 0;
    bool live = false;
};

template<class T>
class CssHeapPtr {
public:
    explicit CssHeapPtr(T *object) : object(object)
    {
        if (object) CssCleanupStackManager::Push(object);
    }
    ~CssHeapPtr()
    {
        if (object) {
            CssCleanupStackManager::Pop(object);
            delete object;
        }
    }
    CssHeapPtr(const CssHeapPtr &) = delete;
    CssHeapPtr &operator=(const CssHeapPtr &) = delete;
    T *get() const { return object; }
    T &operator*() const { return *object; }
    T *operator->() { return object; }
    T *release()
    {
        T *result = object;
        if (object) {
            CssCleanupStackManager::Pop(object);
            object = nullptr;
        }
        return result;
    }
private:
    T *object;
};

#endif
