# Direct device-code flow against Microsoft identity platform, printing the
# user_code via Write-Host (so it shows up in agent-captured output).
# Then uses the resulting access token to call the Microsoft Graph To Do APIs.

[CmdletBinding()]
param(
  [string]$DataFile = (Join-Path $PSScriptRoot 'robotics-tasks.json'),
  [switch]$WhatIf,
  # Microsoft Graph PowerShell SDK public client (works for personal MSA + work).
  [string]$ClientId = '14d82eec-204b-4c2f-b7e8-296a70dab67e',
  [string]$Tenant   = 'common'
)

$ErrorActionPreference = 'Stop'
$scope = 'Tasks.ReadWrite offline_access openid profile'

Write-Host "Requesting device code from Microsoft…" -ForegroundColor Cyan
$dc = Invoke-RestMethod -Method POST `
  -Uri "https://login.microsoftonline.com/$Tenant/oauth2/v2.0/devicecode" `
  -Body @{ client_id = $ClientId; scope = $scope } `
  -ContentType 'application/x-www-form-urlencoded'

Write-Host ""
Write-Host "=============================================================" -ForegroundColor Yellow
Write-Host "  OPEN: $($dc.verification_uri)" -ForegroundColor Yellow
Write-Host "  CODE: $($dc.user_code)" -ForegroundColor Yellow
Write-Host "  (sign in as aviadezra@hotmail.com)" -ForegroundColor Yellow
Write-Host "=============================================================" -ForegroundColor Yellow
Write-Host ""

$expires = (Get-Date).AddSeconds([int]$dc.expires_in)
$interval = [int]$dc.interval
$token = $null

while ((Get-Date) -lt $expires) {
  Start-Sleep -Seconds $interval
  try {
    $token = Invoke-RestMethod -Method POST `
      -Uri "https://login.microsoftonline.com/$Tenant/oauth2/v2.0/token" `
      -Body @{
        grant_type  = 'urn:ietf:params:oauth:grant-type:device_code'
        client_id   = $ClientId
        device_code = $dc.device_code
      } `
      -ContentType 'application/x-www-form-urlencoded'
    if ($token.access_token) { break }
  } catch {
    $errText = $_.ErrorDetails.Message
    $err = $null
    if ($errText) { try { $err = $errText | ConvertFrom-Json } catch {} }
    switch ($err.error) {
      'authorization_pending' { Write-Host "  …waiting for sign-in" -ForegroundColor DarkGray; continue }
      'slow_down'             { $interval += 5; continue }
      'expired_token'         { throw "Device code expired before sign-in." }
      'authorization_declined'{ throw "Sign-in declined by user." }
      default                 { throw ("Token poll failed: " + ($err.error_description ?? $errText)) }
    }
  }
}

if (-not $token.access_token) { throw "Did not receive an access token within the time limit." }

$headers = @{ Authorization = "Bearer $($token.access_token)" }
Write-Host "`n✅ Got access token (expires in $($token.expires_in)s)." -ForegroundColor Green

if (-not (Test-Path $DataFile)) { throw "Data file not found: $DataFile" }
$data = Get-Content -Raw -Path $DataFile | ConvertFrom-Json

$baseUri = 'https://graph.microsoft.com/v1.0/me/todo/lists'
$listsResp = Invoke-RestMethod -Method GET -Uri $baseUri -Headers $headers
$existingLists = @{}
foreach ($l in $listsResp.value) { $existingLists[$l.displayName] = $l.id }

$listsCreated = 0; $tasksCreated = 0; $tasksSkipped = 0; $subitemsCreated = 0

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
    $created = Invoke-RestMethod -Method POST -Uri $baseUri -Headers $headers `
      -Body (@{ displayName = $listName } | ConvertTo-Json) `
      -ContentType 'application/json'
    $listId = $created.id
    $listsCreated++
    Write-Host "`n📋 Created list: $listName" -ForegroundColor Green
  }

  $tasksUri = "$baseUri/$listId/tasks"
  $existingTaskTitles = @{}
  $taskResp = Invoke-RestMethod -Method GET -Uri $tasksUri -Headers $headers
  foreach ($t in $taskResp.value) { $existingTaskTitles[$t.title] = $t.id }

  foreach ($task in $listSpec.tasks) {
    if ($existingTaskTitles.ContainsKey($task.title)) {
      Write-Host "  · skip (exists): $($task.title)" -ForegroundColor DarkGray
      $tasksSkipped++
      continue
    }
    if ($WhatIf) {
      Write-Host "  [WhatIf] + Task: $($task.title)" -ForegroundColor Magenta
      continue
    }
    $taskBody = @{
      title = $task.title
      body  = @{ content = ($task.notes ?? ''); contentType = 'text' }
    } | ConvertTo-Json -Depth 5
    $newTask = Invoke-RestMethod -Method POST -Uri "$baseUri/$listId/tasks" `
      -Headers $headers -Body $taskBody -ContentType 'application/json'
    $tasksCreated++
    Write-Host "  + Task: $($task.title)" -ForegroundColor Green

    if ($task.subitems) {
      $checklistUri = "$baseUri/$listId/tasks/$($newTask.id)/checklistItems"
      foreach ($sub in $task.subitems) {
        Invoke-RestMethod -Method POST -Uri $checklistUri -Headers $headers `
          -Body (@{ displayName = $sub } | ConvertTo-Json) `
          -ContentType 'application/json' | Out-Null
        $subitemsCreated++
      }
      Write-Host "      ($($task.subitems.Count) checklist item(s))" -ForegroundColor DarkGreen
    }
  }
}

Write-Host ""
Write-Host "✅ Done. Lists created: $listsCreated  ·  tasks created: $tasksCreated  ·  tasks skipped: $tasksSkipped  ·  subitems: $subitemsCreated" -ForegroundColor Cyan
Write-Host "   Open Microsoft To Do to see them." -ForegroundColor Cyan
