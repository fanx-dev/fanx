
class NamespaceTest : Test
{
  Void test1()
  {
    ns := FPodNamespace(null)
    pod := ns.resolvePod("std", null)
    type := pod.resolveType("File", true)

    echo(type)
    echo(type.doc)

    slot := type.slot("uri")
    echo(slot)
    echo(slot.doc)
  }
}