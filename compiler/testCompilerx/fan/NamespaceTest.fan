using compilerx

class NamespaceTest : Test
{
  Void test1()
  {
    ns := FPodNamespace(null)
    pod := ns.resolvePod("std", null)
    type := pod.resolveType("File", true)

    verify(type.name == "File")
    verify(type.doc != null)

    slot := type.slot("uri")
    verify(slot != null)
    verify(slot.doc != null)
  }
}