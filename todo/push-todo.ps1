# Push robotics learning tasks to Microsoft To Do via Graph API.
#
# Usage:
#   cd C:\Users\avezra\repro-robotics-plan\todo
#   .\push-todo.ps1
#
# On first run, a browser opens and asks you to sign in with your MSA account
# (aviadezra@hotmail.com) and consent to "Tasks.ReadWrite". The script then
# creates one To Do *list* per phase and populates each list with tasks and
# checklist subitems.
#
# Idempotent: re-running it will reuse existing lists and skip tasks whose
# title already exists in the list.

[CmdletBinding()]
param(
  [string]$DataFile = (Join-Path $PSScriptRoot 'robotics-tasks.json'),
  [switch]$WhatIf
)

$ErrorActionPreference = 'Stop'

function Ensure-Module($name) {
  if (-not (Get-Module -ListAvailable -Name $name)) {
    Write-Host "Installing module $name (CurrentUser scope)…" -ForegroundColor Cyan
    Install-Module -Name $name -Scope CurrentUser -Force -AllowClobber
  }
  Import-Module $name -ErrorAction Stop
}

Ensure-Module 'Microsoft.Graph.Authentication'

Write-Host "Connecting to Microsoft Graph (Tasks.ReadWrite)…" -ForegroundColor Cyan
Connect-MgGraph -Scopes 'Tasks.ReadWrite' -NoWelcome | Out-Null

$ctx = Get-MgContext
Write-Host "Signed in as: $($ctx.Account)" -ForegroundColor Green

if (-not (Test-Path $DataFile)) { throw "Data file not found: $DataFile" }
$data = Get-Content -Raw -Path $DataFile | ConvertFrom-Json

$baseUri = 'https://graph.microsoft.com/v1.0/me/todo/lists'
$listsResp = Invoke-MgGraphRequest -Method GET -Uri $baseUri
$existingLists = @{}
foreach ($l in $listsResp.value) { $existingLists[$l.displayName] = $l.id }

foreach ($listSpec in $data.lists) {
  $listName = $listSpec.name
  if ($existingLists.ContainsKey($listName)) {
    $listId = $existingLists[$listName]
    Write-Host "`n📋 Reusing list: $listName" -ForegroundColor Yellow
  } else {
    if ($WhatIf) {
      Write-Host "`n[WhatIf] Would create list: $listName" -ForegroundColor Magenta
      continue
    }
    $created = Invoke-MgGraphRequest -Method POST -Uri $baseUri `
      -Body (@{ displayName = $listName } | ConvertTo-Json) `
      -ContentType 'application/json'
    $listId = $created.id
    Write-Host "`n📋 Created list: $listName" -ForegroundColor Green
  }

  # Load existing task titles in this list (for idempotency).
  $tasksUri = "$baseUri/$listId/tasks?`$select=id,title&`$top=200"
  $existingTaskTitles = @{}
  $taskResp = Invoke-MgGraphRequest -Method GET -Uri $tasksUri
  foreach ($t in $taskResp.value) { $existingTaskTitles[$t.title] = $t.id }

  foreach ($task in $listSpec.tasks) {
    if ($existingTaskTitles.ContainsKey($task.title)) {
      Write-Host "  · skip (exists): $($task.title)" -ForegroundColor DarkGray
      continue
    }

    if ($WhatIf) {
      Write-Host "  [WhatIf] + Task: $($task.title)" -ForegroundColor Magenta
      if ($task.subitems) {
        foreach ($s in $task.subitems) { Write-Host "      ☐ $s" -ForegroundColor DarkMagenta }
      }
      continue
    }

    $taskBody = @{
      title = $task.title
      body  = @{ content = ($task.notes ?? ''); contentType = 'text' }
    }
    $newTask = Invoke-MgGraphRequest -Method POST `
      -Uri "$baseUri/$listId/tasks" `
      -Body ($taskBody | ConvertTo-Json -Depth 5) `
      -ContentType 'application/json'
    Write-Host "  + Task: $($task.title)" -ForegroundColor Green

    if ($task.subitems) {
      $checklistUri = "$baseUri/$listId/tasks/$($newTask.id)/checklistItems"
      foreach ($sub in $task.subitems) {
        Invoke-MgGraphRequest -Method POST -Uri $checklistUri `
          -Body (@{ displayName = $sub } | ConvertTo-Json) `
          -ContentType 'application/json' | Out-Null
      }
      Write-Host "      ($($task.subitems.Count) checklist item(s) added)" -ForegroundColor DarkGreen
    }
  }
}

Write-Host "`n✅ Done. Open Microsoft To Do to see the new lists." -ForegroundColor Cyan
Disconnect-MgGraph | Out-Null
