# This is just an example to get you started. A typical hybrid package
# uses this file as the main entry point of the application.

import std/random

import uing
import uing/rawui

import assman/submodule

proc createWindow(): uing.Window =
  return uing.newWindow("AssMan", 800, 600, hasmenubar = true)

proc createMenuBar(): seq[uing.Menu] =
  ## Create menu bar.
  ##
  ## .. important::
  ##    Menu objects must not be gathered by GC, so we must keep a variable, pointing to them.

  let openMenu = uing.newMenu("File")
  openMenu.addItem(
    "Open",
    proc(_: uing.MenuItem, window: uing.Window) =
      let filename = window.openFile()

      if filename.len == 0:
        window.error("No file selected", "Text with some details goes here.")
      else:
        window.msgBox("File selected", filename)
  )

  let editMenu = newMenu("Edit")
  editMenu.addCheckItem("Checkable Item")
  editMenu.addSeparator()
  disable editMenu.addItem("Disabled Item")
  editMenu.addPreferencesItem()

  let aboutMenu = uing.newMenu("About")
  aboutMenu.addItem("Help")
  aboutMenu.addAboutItem()

  return @[openMenu, editMenu, aboutMenu]

proc modelNumColumns(mh: ptr uing.TableModelHandler, m: ptr rawui.TableModel): cint {.cdecl.} =
  return cint(random.rand(1..20))

proc modelNumRows(mh: ptr TableModelHandler, m: ptr rawui.TableModel): cint {.cdecl.} = 10

proc modelColumnType(
  mh: ptr TableModelHandler,
  m: ptr rawui.TableModel,
  col: cint,
): uing.TableValueType {.cdecl.} =
  return uing.TableValueTypeString

proc modelCellValue(mh: ptr TableModelHandler, m: ptr rawui.TableModel, row, col: cint): ptr rawui.TableValue {.cdecl.} =
  case col:
    of 0:
      result = newTableValue($random.rand(0..100)).impl
    of 1:
      result = newTableValue("path/to/project").impl
    else:
      result = newTableValue("None").impl

proc modelSetCellValue(mh: ptr TableModelHandler, m: ptr rawui.TableModel, row, col: cint, val: ptr rawui.TableValue) {.cdecl.} =
  return

proc main =
  let menuBar = createMenuBar()
  let window = createWindow()

  let label = uing.newLabel(getWelcomeMessage())
  let tab = uing.newTab()
  let inner = uing.newVerticalBox()

  window.margined = true
  window.child = inner

  let projects = uing.newHorizontalBox()

  var mh: uing.TableModelHandler
  mh.numColumns = modelNumColumns
  mh.numRows = modelNumRows
  mh.columnType = modelColumnType
  mh.cellValue = modelCellValue
  mh.setCellValue = modelSetCellValue

  var p: uing.TableParams
  p.model = uing.newTableModel(addr mh).impl

  let projectsTable = uing.newTable(addr p)
  projectsTable.addTextColumn("ID", 0, uing.TableModelColumnNeverEditable)
  projectsTable.addTextColumn("Path", 1, uing.TableModelColumnNeverEditable)

  projects.add(projectsTable, true)
  tab.add("Projects", projects)

  tab.add "Assets", uing.newHorizontalBox()
  tab.add "Somethings", uing.newHorizontalBox()

  inner.add(tab, true)
  inner.add(label)

  uing.show(window)
  uing.mainLoop()

when isMainModule:
  uing.init()
  main()
