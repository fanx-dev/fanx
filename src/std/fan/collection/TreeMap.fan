//
// Copyright (c) 2017, chunquedong
// Licensed under the LGPL
// History:
//   2017-1-21  Jed Young  Creation
//

internal class AvlNode {
  Obj? key
  Obj? val
  Int height
  AvlNode? right
  AvlNode? left

  new make(Obj? key, Obj? val) {
    height = 0
    right = null
    left = null
    this.key = key
    this.val = val
  }

  Void resetHeight() {
    this.height = TreeMap.getHeight(left).max(TreeMap.getHeight(right))+1
  }

  Bool isBalanced() {
    (TreeMap.getHeight(left)-TreeMap.getHeight(right)).abs < 2
  }
}

**
** AVL Tree (named after inventors Adelson-Velsky and Landis) is an balanced binary tree.
**
class TreeMap<K,V> : Map<K,V> {
  private AvlNode? root := null

  private Bool readOnly
  private Bool immutable

  protected Bool keySafe := true

  protected override Void modify() {
    if (readOnly) {
      throw ReadonlyErr()
    }
  }

  new make() {
  }

  override Int size { private set }

  internal static Int getHeight(AvlNode? N) {
    if (N == null) return -1
    return N.height
  }

  private static Int max(Int a, Int b) { a.max(b) }

  **
  **
  **      K2
  **     / \
  **    K1  c
  **   / \
  **  a   b
  ** /
  **
  **     K1
  **    / \
  **   a   K2
  **  /   / \
  **     b   c
  **
  private AvlNode LL(AvlNode K2) {
    //AvlNode K1 := AvlNode()
    K1 := K2.left
    K2.left = K1.right
    K1.right  = K2

    K2.resetHeight
    K1.resetHeight
    return K1
  }

  **
  **      K1
  **     / \
  **    a   K2
  **       /  \
  **      b    c
  **            \
  **
  **      K2
  **     / \
  **    K1  c
  **   / \   \
  **  a   b
  **
  **
  private AvlNode RR(AvlNode K1) {
    //AvlNode K2 := AvlNode()
    K2 := K1.right
    K1.right = K2.left
    K2.left  = K1

    K1.resetHeight
    K2.resetHeight
    return K2
  }

  **
  **
  **      K3
  **     / \
  **    K1
  **   / \
  **      K2
  **
  **        K3
  **       /  \
  **      K2
  **     / \
  **    K1
  **
  **      K2
  **     /  \
  **    K1   K3
  **
  private AvlNode LR(AvlNode K3) {
    K3.left = RR(K3.left)
    return LL(K3)
  }

  **
  **
  **      K1
  **     / \
  **        K2
  **       / \
  **      K3
  **
  **      K1
  **     / \
  **        K3
  **        / \
  **          K2
  **
  **      K3
  **     /  \
  **    K1   K2
  **
  private AvlNode RL(AvlNode K1) {
    K1.right = LL(K1.right)
    return RR(K1)
  }

  **
  ** insert into node and return root
  **
  private AvlNode insertAt(K k, V v, AvlNode? T, Bool overwrite) {
    if( T == null) {
      T = AvlNode(k, v)
      ++size
    }
    else if(k < T.key) {
      T.left = insertAt(k, v, T.left, overwrite);
      if(!T.isBalanced) {
        if(k < T.left.key )
           T = LL(T);
        else
           T = LR(T);
      }
    }
    else if(k > T.key ) {
      T.right = insertAt(k, v, T.right, overwrite);
      if (!T.isBalanced) {
        if(k > T.right.key )
           T = RR(T);
        else
           T = RL(T);
      }
    }
    else {
      if (overwrite) {
        T.key = k
        T.val = v
      }
      else {
        throw ArgErr("$v already exits")
      }
    }
    T.resetHeight
    return T
  }

  override This set(K key, V val) {
    modify
    if (keySafe && !key.isImmutable)
      throw NotImmutableErr("key is not immutable: ${key.typeof}")
    root = insertAt(key, val, root, true)
    return this
  }

  **
  ** find and remove in node and return root. save old value to 'old'
  **
  private AvlNode? deleteAt(K k, AvlNode? T, AvlNode? old) {
    if(T == null) return null

    //在左子树上找；
    if(k < T.key) {
      T.left = deleteAt(k, T.left, old)

      //调整平衡；
      if(!T.isBalanced) {
        if(getHeight(T.right.left) > getHeight(T.right.right))
          T=RL(T);
        else
          T=RR(T);
      }
    }
    //在右子树上找;
    else if (k > T.key ) {
      T.right = deleteAt(k, T.right, old)

      //调整平衡；
      if(!T.isBalanced)
      {
        if(getHeight(T.left.right) > getHeight(T.left.left))
          T=LR(T);
        else
          T=LL(T);
      }
    }
    //删除当前结点；
    else if (k == T.key ) {
      if (T.left != null && T.right != null) {
        //在右子树中找一个最小值的结点
        temp := T.right
        while (temp.left != null) temp = temp.left
        if (old != null) {
          old.val = T.val
          old.key = T.key
        }
        //把右子树中最小节点的值赋值给本节点
        T.key = temp.key
        T.val = temp.val
        //删除右子树中最小值的节点
        T.right = deleteAt(temp.key, T.right, null)

        //调整平衡；
        if(!T.isBalanced)
        {
          if(getHeight(T.left.right) > getHeight(T.left.left))
            T=LR(T);
          else
            T=LL(T);
        }
      }
      else if (T.left != null && T.right == null) {
        T = T.left
      }
      else if (T.left == null && T.right != null) {
        T = T.right
      }
      else {
        //叶子结点
        T = null
      }
    }

    //调整树高
    if(T != null) T.resetHeight
    return T
  }

  override V? remove(K e) {
    modify
    old := AvlNode(null, null)
    root := deleteAt(e, root, old)
    if (root.key == e) {
      size--
    }
    return old.val
  }

  private AvlNode? searchAt(K x, AvlNode? T) {
    if(T == null) return null
    if(T.key == x) return T
    if(x < T.key ) return searchAt(x, T.left)
    if(x > T.key ) return searchAt(x, T.right)
    return null
  }

  override V? get(K k, V? defValue := super.defV) {
    node  := searchAt(k, root)
    if (node == null) return defValue
    return node.val
  }

  override Bool containsKey(K k) {
    node  := searchAt(k, root)
    return node != null
  }

  override This add(K key, V val) {
    modify
    if (keySafe && !key.isImmutable)
      throw NotImmutableErr("key is not immutable: ${key.typeof}")
    root = insertAt(key, val, root, false)
    return this
  }

  private Void travel(|V,K| f, AvlNode? T) {
    if (T == null) return
    travel(f, T.left)
    f(T.val, T.key)
    travel(f, T.right)
  }

  override Void each(|V,K| f) {
    travel(f, root)
  }

  override This clear() {
    modify
    size = 0
    root = null; return this
  }

  private Obj? travelWhile(|V,K->Obj?| f, AvlNode? T) {
    if (T == null) return null
    res := travelWhile(f, T.left)
    if (res != null) return res

    res = f(T.val, T.key)
    if (res != null) return res

    res = travelWhile(f, T.right)
    return res
  }

  override Obj? eachWhile(|V val, K key->Obj?| c) {
    return travelWhile(c, root)
  }

  override K[] keys() {
    list := List.make(size)
    each |v,k| {
      list.add(k)
    }
    return list
  }

  override V[] vals() {
    list := List.make(size)
    each |v,k| {
      list.add(v)
    }
    return list
  }

  protected override This createEmpty() {
    return TreeMap()
  }

  override Bool isRO() { readOnly }

  override This ro() {
    if (isRO) return this
    TreeMap<K,V> nmap := dup
    nmap.readOnly = true
    return nmap
  }

  override This rw() {
    if (isRW) return this
    TreeMap<K,V> nmap := dup
    nmap.readOnly = false
    return nmap
  }

  override Bool isImmutable() {
    return immutable
  }

  override [K:V] toImmutable() {
    if (immutable) return this
    nmap := createEmpty()
    each |v,k| {
      nmap.set(k?.toImmutable, v?.toImmutable)
    }
    nmap.defV = defV
    nmap.readOnly = true
    nmap.immutable = true
    return nmap
  }

  /*
  static Void test() {
    t := TreeMap<Int,Str>()
    1000.times {
      i := Int.random(0..10)
      t.set(i, i.toStr)
    }
    x := t.get(5)
    echo("5: $x")
    t.remove(5)
    t.each |v| {
       echo(v)
    }
  }
  */
}